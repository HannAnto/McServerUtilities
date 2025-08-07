//  McServerDownloader
//
//  Created by Hannes Müller on 01.08.25.
//
import Foundation

let fileManager = FileManager.default
let homeDir = NSHomeDirectory()

// 🔹 Funktion: Nächster verfügbarer Ordnername
func nextAvailableFolder(baseName: String, in parent: String) -> String {
    var index = 1
    var folder = "\(parent)/\(baseName)"
    while fileManager.fileExists(atPath: folder) {
        index += 1
        folder = "\(parent)/\(baseName) \(index)"
}
    return folder
}

// 🔹 Zielordner vorbereiten
let mcServerRoot = "\(homeDir)/Documents/McServer"
try? fileManager.createDirectory(atPath: mcServerRoot, withIntermediateDirectories: true)
let serverFolder = nextAvailableFolder(baseName: "NewServer", in: mcServerRoot)

// 🔹 Begrüßung & Auswahl
print("""
🧲 Download Mc Server
V - Vanilla   F - Forge
""")

guard let choice = readLine()?.uppercased() else {
    print("❌ Keine Eingabe erkannt.")
    exit(1)
}

if choice == "V" {
    print("📦 Starte Download des Vanilla Servers...")

    // 🔹 Aktuelle Vanilla-URL (z. B. Minecraft 1.20.6)
    let jarURL = "https://piston-data.mojang.com/v1/objects/6bce4ef400e4efaa63a13d5e6f6b500be969ef81/server.jar"
    let jarDestination = "\(serverFolder)/server.jar"

    do {
        try fileManager.createDirectory(atPath: serverFolder, withIntermediateDirectories: true)
        print("📁 Ordner erstellt unter: \(serverFolder)")
} catch {
        print("❌ Fehler beim Erstellen des Ordners: \(error)")
        exit(1)
}

    guard let url = URL(string: jarURL) else {
        print("❌ Ungültige URL")
        exit(1)
}

    do {
        let data = try Data(contentsOf: url)
        try data.write(to: URL(fileURLWithPath: jarDestination))
        print("✅ Download erfolgreich")
        print("💾 Gespeichert als: server.jar")
} catch {
        print("❌ Fehler beim Download oder Speichern: \(error)")
        exit(1)
}

    print("🎉 Fertig! Vanilla Server wurde erfolgreich eingerichtet.")
}

else if choice == "F" {
    print("Which Version? 1.20.1 or 1.21.8")
    guard let version = readLine(), ["1.20.1", "1.21.8"].contains(version) else {
        print("❌ Version nicht verfügbar oder ungültig.")
        exit(1)
}

    let installerURL: String
    switch version {
    case "1.20.1":
        installerURL = "https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.4.6/forge-1.20.1-47.4.6-installer.jar"
    case "1.21.8":
        installerURL = "https://maven.minecraftforge.net/net/minecraftforge/forge/1.21.8-58.0.5/forge-1.21.8-58.0.5-installer.jar"
    default:
        print("❌ Keine gültige Forge-Version.")
        exit(1)
}

    print("📦 Starte Download von Forge \(version)...")
    let installerPath = "\(serverFolder)/forge-installer.jar"

    do {
        try fileManager.createDirectory(atPath: serverFolder, withIntermediateDirectories: true)
        print("📁 Ordner erstellt unter: \(serverFolder)")
} catch {
        print("❌ Fehler beim Erstellen des Ordners: \(error)")
        exit(1)
}

    guard let url = URL(string: installerURL) else {
        print("❌ Ungültige URL")
        exit(1)
}

    do {
        let data = try Data(contentsOf: url)
        try data.write(to: URL(fileURLWithPath: installerPath))
        print("✅ Download erfolgreich")
} catch {
        print("❌ Fehler beim Download oder Speichern: \(error)")
        exit(1)
}

    print("🛠 Installiere Forge Server...")
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/java")
    task.arguments = ["-jar", installerPath, "--installServer"]
    task.currentDirectoryURL = URL(fileURLWithPath: serverFolder)

    do {
        try task.run()
        task.waitUntilExit()
        print("✅ Forge Server installiert")
} catch {
        print("❌ Fehler beim Ausführen des Installers: \(error)")
        exit(1)
}

    print("💾 Forge Server gespeichert in: \(serverFolder)")
    print("🎉 Fertig!")
}

else {
    print("❌ Auswahl nicht erkannt.")
}
