import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets

// Pacman and AUR update monitor for the bottom AEL bar.
// Popup pages: update list and selected-package information.
Item {
    id: root

    required property var barWindow
    property int popupMargin: 12
    property string page: "updates"

    width: 30
    height: 30

    property var selectedPackage: null
    property var packageInfo: ({})
    property string packageInfoRaw: ""
    property bool loadingDetails: false

    function parsePackageInfo(output) {
        const info = {}
        let currentKey = ""

        for (const line of output.split("\n")) {
            const separator = line.indexOf(":")
            if (separator > 0 && !/^\s/.test(line)) {
                currentKey = line.substring(0, separator).trim()
                info[currentKey] = line.substring(separator + 1).trim()
            } else if (currentKey && line.trim()) {
                info[currentKey] += " " + line.trim()
            }
        }

        return info
    }

    function openDetails(pkg) {
        if (!pkg || !/^[A-Za-z0-9@._+:-]+$/.test(pkg.name))
            return

        root.selectedPackage = pkg
        root.packageInfo = ({})
        root.packageInfoRaw = ""
        root.loadingDetails = true
        root.page = "details"

        if (pkg.source === "AUR") {
            detailsProcess.exec([
                "sh", "-c",
                "if ! command -v " + root.aurHelper + " >/dev/null 2>&1; then "
                + "printf 'AUR helper not found: " + root.aurHelper + "'; exit 0; fi; "
                + root.aurHelper + " -Si --aur " + pkg.name + " 2>&1"
            ])
        } else {
            detailsProcess.exec(["pacman", "-Si", pkg.name])
        }
    }

    Process {
        id: detailsProcess
        stdout: StdioCollector {
            onStreamFinished: {
                root.packageInfoRaw = text.trim()
                root.packageInfo = root.parsePackageInfo(text)
                root.loadingDetails = false
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 7
        color: buttonMouse.containsMouse || popup.visible ? "#3a3e4b" : "transparent"

        IconImage {
            anchors.centerIn: parent
            implicitSize: Appearance.iconSize
            source: Qt.resolvedUrl(PackageService.updateCount > 50
                ? "icons/download-package-red.svg"
                : "icons/download-package.svg")
        }

        MouseArea {
            id: buttonMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: popup.visible = !popup.visible
        }
    }

    PopupWindow {
        id: popup
        implicitWidth: 380
        implicitHeight: 460
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
                PackageService.refresh()
            else {
                root.page = "updates"
                root.selectedPackage = null
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: 10
            color: "#ff1b1d24"
            border.color: "#3a3e4b"

            Loader {
                anchors.fill: parent
                anchors.margins: root.popupMargin
                sourceComponent: root.page === "details"
                    ? packageDetailsPage : packageUpdatesPage
            }
        }
    }

    Component {
        id: packageUpdatesPage

        ColumnLayout {
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 34

                Text {
                    text: "Package updates"
                    color: "#f4f4f5"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: PackageService.checking ? "Checking…" : PackageService.updateCount.toString()
                    color: PackageService.updateCount > 50 ? "#e78284" : "#8bd49c"
                    font.pixelSize: 12
                }
                Rectangle {
                    width: 30
                    height: 30
                    radius: 7
                    color: refreshMouse.containsMouse ? "#3a3e4b" : "transparent"
                    IconImage {
                        anchors.centerIn: parent
                        implicitSize: 16
                        source: Quickshell.iconPath("view-refresh-symbolic", true)
                    }
                    MouseArea {
                        id: refreshMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: !PackageService.checking
                        onClicked: PackageService.refresh()
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#3a3e4b" }

            ListView {
                id: packageList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 3
                model: PackageService.updates

                delegate: Rectangle {
                    id: packageRow
                    required property var modelData
                    width: packageList.width
                    height: 52
                    color: packageMouse.containsMouse ? "#343844" : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text {
                                Layout.fillWidth: true
                                text: packageRow.modelData.name + " "
                                    + packageRow.modelData.oldVersion + "  →  "
                                    + packageRow.modelData.newVersion
                                color: "#f4f4f5"
                                font.pixelSize: 13
                                elide: Text.ElideRight
                            }
                            Text {
                                text: packageRow.modelData.source === "AUR" ? "AUR" : "pacman"
                                color: packageRow.modelData.source === "AUR" ? "#e5c890" : "#aeb3c2"
                                font.pixelSize: 10
                            }
                        }
                        Text { text: "›"; color: "#8bd49c"; font.pixelSize: 22 }
                    }

                    MouseArea {
                        id: packageMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.openDetails(packageRow.modelData)
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                Layout.preferredHeight: PackageService.updates.length === 0 ? 40 : 0
                visible: PackageService.updates.length === 0
                text: PackageService.statusMessage
                color: PackageService.statusMessage === "Your system is up to date" ? "#8bd49c" : "#aeb3c2"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.Wrap
            }
        }
    }

    Component {
        id: packageDetailsPage

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
                        text: root.selectedPackage?.name ?? "Package information"
                        color: "#f4f4f5"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }
                    IconImage {
                        implicitWidth: 16
                        implicitHeight: 16
                        source: Qt.resolvedUrl("icons/close.svg")
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: root.page = "updates"
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#3a3e4b" }

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                contentWidth: width
                contentHeight: detailsColumn.implicitHeight

                ColumnLayout {
                    id: detailsColumn
                    width: parent.width
                    spacing: 12

                    Text {
                        visible: root.loadingDetails
                        text: "Loading package information…"
                        color: "#aeb3c2"
                    }
                    Text {
                        Layout.fillWidth: true
                        visible: !root.loadingDetails
                        text: root.packageInfo.Description ?? "No package description available."
                        color: "#f4f4f5"
                        font.pixelSize: 13
                        wrapMode: Text.Wrap
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        visible: !root.loadingDetails
                        columns: 2
                        columnSpacing: 14
                        rowSpacing: 8

                        Text { text: "Source"; color: "#aeb3c2" }
                        Text {
                            Layout.fillWidth: true
                            text: root.selectedPackage?.source ?? "—"
                            color: root.selectedPackage?.source === "AUR" ? "#e5c890" : "#f4f4f5"
                            elide: Text.ElideRight
                        }
                        Text { text: "Installed"; color: "#aeb3c2" }
                        Text {
                            Layout.fillWidth: true
                            text: root.selectedPackage?.oldVersion ?? "—"
                            color: "#f4f4f5"
                            elide: Text.ElideRight
                        }
                        Text { text: "Available"; color: "#aeb3c2" }
                        Text {
                            Layout.fillWidth: true
                            text: root.selectedPackage?.newVersion ?? "—"
                            color: "#8bd49c"
                            elide: Text.ElideRight
                        }
                        Text { text: "Repository"; color: "#aeb3c2" }
                        Text {
                            Layout.fillWidth: true
                            text: root.packageInfo.Repository
                                ?? (root.selectedPackage?.source === "AUR" ? "AUR" : "—")
                            color: "#f4f4f5"
                            elide: Text.ElideRight
                        }
                        Text { text: "Download"; color: "#aeb3c2" }
                        Text {
                            Layout.fillWidth: true
                            text: root.packageInfo["Download Size"] ?? "—"
                            color: "#f4f4f5"
                            elide: Text.ElideRight
                        }
                        Text { text: "Packager"; color: "#aeb3c2" }
                        Text {
                            Layout.fillWidth: true
                            text: root.packageInfo.Packager ?? root.packageInfo.Maintainer ?? "—"
                            color: "#f4f4f5"
                            elide: Text.ElideRight
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        visible: !root.loadingDetails
                        color: "#3a3e4b"
                    }
                    Text {
                        Layout.fillWidth: true
                        visible: !root.loadingDetails && root.packageInfoRaw.length > 0
                            && Object.keys(root.packageInfo).length === 0
                        text: root.packageInfoRaw
                        color: "#aeb3c2"
                        font.family: "monospace"
                        font.pixelSize: 11
                        wrapMode: Text.Wrap
                    }
                }
            }
        }
    }
}
