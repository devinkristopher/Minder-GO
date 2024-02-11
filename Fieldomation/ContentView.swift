//
//  ContentView.swift
//  Fieldomation
//
//  Created by Devin Rogers on 12/30/23.
//
import SafariServices
import SwiftUI
import VisionKit

struct ContentView: View {
    @State var myUrl = ""
    @State var mySetString = ""
    @EnvironmentObject var vm: AppViewModel
    
    private let textContentTypes: [(title: String, textContentType: DataScannerViewController.TextContentType?)] = [
        ("All", .none),
        ("URL", .URL),
        ("Phone", .telephoneNumber),
        ("Email", .emailAddress),
        ("Address", .fullStreetAddress),
        
    ]
    
    var body: some View {
        switch vm.dataScannerAccessStatus {
        case .scannerAvailable:
            mainView
        case .cameraNotAvailable:
            Text("Your device doesn't have a camera")
        case .scannerNotAvailable:
            Text("Your device doesn't have support for scanning barcode with this app")
        case .cameraAccessNotGranted:
            Text("Please provide access to the camera in settings")
        case .notDetermined:
            Text("Requesting camera access")
            Image(systemName: "gearshape.2.fill")
                .font(.system(size: 60))
        }
    }
    
    private var mainView: some View {
        DataScannerView(
            recognizedItems: $vm.recognizedItems,
            recognizedDataType: vm.recognizedDataType,
            recognizesMultipleItems: vm.recognizesMultipleItems)
        .background { Color(red: 0.00, green: 0.23, blue: 0.44) }
        .ignoresSafeArea()
        .id(vm.dataScannerViewId)
        .sheet(isPresented: .constant(true)) {
            bottomContainerView
                .background(.ultraThinMaterial)
                .presentationDetents([.medium, .fraction(0.25)])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled()
                .onAppear {
                    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                          let controller = windowScene.windows.first?.rootViewController?.presentedViewController else {
                        return
                    }
                    controller.view.backgroundColor = .clear
                }
        }
        .onChange(of: vm.scanType) { _ in vm.recognizedItems = [] }
        .onChange(of: vm.textContentType) { _ in vm.recognizedItems = [] }
        .onChange(of: vm.recognizesMultipleItems) { _ in vm.recognizedItems = []}
    }
    
    private var headerView: some View {
        VStack {
            HStack {
                Picker("Scan Type", selection: $vm.scanType) {
                    Button {
                    } label: {
                        Image(systemName: "barcode.viewfinder")
                    }
                    .tag(ScanType.barcode)
                    Button {
                    } label: {
                        Image(systemName: "rectangle.and.pencil.and.ellipsis")
                    }
                    .tag(ScanType.format)
                    Button {
                    } label: {
                        Image(systemName: "printer.fill")
                            .font(.system(size: 60))

                    }
                    .tag(ScanType.export)
                }.pickerStyle(.segmented)
                
            }.padding(.top)
            
            Text(vm.headerText)
                .padding(.top)
                .textCase(.uppercase)
                .font(.headline)
            if vm.scanType == .barcode {
                Toggle("Simultaneous object recognition", isOn: $vm.recognizesMultipleItems)
            }
            if vm.scanType == .format {
                Picker("Text content type", selection: $vm.textContentType) {
                    ForEach(textContentTypes, id: \.self.textContentType) { option in
                        Text(option.title).tag(option.textContentType)
                    }
                }.pickerStyle(.segmented)
                Toggle("Prepend Minder URL Path", isOn: $vm.prependsMinderURLPath)
            }
            if vm.scanType == .export {
                
                Text(mySetString)
                
                Button("Preview List", action: { readSetFromFile() })
                Button {
                action: do { readSetFromFile() }
                } label: {
                    Image(systemName: "list.bullet.rectangle.fill")
                        .font(.system(size: 60))
                }
                Button("Export as CSV", action: { readSetFromFile() })
                Button {
                } label: {
                    Image(systemName: "printer.fill")
                        .font(.system(size: 60))

                }
                Button("Send as email", action: { readSetFromFile() })
                Button {
                } label: {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 60))

                }
                
            }
        }.padding(.horizontal)
    }
    
    func readSetFromFile() {
        let file = "setdata.txt" //this is the file. we will write to and read from it
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            
            //reading
            do {
                let text2 = try String(contentsOf: fileURL, encoding: .utf8)
                print("text 2 is " + text2)
                mySetString = text2
                mySetString = String(mySetString.dropFirst())
                mySetString = String(mySetString.dropLast())
                var rows = mySetString.components(separatedBy: ", ")
                

                for i in rows.indices {
                    rows[i] = rows[i].replacingOccurrences(of: "\"", with: "")
                    if (vm.prependsMinderURLPath == true) { rows[i] = "https://v2.minder.io/miner/" + rows[i] }
                }
                
                
                print(rows)
                mySetString = rows.description
            }
            catch {/* error handling here */}
            
        }
    }
    
    @ViewBuilder
    private var bottomContainerView: some View {
        VStack {
            headerView
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(vm.recognizedItems) { item in
                        switch item {
                        case .barcode(let barcode):
                            Text("https://v2.minder.io/miner/\(barcode.payloadStringValue ?? "Unknown barcode")")
                        case .text(let text):
                            Text(text.transcript)
                            
                        @unknown default:
                            Text("Unknown")
                        }
                        
                        
                    }
                }
                .padding()
            }
        }
    }
    
    
  
}
