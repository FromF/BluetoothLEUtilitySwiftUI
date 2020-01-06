//
//  ServiceControlView.swift
//  BluetoothLEUtility
//
//  Created by 藤治仁 on 2020/01/06.
//  Copyright © 2020 F-Works. All rights reserved.
//

import SwiftUI
import CoreBluetooth

struct ServiceControlView: View {
    @ObservedObject var peripheralVM: PeripheralVM
    var service: CBService
    
    var body: some View {
        VStack {
            List(self.peripheralVM.characteristics) { characteristic in
                Button(action: {
                    self.peripheralVM.selectedCharacteristic = characteristic.characteristic
                }) {
                    ListRowView(title: characteristic.characteristicUuids, detail: "Characteristics")
                }
            }
            
            Spacer()
            
            TextField("Placeholder", text: $peripheralVM.characteristicString)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)
            
            Spacer()
            
            HStack {
                Button(action: {
                    self.peripheralVM.characteristicsWriteValue()
                }) {
                    Text("Write")
                    .frame(width: 100, height: 40, alignment: .center)
                    .background(Color.green)
                    .cornerRadius(6)
                    .foregroundColor(.white)
                }
                
                Button(action: {
                    self.peripheralVM.characteristicsReadValue()
                }) {
                    Text("Read")
                    .frame(width: 100, height: 40, alignment: .center)
                    .background(Color.red)
                    .cornerRadius(6)
                    .foregroundColor(.white)
                }
            }
            Spacer()
//            Button(action: {
//                
//            }) {
//                Text("Invoke App")
//                .frame(width: 200, height: 40, alignment: .center)
//                .background(Color.gray)
//                .cornerRadius(6)
//                .foregroundColor(.white)
//            }
//            Spacer()
        }
        .navigationBarTitle("Characteristics" ,displayMode: .inline)
        .onAppear() {
            _ = self.peripheralVM.searchCharacteristics(service: self.service)
        }
    }
}

//struct ServiceControlView_Previews: PreviewProvider {
//    static var previews: some View {
//        ServiceControlView()
//    }
//}
