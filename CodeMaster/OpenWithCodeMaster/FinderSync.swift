//
//  FinderSync.swift
//  OpenWithCodeMaster
//
//  Created by Nevio Hirani on 17.09.23.
//

/**
 * For anyone working on this file.
 * print does not output to the console, use NSLog.
 * open "console.app" to debug,
 */

import Cocoa
import FinderSync
import os.log

class CMOpenWith: FIFinderSync {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "FinderSync")
    
    override init() {
        super.init()
        // Add finder sync
        let finderSync = FIFinderSyncController.default()
        if let mountedVolumes = FileManager.default.mountedVolumeURLs(
            includingResourceValuesForKeys: nil,
            options: [.skipHiddenVolumes]
        ) {
            finderSync.directoryURLs = Set<URL>(mountedVolumes)
        }
        // Monitor volumes
        let notificationCenter = NSWorkspace.shared.notificationCenter
        notificationCenter.addObserver(forName: NSWorkspace.didMountNotification,
                                       object: nil,
                                       queue: .main) { notification in
            if let volumeURL = notification.userInfo?[NSWorkspace.volumeURLUserInfoKey] as? URL {
                finderSync.directoryURLs.insert(volumeURL)
            }
        }
    }
    
    /// Open in CodeEdit (menu) action
    /// - Parameter sender: sender
    @objc
    func openInCodeMasterAction(_ sender: AnyObject?) {
        guard let items = FIFinderSyncController.default().selectedItemURLs(),
              let defaults = UserDefaults.init(suiteName: "app.codemaster.CodeMaster.shared") else { // TODO: Change name
            return
        }
        
        // Make values compatible to ArrayLiteralElement
        var files = ""
        
        for obj in items {
            files.append("\(obj.path);")
        }
        
        guard let codeMaster = NSWorkspace.shared.urlForApplication(
            withBundleIdentifier: "com.nhstudio.CodeMaster"
        ) else { return }
        
        // Add files to open to openInCMFiles
        defaults.set(files, forKey: "openInCMFiles")
        
        NSWorkspace.shared.open(
            [],
            withApplicationAt: codeMaster,
            configuration: NSWorkspace.OpenConfiguration()
        )
    }
    
    // MARK: - Menu and toolbar item support
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        guard let defaults = UserDefaults.init(suiteName: "app.codemaster.CodeMaster.shared") else {
            logger.error("Unable to load defaults")
            return NSMenu(title: "")
        }
        
        // Register enableOpenInCE (enable Open In CodeEdit
        defaults.register(defaults: ["enableOpenInCM" : true])
        
        let menu = NSMenu(title: "")
        let menuItem = NSMenuItem(
            title: "Open in CodeMaster",
            action: #selector(openInCodeMasterAction(_:)),
            keyEquivalent: ""
        )
        menuItem.image = NSImage.init(named: "icon")
        
        let enableOpenInCM = defaults.bool(forKey: "enableOpenInCM")
        logger.info("Enable Open In CodeMaster value is \(enableOpenInCM, privacy: .public)")
        if enableOpenInCM {
            menu.addItem(menuItem)
        }
        return menu
    }
}

