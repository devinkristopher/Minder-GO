//
//  ContentView.swift
//  Fieldomation
//
//  Created by Devin Rogers on 12/30/23.
//
import SafariServices
import SwiftUI
import VisionKit
import AVFoundation

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
                .presentationDetents([.medium, .fraction(0.38)])
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
                }
                .onChange(of: vm.scanType) {
                    readSetFromFile()
                }
                .pickerStyle(.segmented)
                .padding(.top)
                
            }
            Text(vm.headerText)
                .textCase(.uppercase)
                .font(.headline)
                .padding(.bottom)
            if vm.scanType == .barcode {
                HStack {
                    Spacer()
                    VStack {
                        Button(action: {
                            toggleTorch()
                        }) {
                            Image(systemName: "flashlight.on.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.black)
                        }
                    }
                    Spacer()
                }
                VStack {
                    Toggle("Simultaneous object recognition", isOn: $vm.recognizesMultipleItems)
                    Toggle("Display hyperlink on recognition", isOn: $vm.displayHyperlink)
                }
            }
            if vm.scanType == .format {
                VStack{
                    Toggle("Prepend Minder URL Path", isOn: $vm.prependsMinderURLPath)
                        .onChange(of: vm.prependsMinderURLPath) {
                            readSetFromFile()
                        }
                }
            }
            if vm.scanType == .export {
                HStack {
                    Spacer()
                    VStack {
                          Button(action: {
                              readSetFromFile()
                          }) {
                            Label("Generate", systemImage: "sparkles")
                              .padding()
                              .foregroundColor(.white)
                              .background(LinearGradient(colors: [Color.purple, Color.indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                              .cornerRadius(50)
                              .fontDesign(.rounded)
                              .textCase(.uppercase)
                              .font(.subheadline)
                              .tracking(2.5)
                          }
                        }
                    Spacer()
                            .overlay(
                                ShareLink(item:generateCSV()) {
                                    Image(systemName: "square.and.arrow.up.circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.black)
                                }
                                .padding(.leading)
                            )
                }
                .padding(.bottom)
            }
            
        }
        .padding(.horizontal)
        .padding(.top)
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
    
    
    // This function is used to format the Minder URL into a clickable link.
    func link(_ label: String, _ url: String) -> AttributedString {
        var attrStr = AttributedString(label)
        attrStr.link = URL(string: url)
        return attrStr
    }
    
    func toggleTorch() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTripleCamera, .builtInDualWideCamera, .builtInUltraWideCamera, .builtInWideAngleCamera, .builtInTrueDepthCamera], mediaType: AVMediaType.video, position: .back)
            guard let device = deviceDiscoverySession.devices.first else {return}

            if device.hasTorch && device.isTorchAvailable {
                do {
                    try device.lockForConfiguration()
                    if device.torchMode == .off {
                        try device.setTorchModeOn(level: 1.0) // adjust torch intensity here
                    } else {
                        device.torchMode = .off
                    }
                    device.unlockForConfiguration()
                } catch {
                    print("Torch could not be used")
                }
            } else {
                print("Torch is not available")
            }
        }
    
    
    
    @ViewBuilder
    private var bottomContainerView: some View {
        VStack {
            headerView
            
            if vm.scanType == .barcode {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(vm.recognizedItems) { item in
                            switch item {
                            case .barcode(let barcode):
                                switch (vm.displayHyperlink) {
                                case true:
                                    // This uses the link function, displaying a clickable link.
                                    Text(link("Open \(barcode.payloadStringValue ?? "miner") in Minder", "https://v2.minder.io/miner/\(barcode.payloadStringValue ?? "Unknown barcode")"))
                                        .frame(maxWidth: .infinity, alignment: .center)
                                default:
                                    Text("\(barcode.payloadStringValue ?? "Unknown barcode")")
                                        .frame(maxWidth: .infinity, alignment: .center)
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
            if vm.scanType == .format {
                VStack {
                    ScrollView {
                        
                        Text(setRows.count == 1 ? "\(setRows.count.description)" + " asset scanned" : "\(setRows.count.description)" + " assets scanned")
                        
                        //Text(setRows.count.description + setRows.count == 1 ?? "asset ", : "assets " + "scanned")
                        ForEach (0..<setRows.count, id: \.self) { i in
                            Text(setRows[i])
                        }

                    }
                }
            }
            if vm.scanType == .export {
                VStack {
                    ScrollView {
                        Text(mySetString)
                    }
                }
            }
            
        }
    }
    

}
    

