import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

Item {
    id: root
    width: 30
    height: 30

    required property var barWindow
    property bool menuOpen: false

    Rectangle {
        anchors.fill: parent
        radius: 7
        color: mouse.containsMouse || root.menuOpen ? "#3a3e4b" : "transparent"

        IconImage {
            anchors.centerIn: parent
            implicitSize: Appearance.iconSize
            source: Qt.resolvedUrl(MediaDownloadService.state === "error"
                ? "icons/media-download-red.svg"
                : "icons/media-download.svg")
            opacity: MediaDownloadService.busy ? 0.55 : 1
        }

        Canvas {
            id: progressCanvas
            anchors.centerIn: parent
            width: Appearance.iconSize + 6
            height: width
            visible: MediaDownloadService.state === "downloading"
            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                ctx.strokeStyle = "#72f1b8"
                ctx.lineWidth = 2
                ctx.beginPath()
                ctx.arc(width / 2, height / 2, width / 2 - 1,
                        -Math.PI / 2,
                        -Math.PI / 2 + Math.PI * 2 * MediaDownloadService.progress / 100)
                ctx.stroke()
            }
            Connections {
                target: MediaDownloadService
                function onProgressChanged() { progressCanvas.requestPaint() }
            }
        }

        Rectangle {
            id: activityIndicator
            anchors.centerIn: parent
            width: Appearance.iconSize + 6
            height: width
            radius: width / 2
            color: "transparent"
            border.width: 2
            border.color: "#e5c890"
            visible: MediaDownloadService.state === "inspecting"
                     || MediaDownloadService.state === "awaiting_confirmation"

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                width: 5
                height: 5
                radius: 2.5
                color: "#e5c890"
            }

            RotationAnimation on rotation {
                running: activityIndicator.visible
                         && MediaDownloadService.state === "inspecting"
                loops: Animation.Infinite
                from: 0
                to: 360
                duration: 850
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: event => {
                if (event.button === Qt.LeftButton) MediaDownloadService.download()
                else root.menuOpen = !root.menuOpen
            }
        }
    }

    PopupWindow {
        id: popup

        implicitWidth: Appearance.popupWindowWidth
        implicitHeight: Appearance.popupWindowHeight

        visible: root.menuOpen
        color: "transparent"
        grabFocus: true

        anchor.window: root.barWindow
        anchor.rect.x: root.barWindow.width
        anchor.rect.y: 0
        anchor.edges: Edges.Top | Edges.Right
        anchor.gravity: Edges.Top | Edges.Left

        onVisibleChanged: {
            if (visible)
                root.refresh()
        }

        Rectangle {
            anchors.fill: parent

            topLeftRadius: Appearance.popupWindowRectTLRadius
            topRightRadius: Appearance.popupWindowRectTRRadius
            bottomLeftRadius: Appearance.popupWindowRectBLRadius
            bottomRightRadius: Appearance.popupWindowRectBRRadius
            color: Appearance.backgroundColor
            border.color: Appearance.borderColor

            ColumnLayout {
                id: content
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Label { text: "AEL//MediaDownloader"; color: "#d7fbe9"; font.bold: true }
                Label {
                    Layout.fillWidth: true
                    text: MediaDownloadService.title || MediaDownloadService.message
                    color: "#9bb8aa"
                    elide: Text.ElideRight
                }
                ProgressBar {
                    Layout.fillWidth: true
                    visible: MediaDownloadService.state === "downloading"
                    value: MediaDownloadService.progress / 100
                }
                RowLayout {
                    Label { text: "Format"; color: "#d7fbe9" }
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["Video", "Audio"]
                        currentIndex: MediaDownloadService.mode === "audio" ? 1 : 0
                        onActivated: MediaDownloadService.mode = currentIndex === 1 ? "audio" : "video"
                    }
                }
                RowLayout {
                    Label { text: "Quality"; color: "#d7fbe9" }
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["Best", "1080p", "720p"]
                        onActivated: MediaDownloadService.quality = ["best", "1080", "720"][currentIndex]
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Button {
                        Layout.fillWidth: true
                        text: MediaDownloadService.state === "inspecting"
                            ? "Reading browser…"
                            : MediaDownloadService.state === "awaiting_confirmation"
                                ? "Waiting for confirmation…"
                                : MediaDownloadService.state === "downloading"
                                    ? "Downloading " + MediaDownloadService.progress + "%"
                                    : "Download focused media"
                        enabled: !MediaDownloadService.busy
                        onClicked: MediaDownloadService.download()
                    }
                    Button {
                        visible: MediaDownloadService.state === "downloading"
                        text: "Cancel"
                        onClicked: MediaDownloadService.cancel()
                    }
                }
                Label {
                    Layout.fillWidth: true
                    text: "Focused browser tab → clipboard fallback"
                    color: "#6e8f82"
                    font.pixelSize: 11
                }
            }
        }
    }
}
