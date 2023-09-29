//
//  CodeFile.swift
//  CodeMaster
//
//  Created by Nevio Hirani on 29.09.23.
//

import AppKit
import Foundation
import SwiftUI
import UniformTypeIdentifiers
import QuickLookUI
import CodeMasterTextView
//import CodeMasterLanguage

enum CodeFileError: Error {
    case failedToDecode
    case failedToEncode
    case fileTypeError
}

@objc(CodeFileDocument)
final class CodeFileDocument: NSDocument, ObservableObject, QLPreviewItem {  }
