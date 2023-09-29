//
//  ImageFileView.swift
//  CodeMaster
//
//  Created by Nevio Hirani on 29.09.23.
//

import SwiftUI

struct ImageFileView: View {
    private let image: NSImage?

    init(image: NSImage?) {
        self.image = image
    }
    
    var body: some View {
        GeometryReader { proxy in
            if let image {
                if image.size.width > proxy.size.width || image.size.height > proxy.size.height {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(nsImage: image)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                }
            } else {
                EmptyView()
            }
        }
    }
}
