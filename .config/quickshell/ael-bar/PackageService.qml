pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: service

    property string aurHelper: "paru"

    property var updates: []
    property var pendingPacmanUpdates: []

    property bool checking: false
    property string statusMessage: "Checking for updates…"

    readonly property int updateCount: updates.length

    function parseUpdates(output, source) {
        const packages = []

        for (const line of output.trim().split("\n")) {
            const match = line.trim().match(
                /^(\S+)\s+(\S+)\s+->\s+(\S+)$/
            )

            if (match) {
                packages.push({
                    name: match[1],
                    oldVersion: match[2],
                    newVersion: match[3],
                    source: source
                })
            }
        }

        return packages
    }

    function refresh() {
        if (checking)
            return

        checking = true
        statusMessage = "Checking for updates…"

        // Do not modify `updates` while checking.
        pacmanProcess.exec([
            "sh",
            "-c",
            "if ! command -v checkupdates >/dev/null 2>&1; then "
                + "printf '__AEL_ERROR__checkupdates is not installed'; "
                + "exit 0; "
                + "fi; "
                + "checkupdates 2>/dev/null; code=$?; "
                + "[ $code -eq 0 ] || [ $code -eq 2 ]"
        ])
    }

    Process {
        id: pacmanProcess

        stdout: StdioCollector {
            onStreamFinished: {
                if (text.startsWith("__AEL_ERROR__")) {
                    service.statusMessage = text.substring(13)
                    service.checking = false
                    return
                }

                service.pendingPacmanUpdates =
                    service.parseUpdates(text, "pacman")

                aurProcess.exec([
                    "sh",
                    "-c",
                    "if ! command -v "
                        + service.aurHelper
                        + " >/dev/null 2>&1; then "
                        + "printf '__AEL_ERROR__AUR helper not found: "
                        + service.aurHelper
                        + "'; exit 0; "
                        + "fi; "
                        + service.aurHelper
                        + " -Qua 2>/dev/null"
                ])
            }
        }
    }

    Process {
        id: aurProcess

        stdout: StdioCollector {
            onStreamFinished: {
                if (text.startsWith("__AEL_ERROR__")) {
                    // The check was incomplete. Preserve the previous list
                    // and therefore preserve the current icon.
                    service.statusMessage = text.substring(13)
                    service.checking = false
                    return
                }

                const aurUpdates =
                    service.parseUpdates(text, "AUR")

                // Publish exactly once, after the complete check.
                service.updates =
                    service.pendingPacmanUpdates.concat(aurUpdates)

                service.statusMessage =
                    service.updates.length === 0
                        ? "Your system is up to date"
                        : service.updates.length
                            + (service.updates.length === 1
                                ? " update available"
                                : " updates available")

                service.checking = false
            }
        }
    }

    Timer {
        interval: 1 * 60 * 1000
        repeat: true
        running: true
        triggeredOnStart: true

        onTriggered: service.refresh()
    }
}
