pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property string state: "idle"
    property int progress: 0
    property string title: ""
    property string message: "Ready"
    property string mode: "video"
    property string quality: "best"

    readonly property bool busy:
        state === "inspecting"
        || state === "awaiting_confirmation"
        || state === "downloading"

    readonly property string helper:
        Qt.resolvedUrl("scripts/ael-media-download")
            .toString().replace("file://", "")

    function download() {
        if (busy || requestProcess.running)
            return

        state = "inspecting"
        progress = 0
        title = ""
        message = "Reading the focused browser tab"

        requestProcess.exec([
            "bash",
            helper,
            "request",
            "--mode",
            mode,
            "--quality",
            quality
        ])

        statePoll.start()
    }

    function cancel() {
        if (!cancelProcess.running)
            cancelProcess.exec(["bash", helper, "cancel"])
    }

    function refresh() {
        if (!statusProcess.running)
            statusProcess.exec(["bash", helper, "status"])
    }

    property Process requestProcess: Process {
        onExited: {
            statePoll.start()
            root.refresh()
        }
    }

    property Process cancelProcess: Process {
        onExited: root.refresh()
    }

    property Process statusProcess: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text)

                    root.state = data.state || "idle"
                    root.progress = data.progress || 0
                    root.title = data.title || ""
                    root.message = data.message || "Ready"

                    if (!root.busy && !requestProcess.running)
                        statePoll.stop()
                } catch (error) {
                    root.state = "error"
                    root.message = "Invalid downloader status"

                    if (!requestProcess.running)
                        statePoll.stop()
                }
            }
        }
    }

    property Timer statePoll: Timer {
        interval: 500
        repeat: true
        running: false
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: refresh()
}
