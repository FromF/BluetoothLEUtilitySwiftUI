//
//  ServiceListView.swift
//  BluetoothLEUtility
//
//  Created by 藤治仁 on 2020/01/06.
//  Copyright © 2020 F-Works. All rights reserved.
//

import SwiftUI
import CoreBluetooth

struct ServiceListView: View {
    @ObservedObject var peripheralVM: PeripheralVM
    var peripheral: CBPeripheral

    var body: some View {
        NavigationView {
            List(self.peripheralVM.peripheralServices) {
                peripheralService in
                Button(action: {
                    //無処理
                }) {
                    ListRowView(title: peripheralService.serviceUuids, detail: "Service")
                }
            }
            .navigationBarTitle("サービス一覧" ,displayMode: .inline)
            .onAppear() {
                var result = true
                if result {
                    _ = self.peripheralVM.stopScan()
                }
                if result {
                    result = self.peripheralVM.connectPeripheral(peripheral: self.peripheral)
                }
            }
            .onDisappear() {
                _ = self.peripheralVM.disconnectPeripheral()
            }
        }
    }
}

//struct ServiceListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ServiceListView(peripheralVM: <#Binding<PeripheralVM>#>)
//    }
//}
