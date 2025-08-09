//
//  McServerDownloader.swift
//  Created by Hannes Müller on 01.08.25
//

import Foundation

let fileManager = FileManager.default
let homeDir = NSHomeDirectory()
let mcServerRoot = "\(homeDir)/Documents/McServer"

// 🔹 URL zur Forge-Versionen-Datei (z. B. GitHub raw link)
let forgeVersionURL = "https://raw.githubusercontent.com/HannAnto/McServerUtilities/main/forge_versions.txt"

// 🔹 Funktion: Forge-Versionen aus Online-Datei laden
func loadForgeVersions(from urlString: String) -> [String] {
    guard let url = URL(string: urlString),
          let content = try? String(contentsOf: url, encoding:.utf8) else {
        print("❌ Konnte Forge-Versionen nicht laden.")
        return []
}

    return content
.split(separator: "\n")
.map { $0.trimmingCharacters(in:.whitespacesAndNewlines)}
.filter {!$0.isEmpty && $0.contains("-")}
}

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

// 🔹 Funktion: Datei herunterladen
func downloadFile(from urlString: String, to destinationPath: String) throws {
    guard let url = URL(string: urlString) else {
        throw NSError(domain: "Invalid URL", code: 1)
}
    let data = try Data(contentsOf: url)
    try data.write(to: URL(fileURLWithPath: destinationPath))
}

// 🔹 Funktion: Forge Installer ausführen
func runForgeInstaller(at installerPath: String, in directory: String) throws {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/java")
    task.arguments = ["-jar", installerPath, "--installServer"]
    task.currentDirectoryURL = URL(fileURLWithPath: directory)
    try task.run()
    task.waitUntilExit()
}

// 🔹 Funktion: Forge-URL generieren
func generateForgeURL(from version: String) -> String {
    return "https://maven.minecraftforge.net/net/minecraftforge/forge/\(version)/forge-\(version)-installer.jar"
}

// 🔹 Zielordner vorbereiten
try? fileManager.createDirectory(atPath: mcServerRoot, withIntermediateDirectories: true)
let serverFolder = nextAvailableFolder(baseName: "NewServer", in: mcServerRoot)

print("""
🧲 Minecraft Server Downloader
V - Vanilla   F - Forge
""")

guard let choice = readLine()?.uppercased() else {
    print("❌ Keine Eingabe erkannt.")
    exit(1)
}

do {
    try fileManager.createDirectory(atPath: serverFolder, withIntermediateDirectories: true)
    print("📁 Ordner erstellt unter: \(serverFolder)")

    switch choice {
    case "V":
        print("📦 Starte Download des Vanilla Servers...")
        let jarURL = "https://piston-data.mojang.com/v1/objects/6bce4ef400e4efaa63a13d5e6f6b500be969ef81/server.jar"
        let jarDestination = "\(serverFolder)/server.jar"
        try downloadFile(from: jarURL, to: jarDestination)
        print("✅ Vanilla Server heruntergeladen und gespeichert als server.jar")

    case "F":
        print("🔄 Lade Forge-Versionen aus dem Internet...")
        let forgeVersions = loadForgeVersions(from: forgeVersionURL)

        if forgeVersions.isEmpty {
            print("❌ Keine Forge-Versionen gefunden.")
            exit(1)
}

        print("🔢 Verfügbare Forge-Versionen:")
        for (index, version) in forgeVersions.enumerated() {
            print("[\(index)] \(version)")
}

        print("👉 Wähle eine Version durch Eingabe der Nummer:")
        guard let input = readLine(), let index = Int(input), forgeVersions.indices.contains(index) else {
            print("❌ Ungültige Auswahl.")
            exit(1)
}

        let selectedVersion = forgeVersions[index]
        let installerURL = generateForgeURL(from: selectedVersion)
        let installerPath = "\(serverFolder)/forge-installer.jar"

        print("📦 Lade Forge Installer für Version \(selectedVersion)...")
        try downloadFile(from: installerURL, to: installerPath)

        print("🛠 Installiere Forge Server...")
        try runForgeInstaller(at: installerPath, in: serverFolder)

        print("✅ Forge Server installiert")

    default:
        print("❌ Auswahl nicht erkannt.")
        exit(1)
}

    print("🎉 Fertig! Server gespeichert unter: \(serverFolder)")

} catch {
    print("❌ Fehler: \(error.localizedDescription)")
    exit(1)
}
