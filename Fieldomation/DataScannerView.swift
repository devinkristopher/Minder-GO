//
//  DataScannerView.swift
//  Fieldomation
//
//  Created by Devin Rogers on 12/30/23.
//

import Foundation
import SwiftUI
import VisionKit
import Observation
import AVFAudio
import AVFoundation

struct DataScannerView: UIViewControllerRepresentable {
    @Binding var recognizedItems: [RecognizedItem]
    let recognizedDataType: DataScannerViewController.RecognizedDataType
    let recognizesMultipleItems: Bool
    
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let vc = DataScannerViewController(
            recognizedDataTypes: [recognizedDataType],
            qualityLevel: .accurate,
            recognizesMultipleItems: recognizesMultipleItems,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        return vc
    }
    
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        uiViewController.delegate = context.coordinator
        try? uiViewController.startScanning()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(recognizedItems: $recognizedItems)
    }
    
    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning()
    }
    
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        @State var itemSet = ItemSet()
        @Binding var recognizedItems: [RecognizedItem]
        
        
        init(recognizedItems: Binding<[RecognizedItem]>) {
            self._recognizedItems = recognizedItems
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            print("didTapOn \(item)")
        }
        
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            recognizedItems.append(contentsOf: addedItems)
            print("didAddItems \(addedItems)")
            let strDesc = addedItems.description
            print("----------------")
            // print(strDesc[strDesc.range(of: "Optional")!.lowerBound])
            // print(strDesc[strDesc.range(of: "), observation:")!.lowerBound])
            // print(strDesc[strDesc.index(strDesc.range(of: "Optional")!.lowerBound, offsetBy: 10)])
            
            if (strDesc.range(of: "Optional") != nil) {
                let start = strDesc.index(strDesc.range(of: "Optional")!.lowerBound, offsetBy: 10)
                let end = strDesc.index(strDesc.range(of: "), observation:")!.lowerBound, offsetBy: -1)
                let range = start..<end
                var mySubstring = strDesc[range]
                itemSet.insert(str: String(mySubstring))
            }
   
            
            print("----------------")
            print("added to set")
            print("****************")
            print(itemSet.toString())
            print("going to write " + itemSet.toString() + " to file")
            
            
            let file = "setdata.txt" //this is the file. we will write to and read from it

            let text = itemSet.toString() //just a text

            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

                let fileURL = dir.appendingPathComponent(file)

                //writing
                do {
                    try text.write(to: fileURL, atomically: false, encoding: .utf8)
                }
                catch {/* error handling here */}

                //reading
                do {
                    let text2 = try String(contentsOf: fileURL, encoding: .utf8)
                    print("text 2 is " + text2)
                }
                catch {/* error handling here */}
            }
            print("****************")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            self.recognizedItems = recognizedItems.filter { item in
                !removedItems.contains(where: {$0.id == item.id })
            }
            print("didRemovedItems \(removedItems)")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
            print("became unavailable with error \(error.localizedDescription)")
        }
        
        
        
      
        
    }
    
    
    
}




