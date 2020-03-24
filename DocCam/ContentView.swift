/*
See LICENSE folder for this sample’s licensing information.
*/

import SwiftUI

struct ContentView: View {
    @State var text: String = "Resulting text goes here"
    @State var showingIndicator: Bool = false
    @State var showingCamera: Bool = false

    var body: some View {
        ZStack {
            Group {
                VStack {
                    TextView(text: $text)
                    Button("Scan Document") {
                        self.openCamera()
                    }
                }
                ActivityIndicatorView(
                    style: .large,
                    showingIndicator: $showingIndicator
                )
            }
            .padding()
            .sheet(isPresented: $showingCamera) {
                self.scanDocument()
            }
        }
    }

    private func openCamera() {
        self.showingCamera.toggle()
    }

    private func scanDocument() -> DocumentCameraView {
        DocumentCameraView(
            preparationHandler: {
                self.text = ""
                self.showingCamera.toggle()
                self.showingIndicator.toggle()
            },
            completionHandler: { text in
                self.text = text
                self.showingIndicator.toggle()
            }
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            text: "Resulting text goes here",
            showingIndicator: false
        )
    }
}
