//
//  ListRowView.swift
//  BluetoothLEUtility
//
//  Created by 藤治仁 on 2020/01/06.
//  Copyright © 2020 F-Works. All rights reserved.
//

import SwiftUI

struct ListRowView: View {
    var title:String
    var detail:String
    var isSelect = false
    
    var body: some View {
        VStack(alignment: .leading) {
            if isSelect {
                Text(title)
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(Color.red)
                Text(detail)
                    .font(.caption)
                    .fontWeight(.bold)
            } else {
                Text(title)
                    .font(.body)
                    .foregroundColor(Color.red)
                Text(detail)
                    .font(.caption)
            }
        }
    }
}

struct ListRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ListRowView(title: "no name", detail: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")
            ListRowView(title: "Device Information", detail: "Service")
            ListRowView(title: "Manufacturing Name String", detail: "Characteristics")
            ListRowView(title: "Manufacturing Name String", detail: "Characteristics", isSelect: true)
        }
    }
}
