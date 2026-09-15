import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

Item {
    id: root
    required property var barWindow
    width: 30
    height: 30

    Rectangle {
        anchors.fill: parent
        radius: 7
        color: buttonMouse.containsMouse || delayPopup.visible ? "#3a3e4b" : "transparent"

        IconImage {
            anchors.centerIn: parent
            implicitSize: Appearance.iconSize
            source: Qt.resolvedUrl("icons/screenshot.svg")
            visible: ScreenshotService.countdown === 0
        }

        Text {
            anchors.centerIn: parent
            visible: ScreenshotService.countdown > 0
            text: ScreenshotService.countdown
            color: "#f4f4f5"
            font.pixelSize: 15
            font.weight: Font.Bold
        }

        MouseArea {
            id: buttonMouse
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) {
                    delayPopup.visible = false
                    ScreenshotService.takeScreenshot(root.barWindow.screen.name)
                } else {
                    delayPopup.visible = !delayPopup.visible
                }
            }
        }
    }

    PopupWindow {
        id: delayPopup
        implicitWidth: 250
        implicitHeight: 184
        visible: false
        color: "transparent"
        grabFocus: true
        anchor.window: root.barWindow
        anchor.rect.x: root.barWindow.width
        anchor.rect.y: 0
        anchor.edges: Edges.Top | Edges.Right
        anchor.gravity: Edges.Top | Edges.Left

        Rectangle {
            anchors.fill: parent
            radius: 10
            color: "#ff1b1d24"
            border.color: "#3a3e4b"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Text {
                    text: "Screenshot delay"
                    color: "#f4f4f5"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                }

                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: "#3a3e4b" }

                Repeater {
                    model: [0, 3, 5, 10]
                    Rectangle {
                        required property int modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: 26
                        radius: 5
                        color: delayMouse.containsMouse || ScreenshotService.delaySeconds === modelData ? "#3a3e4b" : "transparent"

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            text: parent.modelData === 0 ? "No delay" : parent.modelData + " seconds"
                            color: "#f4f4f5"
                            font.pixelSize: 13
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            visible: ScreenshotService.delaySeconds === parent.modelData
                            text: "✓"
                            color: "#8bd49c"
                            font.pixelSize: 14
                        }

                        MouseArea {
                            id: delayMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                ScreenshotService.delaySeconds = parent.modelData
                                delayPopup.visible = false
                            }
                        }
                    }
                }
            }
        }
    }
}
