//  McServerLuncher(No Cheats)
//
//  Created by Hannes Müller on 01.08.25.
//

import Foundation

let args = CommandLine.arguments

// 🔹 Standardwerte
var ram = "2"
var jarPath = ""
var workingDirectory: String?

// 🔹 Argumente parsen
var i = 1
while i < args.count {
    switch args[i] {
    case "-ram":
        if i + 1 < args.count { ram = args[i + 1]; i += 1}
    case "-jar":
        if i + 1 < args.count { jarPath = args[i + 1]; i += 1}
    case "-cd":
        if i + 1 < args.count { workingDirectory = args[i + 1]; i += 1}
    default: break
}
    i += 1
}

// 🔍 Validierung
guard !jarPath.isEmpty else {
    print("❌ Fehler: -jar <Pfad> fehlt")
    exit(1)
}

// 🔹 Server-Prozess vorbereiten
let task = Process()
task.executableURL = URL(fileURLWithPath: "/usr/bin/java")
task.arguments = ["-Xmx\(ram)G", "-Xms\(ram)G", "-jar", jarPath, "nogui"]

// 🔹 Arbeitsverzeichnis setzen
if let cd = workingDirectory {
    task.currentDirectoryURL = URL(fileURLWithPath: cd)
} else {
    let jarURL = URL(fileURLWithPath: jarPath)
    task.currentDirectoryURL = jarURL.deletingLastPathComponent()
}

// 🔹 Pipes für Log und Eingabe
let outputPipe = Pipe()
let inputPipe = Pipe()
task.standardOutput = outputPipe
task.standardError = outputPipe
task.standardInput = inputPipe

do {
    try task.run()
    print("🟢 Server gestartet mit \(ram) GB RAM")

    // 🔹 Loganzeige
    DispatchQueue.global().async {
        let handle = outputPipe.fileHandleForReading
        while true {
            let data = handle.availableData
            if data.isEmpty { break}
            if let line = String(data: data, encoding:.utf8) {
                print("\(line)", terminator: "")
}
}
}

    // 🔹 Eingabe mit erlaubten Befehlen
    let erlaubteBefehle = ["stop", "say", "save-all", "reload"]
    let inputHandle = inputPipe.fileHandleForWriting
    while task.isRunning {
        print("Eingabe (erlaubt: \(erlaubteBefehle.joined(separator: ", "))):")
        if let eingabe = readLine(), erlaubteBefehle.contains(where: { eingabe.hasPrefix($0)}) {
            if let data = (eingabe + "\n").data(using:.utf8) {
                inputHandle.write(data)
}
} else {
            print("❌ Ungültiger Befehl")
}
}

    print("✅ Server beendet")

} catch {
    print("❌ Fehler beim Starten: \(error)")
}

