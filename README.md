⁠ markdown
# 🛠 MC Server Utilities

A macOS toolkit for managing Minecraft servers.
Includes tools for downloading, launching, backing up, and generating `.command` launch scripts.

---

## 📦 What's Included

- **McServerDownloader** – Download Vanilla or Forge server files
- **McServerLauncher_Cheats** – Launch server with cheats enabled
- **McServerLauncher_NoCheats** – Launch server without cheats
- **McServerBackup** – Automatically back up server worlds
- **McServerCommandCreator** – Generate `.command` files to launch servers with custom RAM and cheat settings

---

## 💻 Installation

Download the latest `.zip` release from the [Releases](https://github.com/HannAnto/McServerUtilities/releases).

Then:

1. Open the `.zip` file
2. Drag the **McServerUtilities** folder into your `/Applications` directory
3. Run the tools directly from there

---

## 🚀 Command Creator

To generate a launchable `.command` file:

1. Open `McServerCommandCreator`
2. Enter the path to your `server.jar`
3. Choose how much RAM to allocate (in GB)
4. Choose whether to enable cheats
5. A `.command` file will be created in the same folder as your server

You can double-click the `.command` file to launch your server with the selected settings.
It’s the fastest way to start a new server.

---

## ▶️ Start a Server

You can start a server manually using `McServerLauncher_Cheats` or `McServerLauncher_NoCheats`.
Open Terminal and run the launcher with the following arguments:

 ⁠bash
./McServerLauncher_NoCheats -jar /path/to/server.jar -ram 4 -cd /path/to/server/folder


Replace the paths and RAM value with your actual setup.

---

*⬇️ Download a Server*

To download a new Minecraft server (Vanilla or Forge), use `McServerDownloader`.
It guides you through:

- Selecting server type: Vanilla or Forge
- Choosing Forge version (e.g. 1.20.1 or 1.21.8)
- Automatically downloading the correct `.jar` file
- Creating a new folder like `NewServer`, `NewServer 2`, etc.
- Saving the server as `server.jar` in the appropriate location

This tool ensures a clean and organized setup for each server instance.

---

*📁 Backups*

The McServerBackup tool handles automatic and manual backups of your Minecraft server worlds.

🛠 First-Time Setup

On first launch, everything is set up automatically.
To configure which servers should be backed up, add their folder paths (one per line) to:


~/Documents/McServerBackups/serverbackup.txt


🔁 Automatic Backups

A launch agent runs in the background and creates backups every 30 minutes for all listed paths.
Backups are stored in:


~/Documents/McServerBackups


🖱️ Manual Backups

You can also double-click the backup tool at any time to trigger an instant backup.

---

📊 ⁠ -status ⁠

Use this flag to check the current backup status:

•⁠  ⁠Lists all active server paths from ⁠ serverbackup.txt ⁠
•⁠  ⁠Shows the timestamp of the last successful backup
•⁠  ⁠Confirms whether the launch agent is running correctly

---

🧹 ⁠ -uninstall ⁠

Use this flag to remove the backup system:

•⁠  ⁠Deletes the ⁠ serverbackup.txt ⁠ configuration file
•⁠  ⁠Uninstalls the launch agent responsible for automatic backups

This will fully disable automated backups and clean up related files.

---


*🧊 Releases*

Each release includes:

- Compiled tools (Unix executables)
- Optional `.command` launchers
- Version notes and changelogs

---

*🧠 Requirements*

- macOS 12 or later
- Java installed (`java -version`)
- Internet connection for downloads

---

*📬 Feedback & Contributions*

Feel free to open issues or suggest features.
Maintained by [@HannAnto](https://github.com/HannAnto).

---

*📜 License*

This project is released under the MIT License.
