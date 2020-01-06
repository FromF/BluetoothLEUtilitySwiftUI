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

class PeripheralVM: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, ObservableObject {
    
    @Published var peripheralItems: [PeripheralItem] = []
    @Published var state: CBManagerState = .unknown
    @Published var connectedPeripheral: CBPeripheral? = nil
    @Published var peripheralServices: [PeripheralService] = []

    private var centralManager: CBCentralManager!
    
    override init() {
        super.init()
        
        let queue = DispatchQueue(label: "FromF.github.com.BluetoothLEUtility.PeripheralVM")
        centralManager = CBCentralManager(delegate: self, queue: queue, options: nil)
    }
    
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

    /// Serviceの検索
    private func searchService() {
        guard let _connectedPeripheral = connectedPeripheral else {
            errorLog("Unwrap Error")
            return
        }
        
        _connectedPeripheral.delegate = self
        _connectedPeripheral.discoverServices(nil)
    }
    
    // MARK: - CBCentralManagerDelegate
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
    
    // MARK: - CBPeripheralDelegate
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
}
