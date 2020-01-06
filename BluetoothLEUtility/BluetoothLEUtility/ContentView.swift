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
        NavigationView {
            VStack {
                List(self.peripheralVM.peripheralItems) {
                    peripheralItem in
                    NavigationLink(destination: ServiceListView(peripheralVM: self.peripheralVM, peripheral: peripheralItem.peripheral)) {
                        ListRowView(title: peripheralItem.name, detail: peripheralItem.uuid)
                    }
                }
                if peripheralVM.state == .poweredOn {
                    Button(action: {
                        _ = self.peripheralVM.startScan()
                    }) {
                        Text("Search")
                        .frame(width: 200, height: 40, alignment: .center)
                        .background(Color.red)
                        .cornerRadius(6)
                        .foregroundColor(.white)
                    }
                } else {
                    Text("Initialize")
                    .frame(width: 200, height: 40, alignment: .center)
                    .background(Color.gray)
                    .cornerRadius(6)
                    .foregroundColor(.white)
                }
            }
            .navigationBarTitle("Peripheral" ,displayMode: .inline)
        }
        .onAppear() {
            _ = self.peripheralVM.disconnectPeripheral()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
