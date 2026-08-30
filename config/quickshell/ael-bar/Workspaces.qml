// +--------------------------------------------------------------------------+
// [+] INFO
// +--------------------------------------------------------------------------+
// [/.config/quickshell/ael-bar/Workspaces.qml]
// 
// Author      : Pascal Malouin (https://github.com/alterEGO-Linux)
// Created     : 2026-08-26 14:48:23 UTC
// Updated     : 2026-08-26 14:48:23 UTC
// Description : Workspaces.
// +--------------------------------------------------------------------------+

import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

// Hyprland workspace switcher for a multi-monitor bar.
//
// Each instance resolves the Hyprland monitor associated with its bar window,
// then displays only the workspaces currently assigned to that monitor.
Item {
    id: root

    required property var barWindow

    property int buttonSize: 26
    property int spacing: 4
    property color activeColor: "#f4f4f5"
    property color activeBackground: "#3a3e4b"
    property color inactiveColor: "#f4f4f5"
    property color hoverBackground: "#3a3e4b"
    property color normalBackground: "#292c35"

    readonly property var monitor: barWindow?.screen
        ? Hyprland.monitorFor(barWindow.screen)
        : null

    readonly property var monitorWorkspaces: Hyprland.workspaces.values.filter(workspace =>
        workspace.monitor === root.monitor
        && !workspace.name.startsWith("special:")
    )

    implicitWidth: workspaceRow.implicitWidth
    implicitHeight: 30
    width: implicitWidth
    height: implicitHeight

    RowLayout {
        id: workspaceRow

        anchors.centerIn: parent
        spacing: root.spacing

        Repeater {
            model: root.monitorWorkspaces

            delegate: Rectangle {
                id: workspaceButton

                required property var modelData

                Layout.preferredWidth: root.buttonSize
                Layout.preferredHeight: root.height

                radius: 0

                color: modelData.active || workspaceMouse.containsMouse
                    ? root.activeBackground
                    : root.normalBackground

                Text {
                    anchors.centerIn: parent

                    // Numeric workspaces use their ID. Named workspaces use
                    // their name, with Hyprland's "name:" prefix removed.
                    text: workspaceButton.modelData.id > 0
                        ? workspaceButton.modelData.id
                        : workspaceButton.modelData.name.replace(/^name:/, "")

                    color: "#f4f4f5"

                    font.pixelSize: 12
                    font.weight: workspaceButton.modelData.active
                        ? Font.DemiBold
                        : Font.Normal
                }

                MouseArea {
                    id: workspaceMouse

                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: workspaceButton.modelData.activate()

                    // Move through workspaces assigned to this monitor while
                    // keeping the pointer over the center widget.
                    onWheel: wheel => {
                        const workspaces = root.monitorWorkspaces

                        if (workspaces.length < 2)
                            return

                        let current = workspaces.findIndex(workspace => workspace.active)

                        if (current < 0)
                            current = 0

                        const direction = wheel.angleDelta.y > 0 ? -1 : 1
                        const next = (current + direction + workspaces.length)
                            % workspaces.length

                        workspaces[next].activate()
                        wheel.accepted = true
                    }
                }
            }
        }

        Text {
            visible: root.monitorWorkspaces.length === 0
            text: "No workspaces"
            color: root.inactiveColor
            font.pixelSize: 11
        }
    }
}
