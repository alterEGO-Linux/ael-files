//@ pragma UseQApplication

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.SystemTray
import Quickshell.Widgets

ShellRoot {
    id: root

    ScreenshotPreview { }

    // One independent bar is created for every connected monitor.
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData

            screen: modelData
            color: "transparent"
            implicitHeight: 40
            exclusiveZone: implicitHeight

            anchors {
                left: true
                right: true
                bottom: true
            }

            Rectangle {
                anchors.fill: parent
                color: "#ff262626"
                border.color: "#404040"
                border.width: 1

                WindowsMenu {
                    barWindow: bar

                    anchors {
                        left: parent.left
                        leftMargin: 12
                        verticalCenter: parent.verticalCenter
                    }
                }

            Workspaces {
                anchors.centerIn: parent
                barWindow: bar
            }

                RowLayout {
                    anchors {
                        right: parent.right
                        rightMargin: 12
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 5

                    // [*] PiP
                    PiPButton {
                        barWindow: bar
                    }

                    // [*] Packages
                    Packages {
                        barWindow: bar
                    }

                    // [*] SystemMonitor
                    SystemMonitor {
                        barWindow: bar
                    }

                    // [*] Screenshot
                    ScreenshotButton {
                        barWindow: bar
                    }

                    // [+] AUDIO
                    AudioButton {
                        barWindow: bar
                    }

                    // --- Icon Tray.
                    NetworkButton {
                        barWindow: bar
                    }

                    BluetoothButton {
                        barWindow: bar
                    }

                    Repeater {
                        model: SystemTray.items

                        Rectangle {
                            id: trayButton
                            required property var modelData

                            readonly property bool suppressed: {
                                const identity = (modelData.id + " " + modelData.title).toLowerCase()
                                return identity.includes("nm-applet")
                                    || identity.includes("networkmanager")
                                    || identity.includes("blueman")
                            }

                            visible: !suppressed
                            Layout.preferredWidth: suppressed ? 0 : 30
                            Layout.preferredHeight: suppressed ? 0 : 30
                            radius: 7
                            color: mouseArea.containsMouse ? "#3a3e4b" : "transparent"

                            QsMenuAnchor {
                                id: trayMenu
                                menu: trayButton.modelData.menu
                                anchor.item: trayButton
                                anchor.edges: Edges.Top | Edges.Right
                                anchor.gravity: Edges.Top | Edges.Left
                            }

                            IconImage {
                                anchors.centerIn: parent
                                implicitSize: 18
                                source: trayButton.modelData.icon
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                                hoverEnabled: true

                                onClicked: mouse => {
                                    if (mouse.button === Qt.MiddleButton) {
                                        trayButton.modelData.secondaryActivate()
                                    } else if (trayButton.modelData.hasMenu) {
                                        if (trayMenu.visible)
                                            trayMenu.close()
                                        else
                                            trayMenu.open()
                                    } else if (mouse.button === Qt.LeftButton) {
                                        trayButton.modelData.activate()
                                    }
                                }

                                onWheel: wheel => {
                                    trayButton.modelData.scroll(wheel.angleDelta.y, false)
                                }
                            }

                        }
                    }

                    // [*] Clock
                    Column {
                        Layout.leftMargin: 8
                        Layout.alignment: Qt.AlignVCenter
                        spacing: -2

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Qt.formatDateTime(clock.date, "HH:mm")
                            color: "#f4f4f5"
                            font.pixelSize: 16
                            font.weight: Font.DemiBold
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Qt.formatDateTime(clock.date, "ddd, MMM d")
                            color: "#aeb3c2"
                            font.pixelSize: 10
                        }
                    }

                }
            }
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
