/*
See LICENSE folder for this sample’s licensing information.
*/

import SwiftUI
import UIKit

struct ActivityIndicatorView: UIViewRepresentable {
    let style: UIActivityIndicatorView.Style
    @Binding var showingIndicator: Bool

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView(style: style)
        activityIndicatorView.isHidden = !self.showingIndicator
        activityIndicatorView.startAnimating()

        return activityIndicatorView
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        uiView.isHidden = !self.showingIndicator
    }
}
