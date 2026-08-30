import QtQuick
import QtQuick.Layouts
import Quickshell

FloatingWindow {
    id: root
    visible: ScreenshotService.previewVisible
    title: "AEL//Screenshot"
    implicitWidth: 1000
    implicitHeight: 700
    color: "#ff1b1d24"

    onVisibleChanged: {
        if (!visible && ScreenshotService.previewVisible)
            ScreenshotService.previewVisible = false
    }

    Rectangle {
        anchors.fill: parent
        color: "#ff1b1d24"
        border.color: "#3a3e4b"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Text { text: "AEL//Screenshot"; color: "#f4f4f5"; font.pixelSize: 18; font.weight: Font.DemiBold }
                Item { Layout.fillWidth: true }
                Text {
                    text: ScreenshotService.statusMessage
                    color: ScreenshotService.savedPath.length > 0 ? "#8bd49c" : "#aeb3c2"
                    font.pixelSize: 11
                    elide: Text.ElideMiddle
                    Layout.maximumWidth: 500
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#111318"
                border.color: "#343844"
                Image {
                    anchors.fill: parent
                    anchors.margins: 8
                    source: ScreenshotService.previewUrl
                    fillMode: Image.PreserveAspectFit
                    cache: false
                    asynchronous: true
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                ActionButton { label: "Discard"; accent: false; onActivated: ScreenshotService.discard() }
                Item { Layout.fillWidth: true }
                ActionButton { label: "Open in GIMP"; accent: false; onActivated: ScreenshotService.openInGimp() }
                ActionButton { label: "Save"; accent: true; onActivated: ScreenshotService.save() }
            }
        }
    }

    component ActionButton: Rectangle {
        id: action
        required property string label
        property bool accent: false
        signal activated()
        Layout.preferredWidth: label === "Open in GIMP" ? 140 : 100
        Layout.preferredHeight: 36
        radius: 6
        color: actionMouse.containsMouse ? (accent ? "#247f99" : "#3a3e4b") : (accent ? "#1b6e86" : "#2b2e38")
        border.color: accent ? "#3594ad" : "#454956"
        Text { anchors.centerIn: parent; text: action.label; color: "#f4f4f5"; font.pixelSize: 13; font.weight: Font.DemiBold }
        MouseArea { id: actionMouse; anchors.fill: parent; hoverEnabled: true; onClicked: action.activated() }
    }
}
