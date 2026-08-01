//
//  main.swift
//  SDL2 Installer
//
//  Created by Checkm8ra1n on 01/08/26.
//

import Foundation

let sdl2Path = "/Library/Frameworks/SDL2.framework"
let fileManager = FileManager.default
let sdl2URL = "https://github.com/libsdl-org/SDL/releases/download/release-2.26.0/SDL2-2.26.0.dmg"

func downloadAndInstallSDL2() {
    let tempDir = NSTemporaryDirectory()
    let dmgFileName = "SDL2.dmg"
    let dmgPath = (tempDir as NSString).appendingPathComponent(dmgFileName)
    let mountPoint = (tempDir as NSString).appendingPathComponent("SDL2_Mount")
    
    print("Downloading SDL2 from: \(sdl2URL)")
    
    // Download DMG
    guard let url = URL(string: sdl2URL) else {
        print("Invalid URL")
        return
    }
    
    do {
        let data = try Data(contentsOf: url)
        try data.write(to: URL(fileURLWithPath: dmgPath))
        print("DMG downloaded: \(dmgPath)")
    } catch {
        print("Download error: \(error)")
        return
    }
    
    // Mount DMG
    print("Mounting DMG...")
    let mountTask = Process()
    mountTask.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil")
    mountTask.arguments = ["attach", dmgPath, "-mountpoint", mountPoint]
    
    do {
        try mountTask.run()
        mountTask.waitUntilExit()
        print("DMG mounted at: \(mountPoint)")
    } catch {
        print("Mount error: \(error)")
        return
    }
    
    // Copy SDL2.framework to /Library/Frameworks
    print("Copying SDL2.framework to /Library/Frameworks...")
    let sourceFramework = (mountPoint as NSString).appendingPathComponent("SDL2.framework")
    
    let copyTask = Process()
    copyTask.executableURL = URL(fileURLWithPath: "/bin/cp")
    copyTask.arguments = ["-r", sourceFramework, "/Library/Frameworks/"]
    
    do {
        try copyTask.run()
        copyTask.waitUntilExit()
        print("SDL2.framework copied successfully!")
    } catch {
        print("Copy error: \(error)")
        return
    }
    
    // Unmount DMG
    print("Unmounting DMG...")
    let unmountTask = Process()
    unmountTask.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil")
    unmountTask.arguments = ["detach", mountPoint]
    
    do {
        try unmountTask.run()
        unmountTask.waitUntilExit()
        print("DMG unmounted")
    } catch {
        print("Unmount error: \(error)")
    }
    
    // Cleanup
    try? fileManager.removeItem(atPath: dmgPath)
    print("Installation completed!")
}

if fileManager.fileExists(atPath: sdl2Path) {
    print("SDL2.framework already found at: \(sdl2Path)")
    exit(0)
}

downloadAndInstallSDL2()

