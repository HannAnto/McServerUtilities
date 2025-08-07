//  McServerDownloader
//
//  Created by Hannes Müller on 01.08.25.
//
import Foundation

let fileManeger = FileManager.default
var launcherPath = ""

print("Start Command Creator")
print("Pfad zur server.jar eingeben:")
guard let jar = readLine(), fileManeger.fileExists(atPath: jar) else {
    print("Datei nicht gefunden")
    exit(1)
}
print("Wie viel Ram soll zugewiesen werden? z.b. 1,2,3,4,5...")
guard let ramInput = readLine(), let ram = Int(ramInput), ram > 0 else {
    print("❌ Ungültige RAM-Angabe.")
    exit(1)
}

print("Cheats aktivieren J/N")
let antwort = readLine()
if antwort == "J"{
    launcherPath = "/Applications/McServerUtilities/Unix/McServerLuncher_Cheats"
}
if antwort == "N"{
    launcherPath = "/Applications/McServerUtilities/Unix/McServerLuncher_NoCheats"
}
let jarURL = URL(fileURLWithPath: jar)
let workingDir = jarURL.deletingLastPathComponent().path

let commandContent = """
#!/bin/bash
\(launcherPath) -jar \(jar) -ram \(ram) -cd \(workingDir)
"""
let commandPath = "\(workingDir)/StartServer.command"
do {
    try commandContent.write(toFile: commandPath, atomically: true, encoding:.utf8)
    try fileManeger.setAttributes([.posixPermissions: 0o755], ofItemAtPath: commandPath)
    print("✅ Startskript erstellt: \(commandPath)")
    print("📦 Du kannst es jetzt per Doppelklick starten.")
} catch {
    print("❌ Fehler beim Schreiben der Datei: \(error)")
    exit(1)
}

