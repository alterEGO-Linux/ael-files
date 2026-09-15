import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets

// PipeWire audio control for a bottom Quickshell panel.
//
// The popup has two pages:
//   status  -> master volume, mute, and current output information
//   outputs -> available audio output devices
Item {
    id: root

    required property var barWindow
    property int popupMargin: 12
    property string page: "status"

    width: 30
    height: 30

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink?.audio ?? null
    readonly property real volume: audio?.volume ?? 0
    readonly property bool muted: audio?.muted ?? true

    // Hardware audio sinks only. Streams such as Firefox and mpv are omitted.
    readonly property var outputDevices: Pipewire.nodes.values.filter(node =>
        node.audio !== null && node.isSink && !node.isStream
    )

    function setVolume(value) {
        if (!root.audio)
            return

        root.audio.volume = Math.max(0, Math.min(1, value))

        if (root.audio.muted && value > 0)
            root.audio.muted = false
    }

    function volumeIcon() {
        if (!root.sink || root.muted)
            return "audio-volume-muted-symbolic"
        if (root.volume < 0.34)
            return "audio-volume-low-symbolic"
        if (root.volume < 0.67)
            return "audio-volume-medium-symbolic"
        return "audio-volume-high-symbolic"
    }

    // Binding PipeWire objects makes their full properties available and keeps
    // volume/mute changes synchronized with the server.
    PwObjectTracker {
        objects: [root.sink]
    }

    Rectangle {
        anchors.fill: parent
        radius: 7

        color: buttonMouse.containsMouse || popup.visible
            ? "#3a3e4b"
            : "transparent"

        IconImage {
            anchors.centerIn: parent
            implicitSize: Appearance.iconSize
            source: Quickshell.iconPath(root.volumeIcon(), true)
        }

        MouseArea {
            id: buttonMouse
            anchors.fill: parent
            hoverEnabled: true

            onClicked: popup.visible = !popup.visible

            onWheel: wheel => {
                root.setVolume(root.volume + (wheel.angleDelta.y > 0 ? 0.05 : -0.05))
                wheel.accepted = true
            }
        }
    }

    PopupWindow {
        id: popup

        implicitWidth: 360
        implicitHeight: 410

        visible: false
        color: "transparent"
        grabFocus: true

        // Directly above the bar and flush with the screen's right edge.
        anchor.window: root.barWindow
        anchor.rect.x: root.barWindow.width
        anchor.rect.y: 0
        anchor.edges: Edges.Top | Edges.Right
        anchor.gravity: Edges.Top | Edges.Left

        onVisibleChanged: {
            if (!visible)
                root.page = "status"
        }

        Rectangle {
            anchors.fill: parent
            radius: 10
            color: "#ff1b1d24"
            border.color: "#3a3e4b"

            Loader {
                anchors.fill: parent
                anchors.margins: root.popupMargin

                sourceComponent: root.page === "outputs"
                    ? outputDevicesPage
                    : audioStatusPage
            }
        }
    }

    Component {
        id: audioStatusPage

        ColumnLayout {
            spacing: 10

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Audio"
                    color: "#f4f4f5"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: root.muted ? "Muted" : Math.round(root.volume * 100) + "%"
                    color: root.muted ? "#aeb3c2" : "#8bd49c"
                }

                Rectangle {
                    width: 42
                    height: 22
                    radius: 11
                    color: !root.muted ? "#4f8f65" : "#494d59"
                    enabled: root.audio !== null

                    Rectangle {
                        width: 18
                        height: 18
                        radius: 9
                        y: 2
                        x: !root.muted ? 22 : 2
                        color: "#f4f4f5"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.audio.muted = !root.audio.muted
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#3a3e4b" }

            Text {
                text: "Volume"
                color: "#aeb3c2"
                font.pixelSize: 11
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                IconImage {
                    implicitSize: 18
                    source: Quickshell.iconPath(root.volumeIcon(), true)
                }

                Rectangle {
                    id: volumeTrack
                    Layout.fillWidth: true
                    Layout.preferredHeight: 6
                    radius: 3
                    color: "#494d59"

                    Rectangle {
                        width: parent.width * Math.min(root.volume, 1)
                        height: parent.height
                        radius: 3
                        color: "#8bd49c"
                    }

                    Rectangle {
                        width: 16
                        height: 16
                        radius: 8
                        y: -5
                        x: Math.max(0, Math.min(parent.width - width,
                            parent.width * Math.min(root.volume, 1) - width / 2))
                        color: "#f4f4f5"
                    }

                    MouseArea {
                        anchors.fill: parent
                        anchors.topMargin: -10
                        anchors.bottomMargin: -10

                        function updateVolume(mouseX) {
                            root.setVolume(mouseX / volumeTrack.width)
                        }

                        onPressed: mouse => updateVolume(mouse.x)
                        onPositionChanged: mouse => {
                            if (pressed)
                                updateVolume(mouse.x)
                        }
                    }
                }

                Text {
                    Layout.preferredWidth: 38
                    horizontalAlignment: Text.AlignRight
                    text: Math.round(root.volume * 100) + "%"
                    color: "#f4f4f5"
                }
            }

            Text {
                text: "Current output"
                color: "#aeb3c2"
                font.pixelSize: 11
            }

            Text {
                Layout.fillWidth: true
                text: root.sink?.description || root.sink?.nickname || "No audio output"
                color: "#f4f4f5"
                font.pixelSize: 18
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 14
                rowSpacing: 7

                Text { text: "Device"; color: "#aeb3c2" }
                Text {
                    Layout.fillWidth: true
                    text: root.sink?.name || "—"
                    color: "#f4f4f5"
                    elide: Text.ElideRight
                }

                Text { text: "Channels"; color: "#aeb3c2" }
                Text {
                    text: root.audio ? root.audio.channels.length : "—"
                    color: "#f4f4f5"
                }

                Text { text: "State"; color: "#aeb3c2" }
                Text {
                    text: !root.sink ? "Unavailable" : root.muted ? "Muted" : "Active"
                    color: root.sink && !root.muted ? "#8bd49c" : "#f4f4f5"
                }
            }

            Item { Layout.fillHeight: true }

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: -root.popupMargin
                Layout.rightMargin: -root.popupMargin
                Layout.preferredHeight: 38
                color: outputsMouse.containsMouse ? "#3a3e4b" : "#292c35"

                Text {
                    anchors.centerIn: parent
                    text: "Output devices"
                    color: "#f4f4f5"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }

                MouseArea {
                    id: outputsMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.page = "outputs"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: -root.popupMargin
                Layout.rightMargin: -root.popupMargin
                Layout.bottomMargin: -root.popupMargin
                Layout.preferredHeight: 38
                color: settingsMouse.containsMouse ? "#3a3e4b" : "#292c35"

                Text {
                    anchors.centerIn: parent
                    text: "Sound Settings"
                    color: "#f4f4f5"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }

                MouseArea {
                    id: settingsMouse
                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: {
                        popup.visible = false
                        Quickshell.execDetached({ command: ["pavucontrol"] })
                    }
                }
            }
        }
    }

    Component {
        id: outputDevicesPage

        ColumnLayout {
            spacing: 8

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 34
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.rightMargin: 10

                    Text {
                        Layout.fillWidth: true
                        text: "Output devices"
                        color: "#f4f4f5"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                    }

                    IconImage {
                        implicitWidth: 16
                        implicitHeight: 16
                        source: Qt.resolvedUrl("icons/close.svg")
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.page = "status"
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#3a3e4b" }

            ListView {
                id: outputList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 3
                model: root.outputDevices

                delegate: Rectangle {
                    id: outputRow
                    required property var modelData

                    width: outputList.width
                    height: 50
                    radius: 7
                    color: outputMouse.containsMouse ? "#343844" : "transparent"

                    PwObjectTracker {
                        objects: [outputRow.modelData]
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8

                        IconImage {
                            implicitSize: 18
                            source: Quickshell.iconPath(
                                outputRow.modelData === root.sink
                                    ? "audio-card-symbolic"
                                    : "audio-speakers-symbolic",
                                true
                            )
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                Layout.fillWidth: true
                                text: outputRow.modelData.description
                                    || outputRow.modelData.nickname
                                    || outputRow.modelData.name
                                color: "#f4f4f5"
                                elide: Text.ElideRight
                            }

                            Text {
                                text: outputRow.modelData === root.sink
                                    ? "Current output"
                                    : "Available"
                                color: outputRow.modelData === root.sink
                                    ? "#8bd49c"
                                    : "#aeb3c2"
                                font.pixelSize: 10
                            }
                        }

                        Text {
                            text: outputRow.modelData.audio
                                ? Math.round(outputRow.modelData.audio.volume * 100) + "%"
                                : ""
                            color: "#aeb3c2"
                        }
                    }

                    MouseArea {
                        id: outputMouse
                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            Pipewire.preferredDefaultAudioSink = outputRow.modelData
                            root.page = "status"
                        }
                    }
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                visible: root.outputDevices.length === 0
                text: "No audio output found"
                color: "#aeb3c2"
            }
        }
    }
}
