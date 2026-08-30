import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Widgets

Item {
    id: root

    required property var barWindow
    property int popupMargin: 12

    width: 30
    height: 30

    property var adapter: Bluetooth.defaultAdapter

    Rectangle {
        anchors.fill: parent
        radius: 7
        color: mouse.containsMouse || popup.visible ? "#3a3e4b" : "transparent"

        IconImage {
            anchors.centerIn: parent
            implicitSize: Appearance.iconSize
            source: Quickshell.iconPath(
                root.adapter?.enabled ? "bluetooth-active-symbolic" : "bluetooth-disabled-symbolic",
                true
            )
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: popup.visible = !popup.visible
        }
    }

    PopupWindow {
        id: popup

        implicitWidth: 340
        implicitHeight: 410

        visible: false
        color: "transparent"
        grabFocus: true

        // --- Position directly above the bar and flush with
        // ... the screen's right edge.
        anchor.window: root.barWindow
        anchor.rect.x: root.barWindow.width
        anchor.rect.y: 0
        anchor.edges: Edges.Top | Edges.Right
        anchor.gravity: Edges.Top | Edges.Left

        onVisibleChanged: {
            if (root.adapter && root.adapter.enabled)
                root.adapter.discovering = visible
        }

        Rectangle {
            anchors.fill: parent

            radius: 10
            color: "#ff1b1d24"
            border.color: "#3a3e4b"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: root.popupMargin
                spacing: 0

                // +----------------------------------------------------------+
                // [+] TOP SECTION
                // +----------------------------------------------------------+
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Bluetooth"
                        color: "#f4f4f5"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                    }

                    Item { Layout.fillWidth: true }

                    // --- Switch ON/OFF
                    Text {
                        text: root.adapter?.enabled ? "On" : "Off"
                        color: root.adapter?.enabled ? "#8bd49c" : "#aeb3c2"
                    }

                    Rectangle {
                        width: 42
                        height: 22
                        radius: 11
                        color: root.adapter?.enabled ? "#4f8f65" : "#494d59"
                        enabled: root.adapter !== null

                        Rectangle {
                            width: 18
                            height: 18
                            radius: 9
                            y: 2
                            x: root.adapter?.enabled ? 22 : 2
                            color: "#f4f4f5"
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.adapter.enabled = !root.adapter.enabled
                        }
                    }
                }

                Text {
                    visible: root.adapter?.discovering ?? false
                    text: "Scanning for devices…"
                    color: "#aeb3c2"
                    font.pixelSize: 11
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#3a3e4b" }

                // +----------------------------------------------------------+
                // [+] LIST VIEW
                // +----------------------------------------------------------+
                ListView {
                    id: deviceList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 3
                    model: root.adapter?.devices ?? null

                    delegate: Rectangle {
                        id: deviceRow
                        required property var modelData
                        width: deviceList.width
                        height: 46
                        //radius: 7
                        color: deviceMouse.containsMouse ? "#343844" : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8

                            IconImage {
                                implicitSize: 18
                                source: Quickshell.iconPath(deviceRow.modelData.icon, true)
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                Text {
                                    Layout.fillWidth: true
                                    text: deviceRow.modelData.name
                                    elide: Text.ElideRight
                                    color: "#f4f4f5"
                                }

                                Text {
                                    text: deviceRow.modelData.connected ? "Connected"
                                          : deviceRow.modelData.pairing ? "Pairing…"
                                          : deviceRow.modelData.paired ? "Paired" : "Available"
                                    color: deviceRow.modelData.connected ? "#8bd49c" : "#aeb3c2"
                                    font.pixelSize: 10
                                }
                            }

                            Text {
                                visible: deviceRow.modelData.batteryAvailable
                                text: Math.round(deviceRow.modelData.battery * 100) + "%"
                                color: "#aeb3c2"
                            }
                        }

                        MouseArea {
                            id: deviceMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                const device = deviceRow.modelData
                                if (device.connected)
                                    device.disconnect()
                                else if (device.paired)
                                    device.connect()
                                else
                                    device.pair()
                            }
                        }
                    }
                }

                // +----------------------------------------------------------+
                // [+] BLUEMAN-MANAGER
                // +----------------------------------------------------------+
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: -root.popupMargin
                    Layout.rightMargin: -root.popupMargin
                    Layout.preferredHeight: 38

                    color: bluemanMouse.containsMouse
                        ? "#3a3e4b"
                        : "#292c35"

                    Text {
                        anchors.centerIn: parent

                        text: "Bluetooth Manager"
                        color: "#f4f4f5"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        id: bluemanMouse

                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            popup.visible = false

                            Quickshell.execDetached({
                                command: ["blueman-manager"]
                            })
                        }
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    visible: !root.adapter
                    text: "No Bluetooth adapter found"
                    color: "#aeb3c2"
                }
            }
        }
    }
}
