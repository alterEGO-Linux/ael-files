import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Widgets

// Native NetworkManager control for a bottom Quickshell panel.
//
// The popup uses two internal pages instead of nested platform menus:
//   status   -> Wi-Fi switch and current connection information
//   networks -> available networks and password entry
Item {
    id: root

    required property var barWindow
    property int popupMargin: 12

    width: 30
    height: 30

    property string page: "status"

    // Find the first Wi-Fi device exposed by NetworkManager.
    property var wifiDevice: Networking.devices.values.find(device =>
        device.type === DeviceType.Wifi
    ) ?? null

    // Find the currently connected Wi-Fi network.
    property var currentNetwork: wifiDevice?.networks.values.find(network =>
        network.connected
    ) ?? null

    // A secured network waiting for a password.
    property var pendingNetwork: null

    // Extra information supplied by nmcli.
    property string interfaceName: ""
    property string connectionName: ""
    property string ipAddress: ""
    property string gateway: ""
    property string dnsServer: ""

    // Active VPN information supplied by NetworkManager.
    property string vpnName: ""
    property string vpnType: ""
    property string vpnInterface: ""
    property string vpnIpAddress: ""

    readonly property bool vpnActive: vpnName !== ""

    function refreshNetworkInfo() {
        if (root.wifiDevice) {
            // Process executes the argument list directly.
            // No shell quoting is required.
            networkInfoProcess.exec([
                "nmcli",
                "--terse",
                "--fields",
                "GENERAL.DEVICE,GENERAL.CONNECTION,IP4.ADDRESS,IP4.GATEWAY,IP4.DNS",
                "device",
                "show",
                root.wifiDevice.name
            ])
        }

        // VPNs are connections rather than Wi-Fi devices, so they need a
        // separate query. NetworkManager may expose them as vpn, wireguard,
        // or as a generic tun connection such as tun0.
        vpnConnectionProcess.exec([
            "nmcli",
            "--terse",
            "--fields",
            "NAME,TYPE,DEVICE",
            "connection",
            "show",
            "--active"
        ])
    }

    function parseVpnConnections(output) {
        root.vpnName = ""
        root.vpnType = ""
        root.vpnInterface = ""
        root.vpnIpAddress = ""

        const lines = output.trim().split("\n")

        for (const line of lines) {
            const fields = line.split(":")
            const type = fields[1] ?? ""

            if (
                type !== "vpn"
                && type !== "wireguard"
                && type !== "tun"
            )
                continue

            root.vpnName = fields[0] ?? ""
            root.vpnType = type === "wireguard"
                ? "WireGuard"
                : type === "tun"
                    ? "TUN tunnel"
                    : "VPN"
            root.vpnInterface = fields[2] ?? ""

            if (root.vpnInterface) {
                vpnInfoProcess.exec([
                    "nmcli",
                    "--terse",
                    "--fields",
                    "IP4.ADDRESS",
                    "device",
                    "show",
                    root.vpnInterface
                ])
            }

            return
        }
    }

    function parseVpnInfo(output) {
        root.vpnIpAddress = ""

        for (const line of output.trim().split("\n")) {
            const separator = line.indexOf(":")

            if (separator >= 0) {
                root.vpnIpAddress = line.substring(separator + 1)
                return
            }
        }
    }

    function parseNetworkInfo(output) {
        root.interfaceName = ""
        root.connectionName = ""
        root.ipAddress = ""
        root.gateway = ""
        root.dnsServer = ""

        const lines = output.trim().split("\n")

        for (const line of lines) {
            const separator = line.indexOf(":")

            if (separator < 0)
                continue

            const key = line.substring(0, separator)
            const value = line.substring(separator + 1)

            if (key === "GENERAL.DEVICE") {
                root.interfaceName = value
            } else if (key === "GENERAL.CONNECTION") {
                root.connectionName = value
            } else if (
                key.startsWith("IP4.ADDRESS")
                && !root.ipAddress
            ) {
                root.ipAddress = value
            } else if (key === "IP4.GATEWAY") {
                root.gateway = value
            } else if (
                key.startsWith("IP4.DNS")
                && !root.dnsServer
            ) {
                root.dnsServer = value
            }
        }
    }

    function selectNetwork(network) {
        if (network.connected) {
            network.disconnect()
        } else if (
            network.known
            || network.security === WifiSecurityType.Open
        ) {
            network.connect()
        } else {
            // Display the password editor.
            root.pendingNetwork = network
        }
    }

    Process {
        id: networkInfoProcess

        stdout: StdioCollector {
            onStreamFinished: root.parseNetworkInfo(text)
        }
    }

    Process {
        id: vpnConnectionProcess

        stdout: StdioCollector {
            onStreamFinished: root.parseVpnConnections(text)
        }
    }

    Process {
        id: vpnInfoProcess

        stdout: StdioCollector {
            onStreamFinished: root.parseVpnInfo(text)
        }
    }

    // Refresh DHCP information while the popup is open.
    Timer {
        interval: 5000
        repeat: true
        running: popup.visible

        onTriggered: root.refreshNetworkInfo()
    }

    // Refresh immediately when the active network changes.
    onCurrentNetworkChanged: {
        if (popup.visible)
            root.refreshNetworkInfo()
    }

    // ------------------------------------------------------------------
    // Bar icon
    // ------------------------------------------------------------------

    Rectangle {
        anchors.fill: parent

        radius: 7

        color: buttonMouse.containsMouse || popup.visible
            ? "#3a3e4b"
            : "transparent"

        IconImage {
            anchors.centerIn: parent

            implicitSize: Appearance.iconSize

            source: Quickshell.iconPath(
                root.currentNetwork
                    ? "network-wireless-signal-excellent-symbolic"
                    : "network-wireless-offline-symbolic",
                true
            )
        }

        MouseArea {
            id: buttonMouse

            anchors.fill: parent
            hoverEnabled: true

            onClicked: {
                popup.visible = !popup.visible
            }
        }
    }

    // ------------------------------------------------------------------
    // Popup shared by both internal pages
    // ------------------------------------------------------------------

    PopupWindow {
        id: popup

        implicitWidth: 360
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
            // Scan only while the network popup is open.
            if (root.wifiDevice)
                root.wifiDevice.scannerEnabled = visible

            if (visible) {
                root.refreshNetworkInfo()
            } else {
                root.page = "status"
                root.pendingNetwork = null
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

                sourceComponent: root.page === "networks"
                    ? availableNetworksPage
                    : root.page === "vpn"
                        ? vpnStatusPage
                        : networkStatusPage
            }
        }
    }

    // ------------------------------------------------------------------
    // Page 1: current connection information
    // ------------------------------------------------------------------

    Component {
        id: networkStatusPage

        ColumnLayout {
            spacing: 10

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Network"

                    color: "#f4f4f5"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: Networking.wifiEnabled
                        ? "Wi-Fi on"
                        : "Wi-Fi off"

                    color: Networking.wifiEnabled
                        ? "#8bd49c"
                        : "#aeb3c2"
                }

                // Compact custom Wi-Fi switch.
                Rectangle {
                    width: 42
                    height: 22

                    radius: 11

                    color: Networking.wifiEnabled
                        ? "#4f8f65"
                        : "#494d59"

                    enabled: Networking.wifiHardwareEnabled

                    Rectangle {
                        width: 18
                        height: 18

                        radius: 9

                        y: 2
                        x: Networking.wifiEnabled ? 22 : 2

                        color: "#f4f4f5"
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            Networking.wifiEnabled =
                                !Networking.wifiEnabled
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true

                height: 1
                color: "#3a3e4b"
            }

            Text {
                text: "Connected network"

                color: "#aeb3c2"
                font.pixelSize: 11
            }

            Text {
                Layout.fillWidth: true

                text: root.currentNetwork?.name ?? "Not connected"

                color: "#f4f4f5"
                font.pixelSize: 18
                font.weight: Font.DemiBold

                elide: Text.ElideRight
            }

            // Current network information.
            GridLayout {
                Layout.fillWidth: true

                columns: 2
                columnSpacing: 14
                rowSpacing: 7

                Text {
                    text: "Signal"
                    color: "#aeb3c2"
                }

                Text {
                    text: root.currentNetwork
                        ? Math.round(
                            root.currentNetwork.signalStrength * 100
                        ) + "%"
                        : "—"

                    color: "#f4f4f5"
                }

                Text {
                    text: "Security"
                    color: "#aeb3c2"
                }

                Text {
                    text: root.currentNetwork
                        ? WifiSecurityType.toString(
                            root.currentNetwork.security
                        )
                        : "—"

                    color: "#f4f4f5"
                }

                Text {
                    text: "Interface"
                    color: "#aeb3c2"
                }

                Text {
                    text: root.interfaceName || "—"
                    color: "#f4f4f5"
                }

                Text {
                    text: "IP address"
                    color: "#aeb3c2"
                }

                Text {
                    text: root.ipAddress || "—"
                    color: "#f4f4f5"
                }

                Text {
                    text: "Gateway"
                    color: "#aeb3c2"
                }

                Text {
                    text: root.gateway || "—"
                    color: "#f4f4f5"
                }

                Text {
                    text: "DNS"
                    color: "#aeb3c2"
                }

                Text {
                    text: root.dnsServer || "—"
                    color: "#f4f4f5"
                }
            }

            Item {
                Layout.fillHeight: true
            }

            // [*] VPN Button
            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: -root.popupMargin
                Layout.rightMargin: -root.popupMargin
                Layout.preferredHeight: 38

                visible: root.vpnActive

                color: vpnMouse.containsMouse
                    ? "#3a3e4b"
                    : "#292c35"

                Text {
                    anchors.centerIn: parent

                    text: "VPN connection (" + root.vpnName + ")"
                    color: "#f4f4f5"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }

               // RowLayout {
               //     anchors.fill: parent
               //     anchors.leftMargin: 12
               //     anchors.rightMargin: 12

               //     Text {
               //         text: "VPN connection"
               //         color: "#f4f4f5"
               //         font.pixelSize: 13
               //         font.weight: Font.Medium
               //     }

               //     Item {
               //         Layout.fillWidth: true
               //     }

               //     Text {
               //         text: root.vpnName + "  ›"
               //         color: "#8bd49c"
               //         elide: Text.ElideRight
               //     }
               // }

                MouseArea {
                    id: vpnMouse

                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: {
                        root.page = "vpn"
                    }
                }
            }

            // [*] Available Connections Button
            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: -root.popupMargin
                Layout.rightMargin: -root.popupMargin
                Layout.preferredHeight: 38

                color: connectionsMouse.containsMouse
                    ? "#3a3e4b"
                    : "#292c35"

                Text {
                    anchors.centerIn: parent

                    text: "Available connections"
                    color: "#f4f4f5"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }

                MouseArea {
                    id: connectionsMouse

                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: {
                        root.page = "networks"
                    }
                }
            }
        }
    }

    // ------------------------------------------------------------------
    // Page 2: active VPN information
    // ------------------------------------------------------------------

    Component {
        id: vpnStatusPage

        ColumnLayout {
            spacing: 10

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 34

                color: "transparent"

                RowLayout {
                    anchors.fill: parent

                    Text {
                        Layout.fillWidth: true

                        text: "VPN connection"
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

                    onClicked: {
                        root.page = "status"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#3a3e4b"
            }

            Text {
                text: "Active tunnel"
                color: "#aeb3c2"
                font.pixelSize: 11
            }

            Text {
                Layout.fillWidth: true

                text: root.vpnName || "Not connected"
                color: root.vpnActive ? "#8bd49c" : "#f4f4f5"
                font.pixelSize: 18
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            GridLayout {
                Layout.fillWidth: true

                columns: 2
                columnSpacing: 14
                rowSpacing: 7

                Text {
                    text: "Type"
                    color: "#aeb3c2"
                }

                Text {
                    text: root.vpnType || "—"
                    color: "#f4f4f5"
                }

                Text {
                    text: "Interface"
                    color: "#aeb3c2"
                }

                Text {
                    text: root.vpnInterface || "—"
                    color: "#f4f4f5"
                }

                Text {
                    text: "IP address"
                    color: "#aeb3c2"
                }

                Text {
                    text: root.vpnIpAddress || "—"
                    color: "#f4f4f5"
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }

    // ------------------------------------------------------------------
    // Page 3: available Wi-Fi networks
    // ------------------------------------------------------------------

    Component {
        id: availableNetworksPage

        ColumnLayout {
            spacing: 8

            // Back button and page title.
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 34

                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.rightMargin: 10

                    Text {
                        Layout.fillWidth: true

                        text: "Available connections"

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

                    onClicked: {
                        root.pendingNetwork = null
                        root.page = "status"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true

                height: 1
                color: "#3a3e4b"
            }

            ListView {
                id: networkList

                Layout.fillWidth: true
                Layout.fillHeight: true

                clip: true
                spacing: 3

                model: root.wifiDevice?.networks ?? null

                delegate: Rectangle {
                    id: networkRow

                    required property var modelData

                    width: networkList.width
                    height: 44

                    radius: 7

                    color: networkMouse.containsMouse
                        ? "#343844"
                        : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8

                        Text {
                            text: networkRow.modelData.connected
                                ? "●"
                                : "○"

                            color: networkRow.modelData.connected
                                ? "#8bd49c"
                                : "#777c89"
                        }

                        Text {
                            Layout.fillWidth: true

                            text: networkRow.modelData.name
                            color: "#f4f4f5"

                            elide: Text.ElideRight
                        }

                        Text {
                            text: networkRow.modelData.security
                                === WifiSecurityType.Open
                                ? ""
                                : "🔒"

                            color: "#aeb3c2"
                            font.pixelSize: 11
                        }

                        Text {
                            text: Math.round(
                                networkRow.modelData.signalStrength * 100
                            ) + "%"

                            color: "#aeb3c2"
                        }
                    }

                    MouseArea {
                        id: networkMouse

                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            root.selectNetwork(networkRow.modelData)
                        }
                    }
                }
            }

            // Displayed after selecting a new secured network.
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: root.pendingNetwork ? 78 : 0

                visible: root.pendingNetwork !== null

                radius: 7
                color: "#292c35"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8

                    spacing: 5

                    Text {
                        text: root.pendingNetwork
                            ? "Password for "
                                + root.pendingNetwork.name
                            : ""

                        color: "#aeb3c2"
                        font.pixelSize: 11
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        spacing: 6

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            radius: 5
                            color: "#17191f"

                            border.color: passwordInput.activeFocus
                                ? "#6f91c7"
                                : "#3a3e4b"

                            Text {
                                anchors.fill: parent
                                anchors.margins: 8

                                text: "Password"
                                color: "#777c89"

                                verticalAlignment: Text.AlignVCenter
                                visible: passwordInput.text.length === 0
                            }

                            TextInput {
                                id: passwordInput

                                anchors.fill: parent
                                anchors.margins: 8

                                color: "#f4f4f5"
                                echoMode: TextInput.Password
                                verticalAlignment: TextInput.AlignVCenter

                                function submit() {
                                    if (
                                        !root.pendingNetwork
                                        || text.length === 0
                                    ) {
                                        return
                                    }

                                    root.pendingNetwork.connectWithPsk(text)

                                    text = ""
                                    root.pendingNetwork = null
                                }

                                onAccepted: {
                                    submit()
                                }
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 70
                            Layout.fillHeight: true

                            radius: 5

                            color: connectMouse.containsMouse
                                ? "#5d80b7"
                                : "#496a9f"

                            Text {
                                anchors.centerIn: parent

                                text: "Connect"
                                color: "#ffffff"
                            }

                            MouseArea {
                                id: connectMouse

                                anchors.fill: parent
                                hoverEnabled: true

                                onClicked: {
                                    passwordInput.submit()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
