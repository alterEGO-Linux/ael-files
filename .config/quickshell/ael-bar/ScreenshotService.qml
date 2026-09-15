pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int delaySeconds: 0
    property int countdown: 0
    property bool capturing: false
    property bool previewVisible: false
    property string previewPath: "/tmp/ael-screenshot-preview.png"
    property string previewUrl: ""
    property string requestedOutput: ""
    property string statusMessage: ""
    property string savedPath: ""

    function takeScreenshot(outputName) {
        if (capturing)
            return

        requestedOutput = outputName || ""
        savedPath = ""
        statusMessage = ""
        capturing = true
        countdown = delaySeconds

        if (countdown > 0)
            countdownTimer.start()
        else
            captureNow()
    }

    function captureNow() {
        countdownTimer.stop()
        countdown = 0

        const args = ["grim"]
        if (requestedOutput.length > 0)
            args.push("-o", requestedOutput)
        args.push(previewPath)
        captureProcess.exec(args)
    }

    function save() {
        if (!previewVisible || saveProcess.running)
            return

        statusMessage = "Saving…"
        saveProcess.exec([
            "sh", "-c",
            "dir=\"${XDG_SCREENSHOTS_DIR:-${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots}\"; "
            + "mkdir -p \"$dir\" && "
            + "file=\"$dir/AEL-Screenshot-$(date +%Y-%m-%d_%H-%M-%S).png\" && "
            + "cp -- \"$1\" \"$file\" && printf '%s' \"$file\"",
            "ael-screenshot-save", previewPath
        ])
    }

    function openInGimp() {
        if (previewVisible)
            Quickshell.execDetached(["gimp", previewPath])
    }

    function discard() {
        previewVisible = false
        statusMessage = ""
        Quickshell.execDetached(["rm", "-f", previewPath])
    }

    Timer {
        id: countdownTimer
        interval: 1000
        repeat: true
        onTriggered: {
            root.countdown--
            if (root.countdown <= 0)
                root.captureNow()
        }
    }

    Process {
        id: captureProcess
        onExited: exitCode => {
            root.capturing = false
            if (exitCode === 0) {
                root.previewUrl = "file://" + root.previewPath + "?v=" + Date.now()
                root.previewVisible = true
            } else {
                root.statusMessage = "Capture failed — is grim installed?"
            }
        }
    }

    Process {
        id: saveProcess
        stdout: StdioCollector {
            onStreamFinished: {
                root.savedPath = text
                root.statusMessage = text.length > 0 ? "Saved to " + text : "Save failed"
            }
        }
        onExited: exitCode => {
            if (exitCode !== 0)
                root.statusMessage = "Save failed"
        }
    }
}
