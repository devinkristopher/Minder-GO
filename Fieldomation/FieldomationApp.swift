//
//  FieldomationApp.swift
//  Fieldomation
//
//  Created by Devin Rogers on 12/30/23.
//

import SwiftUI

@main
struct FieldomationApp: App {
    
    @StateObject private var vm = AppViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
                .task{
                    await vm.requestDataScannerAccessStatus()
                }
        }
    }
}
