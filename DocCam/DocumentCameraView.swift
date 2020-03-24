/*
See LICENSE folder for this sample’s licensing information.
*/

import SwiftUI
import UIKit
import Vision
import VisionKit

struct DocumentCameraView: UIViewControllerRepresentable  {
    let preparationHandler: (() -> Void)?
    let completionHandler: ((String) -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = context.coordinator

        return documentCameraViewController
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
    }

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: DocumentCameraView

        init(_ documentCameraView: DocumentCameraView) {
            self.parent = documentCameraView
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            let textRecogizer = TextRecognizer(scan: scan)
            textRecogizer.request(
                preparationHandler: self.parent.preparationHandler,
                completionHandler: self.parent.completionHandler
            )
        }
    }

    class TextRecognizer {
        private let scan: VNDocumentCameraScan

        // Vision requests to be performed on each page of the scanned document.
        private var requests = [VNRequest]()
        // Dispatch queue to perform Vision requests.
        private let textRecognitionWorkQueue = DispatchQueue(
            label: "TextRecognitionQueue",
            qos: .userInitiated,
            attributes: [],
            autoreleaseFrequency: .workItem
        )
        private var resultingText: String = ""

        init(scan: VNDocumentCameraScan) {
            self.scan = scan
            self.setupVision()
        }

        // Setup Vision request as the request can be reused
        private func setupVision() {
            let textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    print("The observations are of an unexpected type.")
                    return
                }
                // Concatenate the recognised text from all the observations.
                let maximumCandidates = 1
                for observation in observations {
                    guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
                    self.resultingText += candidate.string + "\n"
                }
            }
            // specify the recognition level
            textRecognitionRequest.recognitionLevel = .accurate
            self.requests = [textRecognitionRequest]
        }

        func request(preparationHandler: (() -> Void)?,
                     completionHandler: ((String) -> Void)?) {
            if let preparationHandler = preparationHandler {
                preparationHandler()
            }

            self.textRecognitionWorkQueue.async {
                self.resultingText = ""
                for pageIndex in 0 ..< self.scan.pageCount {
                    let image = self.scan.imageOfPage(at: pageIndex)
                    if let cgImage = image.cgImage {
                        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                        do {
                            try requestHandler.perform(self.requests)
                        } catch {
                            print(error)
                        }
                    }
                    self.resultingText += "\n\n"
                }
                DispatchQueue.main.async(execute: {
                    if let completionHandler = completionHandler {
                        completionHandler(self.resultingText)
                    }
                })
            }
        }
    }
}
