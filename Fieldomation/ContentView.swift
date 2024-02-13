//
//  ContentView.swift
//  Fieldomation
//
//  Created by Devin Rogers on 12/30/23.
//
import SafariServices
import SwiftUI
import VisionKit

struct ScanData {
    var asset: String
}

struct ContentView: View {
    @State var myUrl = ""
    @State var mySetString = ""
    @EnvironmentObject var vm: AppViewModel
    @State var setRows = [String]()
    
    private let textContentTypes: [(title: String, textContentType: DataScannerViewController.TextContentType?)] = [
        ("All", .none)
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
                Toggle("Display hyperlink on recognition", isOn: $vm.displayHyperlink)
            }
            if vm.scanType == .format {
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
                ShareLink(item:generateCSV()) {
                    Label("Export as CSV", systemImage: "list.bullet.rectangle.portrait")
                        .font(.system(size: 60))
                }
                
            }
        }.padding(.horizontal)
    }
    let scanData: [ScanData] = [
            ScanData(asset: " Asset Scan with Minder GO")
        ]

    func generateCSV() -> URL {
            var fileURL: URL!
            
        let time = NSDate().timeIntervalSince1970
        let myTimeInterval = TimeInterval(time)
        let heading = NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval)).description
        
            // file rows
        var rows = scanData.map { "\($0.asset)" }
        
        for i in 0..<setRows.count{
            rows.append(setRows[i])
        }
                    
            
            // rows to string data
            let stringData = heading + rows.joined(separator: "\n")
            
            do {
                
                let path = try FileManager.default.url(for: .documentDirectory,
                                                       in: .allDomainsMask,
                                                       appropriateFor: nil,
                                                       create: false)
                
                fileURL = path.appendingPathComponent("Minder GO Scan @ " + heading + ".csv")
                
                // append string data to file
                try stringData.write(to: fileURL, atomically: true , encoding: .utf8)
                print(fileURL!)
                
            } catch {
                print("error generating csv file")
            }
            return fileURL
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
                setRows = mySetString.components(separatedBy: ", ")
                

                for i in setRows.indices {
                    setRows[i] = setRows[i].replacingOccurrences(of: "\"", with: "")
                    if (vm.prependsMinderURLPath == true) { setRows[i] = "https://v2.minder.io/miner/" + setRows[i] }
                }
                
                
                print(setRows)
                mySetString = setRows.description
            }
            catch {/* error handling here */}
            
        }
    }
    
    
    func link(_ label: String, _ url: String) -> AttributedString {

        var attrStr = AttributedString(label)
        attrStr.link = URL(string: url)
        return attrStr
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
                            switch (vm.displayHyperlink) {
                            case true:
                                Text(link("Open in Minder", "https://v2.minder.io/miner/\(barcode.payloadStringValue ?? "Unknown barcode")"))
                                // Text("https://v2.minder.io/miner/\(barcode.payloadStringValue ?? "Unknown barcode")")
                            default:
                                Text("\(barcode.payloadStringValue ?? "Unknown barcode")")
                            }
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
    

