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
                NavigationLink(destination: ServiceControlView(peripheralVM: self.peripheralVM, service: peripheralService.service)) {
                    ListRowView(title: peripheralService.serviceUuids, detail: "Service")
                }
            }
            .navigationBarTitle("Service" ,displayMode: .inline)
            .onAppear() {
                var result = true
                if result {
                    _ = self.peripheralVM.stopScan()
                }
                if result {
                    result = self.peripheralVM.connectPeripheral(peripheral: self.peripheral)
                }
            }
        }
    }
}

//struct ServiceListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ServiceListView(peripheralVM: <#Binding<PeripheralVM>#>)
//    }
//}
