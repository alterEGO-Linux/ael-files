// +--------------------------------------------------------------------------+
// [+] INFO
// +--------------------------------------------------------------------------+
// [/.config/quickshell/ael-bar/WindowsMenu.qml]
// 
// Author      : Pascal Malouin (https://github.com/alterEGO-Linux)
// Created     : 2026-08-25 09:41:05 UTC
// Updated     : 2026-08-25 09:41:05 UTC
// Description : Windows 10 mock menu.
// ---------------------------------------------------------------------------+

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland

Item {
    id: root

    required property var barWindow

    width: 30
    height: 30

    // Windows launcher button shown in the AEL bar.
    Rectangle {
        id: launcherButton

        anchors.fill: parent
        radius: 7

        color: launcherMouse.containsMouse
            ? "#3a3e4b"
            : "transparent"

        Image {
            anchors.centerIn: parent

            width: 19
            height: 19

            source: Qt.resolvedUrl("icons/windows.svg")
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
        }

        MouseArea {
            id: launcherMouse

            anchors.fill: parent
            hoverEnabled: false

            onClicked: {
                if (launcherPopup.visible) {
                    menuFocus.active = false
                    launcherPopup.visible = false
                } else {
                    launcherPopup.visible = true
                    menuFocus.active = true
                }
            }
        }
    }

    // Application menu displayed above the AEL bar.
    PopupWindow {
        id: launcherPopup

        implicitWidth: 390
        implicitHeight: 500

        visible: false
        color: "transparent"

        anchor.window: root.barWindow
        anchor.rect.x: 0
        anchor.rect.y: 0
        anchor.edges: Edges.Top | Edges.Left
        anchor.gravity: Edges.Top | Edges.Right

        Rectangle {
            anchors.fill: parent

            radius: 10
            color: "#ff1b1d24"
            border.color: "#3a3e4b"

            ListView {
                id: applicationList

                anchors.fill: parent
                anchors.margins: 10

                clip: true
                spacing: 0

                model: [
                    {
                        name: "Alacritty",
                        icon: "icons/alacritty.svg",
                        command: ["alacritty"]
                    },
                    {
                        name: "Firefox",
                        icon: "icons/firefox.svg",
                        command: ["firefox"]
                    },
                    {
                        name: "VLC",
                        icon: "icons/vlc.svg",
                        command: ["vlc"]
                    }
                ]

                delegate: Rectangle {
                    required property var modelData

                    width: applicationList.width
                    height: 38

                    color: itemMouse.containsMouse
                        ? "#3a3e4b"
                        : "#1b1d24"

                    Image {
                        anchors {
                            left: parent.left
                            leftMargin: 12
                            verticalCenter: parent.verticalCenter
                        }

                        width: 19
                        height: 19

                        source: Qt.resolvedUrl(modelData.icon)
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                    }

                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: 40
                            verticalCenter: parent.verticalCenter
                        }

                        text: modelData.name
                        color: "#f4f4f5"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        id: itemMouse

                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            menuFocus.active = false
                            launcherPopup.visible = false

                            Quickshell.execDetached({
                                command: modelData.command
                            })
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }
            }

        }
    }

    // Close the menu when the user clicks outside it.
    HyprlandFocusGrab {
        id: menuFocus

        windows: [launcherPopup]

        onCleared: {
            launcherPopup.visible = false
        }
    }

    // Close the menu when Escape is pressed.
    Shortcut {
        enabled: launcherPopup.visible
        sequence: "Escape"
        context: Qt.ApplicationShortcut

        onActivated: {
            menuFocus.active = false
            launcherPopup.visible = false
        }
    }
}
