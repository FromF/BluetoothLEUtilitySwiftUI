//
//  ContentView.swift
//  BluetoothLEUtility
//
//  Created by 藤治仁 on 2020/01/06.
//  Copyright © 2020 F-Works. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var peripheralVM = PeripheralVM()
    
    var body: some View {
        VStack {
            List(self.peripheralVM.peripheralItems) {
                peripheralItem in
                Button(action: {
                    var result = true
                    if result {
                        result = self.peripheralVM.stopScan()
                    }
                    if result {
                        result = self.peripheralVM.connectPeripheral(peripheral: peripheralItem.peripheral)
                    }
                }) {
                    ListRowView(title: peripheralItem.name, detail: peripheralItem.uuid)
                }
            }
            if peripheralVM.state == .poweredOn {
                Button(action: {
                    _ = self.peripheralVM.startScan()
                }) {
                    Text("検索")
                }
            } else {
                Text("準備中")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
