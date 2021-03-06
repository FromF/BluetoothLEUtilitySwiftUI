//
//  PeripheralVM.swift
//  BluetoothLEUtility
//
//  Created by 藤治仁 on 2020/01/06.
//  Copyright © 2020 F-Works. All rights reserved.
//

import Foundation
import CoreBluetooth

struct PeripheralItem : Identifiable {
    let id = UUID()
    let uuid: String
    let name: String
    let peripheral: CBPeripheral
    let rssi: NSNumber
}

struct PeripheralService : Identifiable {
    let id = UUID()
    let peripheral: CBPeripheral
    let serviceUuids: String
    let service: CBService
}

struct Characteristic : Identifiable {
    let id = UUID()
    let characteristicUuids: String
    let characteristic: CBCharacteristic
}

class PeripheralVM: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, ObservableObject {
    /// ペリフェラルスキャン結果
    @Published var peripheralItems: [PeripheralItem] = []
    /// デバイス状態
    @Published var state: CBManagerState = .unknown
    /// サービス検索結果
    @Published var peripheralServices: [PeripheralService] = []
    /// キャラクタリスティック検索結果
    @Published var characteristics: [Characteristic] = []
    /// Read/Writeをする対象キャラクタリスティック
    @Published var selectedCharacteristic: CBCharacteristic?
    /// キャラクタリスティックへのRead結果/WriteするString
    @Published var characteristicString: String = ""
    
    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral? = nil
    
    override init() {
        super.init()
        
        let queue = DispatchQueue(label: "FromF.github.com.BluetoothLEUtility.PeripheralVM")
        centralManager = CBCentralManager(delegate: self, queue: queue, options: nil)
    }
    
    // MARK: - ペリフェラルスキャン開始・終了
    func startScan() -> Bool {
        let result = state == .poweredOn ? true : false
        
        if result {
            // リストをクリアする
            peripheralItems = []
            // 重複して検出しない
            let options = [CBCentralManagerScanOptionAllowDuplicatesKey: false]
            // BLEデバイスの検出を開始
            centralManager.scanForPeripherals(withServices: nil, options: options)
        }
        
        return result
    }
    
    func stopScan() -> Bool {
        var result = state == .poweredOn ? true : false
        
        if result {
            if !centralManager.isScanning {
                result = false
            }
        }
        
        if result {
            // BLEデバイスの検出を終了
            centralManager.stopScan()
        }
        
        return result
    }
    
    // MARK: - ペリフェラルスキャン接続・切断
    func connectPeripheral(peripheral: CBPeripheral) -> Bool {
        let result = state == .poweredOn ? true : false
        
        if result {
            DispatchQueue.main.async {
                self.peripheralServices = []
            }
            centralManager.connect(peripheral, options: nil)
        }
        
        return result
    }
    
    func disconnectPeripheral() -> Bool {
        let result = state == .poweredOn ? true : false
        
        if result {
            if let _connectedPeripheral = connectedPeripheral {
                centralManager.cancelPeripheralConnection(_connectedPeripheral)
            }
        }
        
        return result
    }
    
    // MARK: - サービス検索
    /// Serviceの検索
    private func searchService() {
        guard let _connectedPeripheral = connectedPeripheral else {
            errorLog("Unwrap Error")
            return
        }
        
        _connectedPeripheral.delegate = self
        _connectedPeripheral.discoverServices(nil)
    }
    
    // MARK: - キャラクタリスティック検索
    /// Charactaristicsの検索
    func searchCharacteristics(service: CBService){
        guard let _connectedPeripheral = connectedPeripheral else {
            errorLog("Unwrap Error")
            return
        }
        DispatchQueue.main.async {
            self.characteristics = []
            self.characteristicString = ""
            _connectedPeripheral.delegate = self
            _connectedPeripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    // MARK: - キャラクタリスティックのRead/Write
    func characteristicsReadValue() {
        guard let _connectedPeripheral = connectedPeripheral else {
            errorLog("Unwrap Error")
            return
        }
        guard let _selectedCharacteristic = selectedCharacteristic else {
            errorLog("Unwrap Error")
            return
        }
        
        _connectedPeripheral.readValue(for: _selectedCharacteristic)
    }
    
    func characteristicsWriteValue() {
        guard let _connectedPeripheral = connectedPeripheral else {
            errorLog("Unwrap Error")
            return
        }
        guard let _selectedCharacteristic = selectedCharacteristic else {
            errorLog("Unwrap Error")
            return
        }

        guard let data = characteristicString.data(using: .utf8, allowLossyConversion: true) else {
            errorLog("Unwrap Error")
            return
        }
        
        _connectedPeripheral.writeValue(data, for: _selectedCharacteristic, type: .withResponse)
    }

    // MARK: - CBCentralManagerDelegate - デバイス起動時のdelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async {
            self.state = central.state
            debugLog("state \(self.state)");
            switch self.state {
            case .poweredOff:
                debugLog("Bluetoothの電源がOff")
            case .poweredOn:
                debugLog("Bluetoothの電源はOn")
            case .resetting:
                debugLog("レスティング状態")
            case .unauthorized:
                debugLog("非認証状態")
            case .unknown:
                debugLog("不明")
            case .unsupported:
                debugLog("非対応")
            @unknown default:
                fatalError()
            }
        }
    }
    
    // MARK: - CBCentralManagerDelegate - ペリフェラルスキャン時のdelegate
    // BLEデバイスが検出された際に呼び出される.
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        debugLog("\(peripheral.name ?? "no name") \(peripheral.identifier.uuidString) \(RSSI)")
        debugLog(" \(advertisementData)")
        
        let kCBAdvDataLocalName = advertisementData["kCBAdvDataLocalName"] as? String
        
        let peripheralItem = PeripheralItem(uuid: peripheral.identifier.uuidString,
                                            name: kCBAdvDataLocalName ?? peripheral.name ?? "no name",
                                            peripheral: peripheral,
                                            rssi: RSSI)
        DispatchQueue.main.async {
            self.peripheralItems.append(peripheralItem)
        }
    }
    
    // MARK: - CBCentralManagerDelegate - ペリフェラル接続/切断時のdelegate
    // Peripheralに接続
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        debugLog("Connect")
        
        DispatchQueue.main.async {
            // 接続済みのペリフェラルを保存する
            self.connectedPeripheral = peripheral
            
            // サービスの検索開始
            self.searchService()
        }
    }
    
    // Peripheralに接続失敗した際
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let e = error {
            errorLog("Error: \(e.localizedDescription)")
        } else {
            errorLog("Not Connect")
        }
    }
    
    // Peripheralの切断
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        debugLog("Disconnect")
        if let e = error {
            errorLog("Error: \(e.localizedDescription)")
        }
        
        DispatchQueue.main.async {
            // 接続済みのペリフェラルを初期化する
            self.connectedPeripheral = nil
        }
    }
    
    // MARK: - CBPeripheralDelegate - サービス検索時のdelegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        debugLog("didDiscoverServices")
        
        if let services = peripheral.services {
            for service in services {
                let peripheralService = PeripheralService(peripheral: peripheral, serviceUuids: service.uuid.uuidString, service: service)
                DispatchQueue.main.async {
                    self.peripheralServices.append(peripheralService)
                }
            }
        }
    }
    
    // MARK: - CBPeripheralDelegate - キャラクタリスティック検索時のdelegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let e = error {
            errorLog("Error: \(e.localizedDescription)")
        } else if let characteristics = service.characteristics {
            for characteristic in characteristics {
                let _characteristic = Characteristic(characteristicUuids: characteristic.uuid.uuidString, characteristic: characteristic)
                DispatchQueue.main.async {
                    self.characteristics.append(_characteristic)
                }
            }
        }
    }
    
    // MARK: - CBPeripheralDelegate - キャラクタリスティックRead/Write時のdelegate
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let e = error {
            errorLog("Error: \(e.localizedDescription)")
        } else if let value = characteristic.value {
            DispatchQueue.main.async {
                if let string = String(data: value, encoding: .utf8) {
                    self.characteristicString = string
                } else {
                    self.characteristicString = "\(value)"
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        if let e = error {
            errorLog("Error: \(e.localizedDescription)")
        } else {
            debugLog("success")
        }
    }
}
