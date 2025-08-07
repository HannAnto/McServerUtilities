import Foundation

    let args = CommandLine.arguments
    let fileManager = FileManager.default
    let homeDir = NSHomeDirectory()
    let launchAgentsPath = "\(homeDir)/Library/LaunchAgents"
    let agentLabel = "com.hannes.mcbackup"
    let agentPlistPath = "\(launchAgentsPath)/\(agentLabel).plist"
    let scriptPath = CommandLine.arguments[0]
    let backupRoot = "\(homeDir)/Documents/Server backups"
    let configPath = "\(backupRoot)/serverbackup.txt"

    // 🔹 Uninstall-Modus
    if args.contains("-uninstall") {
        print("🧹 Starte Deinstallation...")

        let unloadTask = Process()
        unloadTask.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        unloadTask.arguments = ["unload", agentPlistPath]
        do {
            try unloadTask.run()
            unloadTask.waitUntilExit()
            print("🚫 Launch Agent deaktiviert")
    } catch {
            print("⚠️ Konnte Agent nicht deaktivieren: \(error)")
    }

        if fileManager.fileExists(atPath: agentPlistPath) {
            try? fileManager.removeItem(atPath: agentPlistPath)
            print("🗑️ Entfernt: \(agentPlistPath)")
    }

        if fileManager.fileExists(atPath: configPath) {
            try? fileManager.removeItem(atPath: configPath)
            print("🗑️ Entfernt: \(configPath)")
    }

        print("✅ Deinstallation abgeschlossen. Das CLI-Tool selbst wurde nicht gelöscht.")
        exit(0)
    }

    if args.contains("-status") {
    print("📊 Statusbericht für McServerBackup\n")

    // 🔹 Agent-Status prüfen
    let checkTask = Process()
    checkTask.executableURL = URL(fileURLWithPath: "/bin/launchctl")
    checkTask.arguments = ["list", agentLabel]

    let pipe = Pipe()
    checkTask.standardOutput = pipe
    do {
        try checkTask.run()
        checkTask.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding:.utf8),!output.isEmpty {
            print("🚀 Launch Agent ist aktiv:\n\(output)")
} else {
            print("⚠️ Launch Agent ist nicht geladen.")
}
} catch {
        print("❌ Fehler beim Prüfen des Agent-Status: \(error)")
}

    // 🔹 Backup-Übersicht
    print("\n📁 Backup-Ordnerübersicht:")
    let backupRoot = "\(homeDir)/Documents/Server backups"
    if let folders = try? fileManager.contentsOfDirectory(atPath: backupRoot) {
        for folder in folders {
            let fullPath = "\(backupRoot)/\(folder)"
            if let backups = try? fileManager.contentsOfDirectory(atPath: fullPath) {
                print("📦 \(folder): \(backups.count) Backups")
}
}
} else {
        print("⚠️ Kein Backup-Ordner gefunden unter: \(backupRoot)")
}

    // 🔹 Pfade aus serverbackup.txt anzeigen
    print("\n📄 Pfade in serverbackup.txt:")
    if let fileContents = try? String(contentsOfFile: configPath, encoding:.utf8) {
        let lines = fileContents
.split(separator: "\n")
.map { String($0).trimmingCharacters(in:.whitespacesAndNewlines)}
.filter {!$0.isEmpty && !$0.hasPrefix("#")}

        for path in lines {
            print("🔹 \(path)")
}
} else {
        print("⚠️ Datei serverbackup.txt nicht gefunden.")
}

    exit(0)
}


    // 🔹 Setup: Textdatei & Launch Agent
// 🔹 Backup-Ordner sicherstellen
    if !fileManager.fileExists(atPath: backupRoot) {
        try? fileManager.createDirectory(atPath: backupRoot, withIntermediateDirectories: true)
    }

    if !fileManager.fileExists(atPath: configPath) {
        try? "### Trage hier deine Backup-Pfade ein um das komplette backup zurückzusetzen führe den McServerBackup mit argument -uninstall aus\n".write(toFile: configPath, atomically: true, encoding:.utf8)
        print("📄 Erstellt: \(configPath)")
    }

    if !fileManager.fileExists(atPath: agentPlistPath) {
        let plistContent = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key>
            <string>\(agentLabel)</string>
            <key>ProgramArguments</key>
            <array>
                <string>/usr/bin/swift</string>
                <string>\(scriptPath)</string>
            </array>
            <key>StartInterval</key>
            <integer>1800</integer>
            <key>RunAtLoad</key>
            <true/>
        </dict>
        </plist>
        """
        try? plistContent.write(toFile: agentPlistPath, atomically: true, encoding:.utf8)
        print("⚙️ Launch Agent erstellt: \(agentPlistPath)")

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        task.arguments = ["load", agentPlistPath]
        try? task.run()
        task.waitUntilExit()
        print("🚀 Launch Agent aktiviert")
    }

    // 🔹 Backup ausführen
    guard let fileContents = try? String(contentsOfFile: configPath, encoding:.utf8) else {
        print("❌ Fehler: Kann Datei nicht lesen: \(configPath)")
        exit(1)
    }

    let folderPaths = fileContents
    .split(separator: "\n")
    .map { String($0).trimmingCharacters(in:.whitespacesAndNewlines)}
    .filter {!$0.isEmpty && !$0.hasPrefix("#")}


    guard !folderPaths.isEmpty else {
        print("⚠️ Keine gültigen Pfade gefunden in serverbackup.txt")
        exit(0)
    }

    let timestamp = ISO8601DateFormatter().string(from: Date())

    for sourcePath in folderPaths {
        let folderName = URL(fileURLWithPath: sourcePath).lastPathComponent
        let backupFolder = "\(backupRoot)/\(folderName)"
        let destinationPath = "\(backupFolder)/backup_\(timestamp)"

        do {
            try fileManager.createDirectory(atPath: backupFolder, withIntermediateDirectories: true)
            try fileManager.copyItem(atPath: sourcePath, toPath: destinationPath)
            print("✅ Backup erstellt: \(destinationPath)")

            let contents = try fileManager.contentsOfDirectory(atPath: backupFolder)
    .filter { $0.hasPrefix("backup_")}
    .sorted()

            if contents.count > 3 {
                let backupsToDelete = contents.prefix(contents.count - 3)
                for oldBackup in backupsToDelete {
                    let fullPath = "\(backupFolder)/\(oldBackup)"
                    try fileManager.removeItem(atPath: fullPath)
                    print("🗑️ Gelöscht: \(fullPath)")
    }
    }

    } catch {
        print("❌ Fehler bei \(sourcePath): \(error)")
    }
    }

    if CommandLine.arguments.count == 1 {
        print("""
    ✅ Einrichtung abgeschlossen!

    👉 Öffne die Datei:
    \(configPath)

    und trage dort die Pfade zu deinen Minecraft-Server-Ordnern ein – jeweils eine Zeile pro Ordner.

    Ab jetzt wird alle 30 Minuten automatisch ein Backup erstellt – pro Pfad in einem eigenen Ordner.
    """)
    }
