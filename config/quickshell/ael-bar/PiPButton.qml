import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

Item {
    id: root

    required property var barWindow
    property int popupMargin: 12

    width: 30
    height: 30
    visible: PiPService.available

    component ActionButton: Rectangle {
        id: action
        property string label: ""
        property color labelColor: "#f4f4f5"
        property bool selected: false
        signal clicked()

        Layout.fillWidth: true
        Layout.preferredHeight: 38
        radius: 7
        color: actionMouse.containsMouse ? "#3a3e4b" : "#30333d"
        border.color: selected ? "#8bd49c" : "transparent"

        Text {
            anchors.centerIn: parent
            text: action.label
            color: action.selected ? "#8bd49c" : action.labelColor
            font.weight: Font.DemiBold
        }

        MouseArea {
            id: actionMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: action.clicked()
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 7
        color: buttonMouse.containsMouse || popup.visible ? "#3a3e4b" : "transparent"

        IconImage {
            anchors.centerIn: parent
            implicitSize: Appearance.iconSize
            source: Qt.resolvedUrl("icons/picture-in-picture.svg")
        }

        MouseArea {
            id: buttonMouse
            anchors.fill: parent
            hoverEnabled: true
            enabled: PiPService.available
            onClicked: popup.visible = !popup.visible
        }
    }

    PopupWindow {
        id: popup
        implicitWidth: 380
        implicitHeight: 390
        visible: false
        color: "transparent"
        grabFocus: true

        anchor.window: root.barWindow
        anchor.rect.x: root.barWindow.width
        anchor.rect.y: 0
        anchor.edges: Edges.Top | Edges.Right
        anchor.gravity: Edges.Top | Edges.Left

        onVisibleChanged: {
            if (visible)
                PiPService.refresh()
        }

        Rectangle {
            anchors.fill: parent
            radius: 10
            color: "#ff1b1d24"
            border.color: "#3a3e4b"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: root.popupMargin
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34

                    Text {
                        text: "Picture in picture"
                        color: "#f4f4f5"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: PiPService.floating ? "Floating" : "Tiled"
                        color: PiPService.floating ? "#8bd49c" : "#aeb3c2"
                        font.pixelSize: 12
                    }

                    Rectangle {
                        width: 30
                        height: 30
                        radius: 7
                        color: closePopupMouse.containsMouse ? "#3a3e4b" : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "×"
                            color: "#f4f4f5"
                            font.pixelSize: 20
                        }

                        MouseArea {
                            id: closePopupMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: popup.visible = false
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#3a3e4b" }

                Text {
                    Layout.fillWidth: true
                    text: PiPService.application + " · " + PiPService.title
                    color: "#aeb3c2"
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }

                Text { text: "Size"; color: "#aeb3c2"; font.pixelSize: 11 }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    opacity: PiPService.floating ? 1 : 0.4

                    Text { text: "Small"; color: "#aeb3c2"; font.pixelSize: 11 }

                    Rectangle {
                        id: sizeTrack
                        Layout.fillWidth: true
                        Layout.preferredHeight: 6
                        radius: 3
                        color: "#494d59"

                        readonly property real fraction: Math.max(0, Math.min(1,
                            (PiPService.savedWidth - 320) / 640))

                        Rectangle {
                            width: parent.width * sizeTrack.fraction
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
                                parent.width * sizeTrack.fraction - width / 2))
                            color: "#f4f4f5"
                        }

                        MouseArea {
                            anchors.fill: parent
                            anchors.topMargin: -10
                            anchors.bottomMargin: -10
                            enabled: PiPService.floating

                            function updateSize(mouseX) {
                                const fraction = Math.max(0, Math.min(1, mouseX / sizeTrack.width))
                                PiPService.requestResize(320 + fraction * 640)
                            }

                            onPressed: mouse => updateSize(mouse.x)
                            onPositionChanged: mouse => {
                                if (pressed)
                                    updateSize(mouse.x)
                            }
                        }
                    }

                    Text { text: "Large"; color: "#aeb3c2"; font.pixelSize: 11 }
                }

                Text { text: "Position"; color: "#aeb3c2"; font.pixelSize: 11 }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    opacity: PiPService.floating ? 1 : 0.4

                    ActionButton {
                        label: "↗  Upper right"
                        selected: PiPService.corner === "top-right"
                        enabled: PiPService.floating
                        onClicked: PiPService.moveTo("top-right")
                    }

                    ActionButton {
                        label: "↘  Lower right"
                        selected: PiPService.corner === "bottom-right"
                        enabled: PiPService.floating
                        onClicked: PiPService.moveTo("bottom-right")
                    }
                }

                Text { text: "Window mode"; color: "#aeb3c2"; font.pixelSize: 11 }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    ActionButton {
                        label: "Floating"
                        selected: PiPService.floating
                        onClicked: PiPService.setFloating()
                    }

                    ActionButton {
                        label: "Tiled"
                        selected: !PiPService.floating
                        onClicked: PiPService.setTiled()
                    }
                }

                Item { Layout.fillHeight: true }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    ActionButton {
                        label: "Focus PiP"
                        onClicked: {
                            PiPService.focus()
                            popup.visible = false
                        }
                    }

                    ActionButton {
                        label: "Close PiP"
                        labelColor: "#e78284"
                        onClicked: {
                            PiPService.close()
                            popup.visible = false
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    visible: PiPService.lastError.length > 0
                    text: PiPService.lastError
                    color: "#e78284"
                    font.pixelSize: 10
                    wrapMode: Text.Wrap
                }
            }
        }
    }
}
