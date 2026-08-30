import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets

// Compact system monitor for a bottom AEL bar.
//
// The bar shows an icon and the hottest/most useful current value. The popup
// contains CPU, memory, root disk and temperature details. Data comes directly
// from Linux procfs/sysfs, with no lm_sensors dependency.
Item {
    id: root

    required property var barWindow
    property int popupMargin: 12

    width: 30
    height: 30

    property real cpuUsage: 0
    property real memoryUsage: 0
    property real diskUsage: 0
    property real temperature: -1

    property string memoryUsed: "--"
    property string memoryTotal: "--"
    property string diskUsed: "--"
    property string diskTotal: "--"
    property string diskFree: "--"

    property real previousCpuTotal: 0
    property real previousCpuIdle: 0

    readonly property bool systemWarning:
        cpuUsage >= 70 || memoryUsage >= 75

    function warningColor(value, warning, critical) {
        if (value >= critical)
            return "#e78284"
        if (value >= warning)
            return "#e5c890"
        //return "#8bd49c"
        return "#1B6E86"
    }

    function parseStats(output) {
        const values = {}

        for (const line of output.trim().split("\n")) {
            const separator = line.indexOf("=")
            if (separator > 0)
                values[line.substring(0, separator)] = line.substring(separator + 1)
        }

        const cpuFields = (values.cpu ?? "").trim().split(/\s+/).map(Number)
        if (cpuFields.length >= 5) {
            const idle = cpuFields[3] + (cpuFields[4] || 0)
            const total = cpuFields.reduce((sum, value) => sum + value, 0)
            const totalDelta = total - root.previousCpuTotal
            const idleDelta = idle - root.previousCpuIdle

            if (root.previousCpuTotal > 0 && totalDelta > 0)
                root.cpuUsage = Math.max(0, Math.min(100,
                    100 * (totalDelta - idleDelta) / totalDelta))

            root.previousCpuTotal = total
            root.previousCpuIdle = idle
        }

        const memoryTotalKb = Number(values.memoryTotal ?? 0)
        const memoryAvailableKb = Number(values.memoryAvailable ?? 0)
        if (memoryTotalKb > 0) {
            const memoryUsedKb = memoryTotalKb - memoryAvailableKb
            root.memoryUsage = 100 * memoryUsedKb / memoryTotalKb
            root.memoryUsed = (memoryUsedKb / 1048576).toFixed(1) + " GiB"
            root.memoryTotal = (memoryTotalKb / 1048576).toFixed(1) + " GiB"
        }

        root.diskUsage = Number(values.diskPercent ?? 0)
        root.diskUsed = values.diskUsed ?? "--"
        root.diskTotal = values.diskTotal ?? "--"
        root.diskFree = values.diskFree ?? "--"

        const temperatureMillidegrees = Number(values.temperature ?? -1000)
        root.temperature = temperatureMillidegrees >= 0
            ? temperatureMillidegrees / 1000
            : -1
    }

    function refresh() {
        if (!statsProcess.running)
            statsProcess.exec([
                "sh", "-c",
                "awk '/^cpu / {sub(/^cpu +/, \"\"); print \"cpu=\" $0} "
                + "/^MemTotal:/ {print \"memoryTotal=\" $2} "
                + "/^MemAvailable:/ {print \"memoryAvailable=\" $2}' "
                + "/proc/stat /proc/meminfo; "
                + "df -Pk / | awk 'NR==2 {gsub(/%/, \"\", $5); "
                + "printf \"diskPercent=%s\\ndiskUsed=%.1f GiB\\ndiskTotal=%.1f GiB\\ndiskFree=%.1f GiB\\n\", "
                + "$5, $3/1048576, $2/1048576, $4/1048576}'; "
                + "for f in /sys/class/hwmon/hwmon*/temp*_input; do "
                + "[ -r \"$f\" ] || continue; v=$(cat \"$f\"); "
                + "[ \"$v\" -gt 0 ] 2>/dev/null || continue; "
                + "[ \"$v\" -lt 120000 ] 2>/dev/null || continue; "
                + "if [ -z \"$max\" ] || [ \"$v\" -gt \"$max\" ]; then max=$v; fi; "
                + "done; printf 'temperature=%s\\n' \"${max:--1000}\""
            ])
    }

    Process {
        id: statsProcess

        stdout: StdioCollector {
            onStreamFinished: root.parseStats(text)
        }
    }

    Timer {
        interval: 3000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refresh()
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

            source: Qt.resolvedUrl(root.systemWarning
                ? "icons/system-monitor-red.svg"
                : "icons/system-monitor.svg")
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

        implicitWidth: 340
        implicitHeight: 300

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
                root.refresh()
        }

        Rectangle {
            anchors.fill: parent
            radius: 10
            color: "#ff1b1d24"
            border.color: "#3a3e4b"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: root.popupMargin
                spacing: 12

                Text {
                    text: "System Monitor"
                    color: "#f4f4f5"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#3a3e4b"
                }

                MetricRow {
                    Layout.fillWidth: true
                    label: "CPU"
                    detail: Math.round(root.cpuUsage) + "%"
                    value: root.cpuUsage
                    accent: root.warningColor(root.cpuUsage, 75, 90)
                }

                MetricRow {
                    Layout.fillWidth: true
                    label: "Memory"
                    detail: root.memoryUsed + " / " + root.memoryTotal + " (" + Math.round(root.memoryUsage) + "%)"
                    value: root.memoryUsage
                    accent: root.warningColor(root.memoryUsage, 80, 90)
                }

                MetricRow {
                    Layout.fillWidth: true
                    label: "Disk /"
                    detail: root.diskUsed + " / " + root.diskTotal
                    value: root.diskUsage
                    accent: root.warningColor(root.diskUsage, 85, 95)
                }

                MetricRow {
                    Layout.fillWidth: true
                    label: "Temperature"
                    detail: root.temperature >= 0
                        ? Math.round(root.temperature) + "°C"
                        : "Unavailable"
                    value: root.temperature >= 0
                        ? Math.min(root.temperature, 100)
                        : 0
                    accent: root.temperature >= 0
                        ? root.warningColor(root.temperature, 75, 90)
                        : "#aeb3c2"
                }

                Item { Layout.fillHeight: true }

                Text {
                    Layout.alignment: Qt.AlignRight
                    text: "Disk free: " + root.diskFree
                    color: "#aeb3c2"
                    font.pixelSize: 11
                }
            }
        }
    }

    component MetricRow: ColumnLayout {
        id: metric

        required property string label
        required property string detail
        required property real value
        required property color accent

        spacing: 5

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: metric.label
                color: "#f4f4f5"
                font.pixelSize: 13
                font.weight: Font.Medium
            }

            Item { Layout.fillWidth: true }

            Text {
                text: metric.detail
                color: metric.accent
                font.pixelSize: 12
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 6
            radius: 3
            color: "#343844"

            Rectangle {
                width: parent.width * Math.max(0, Math.min(100, metric.value)) / 100
                height: parent.height
                radius: 3
                color: metric.accent

                Behavior on width {
                    NumberAnimation { duration: 250 }
                }
            }
        }
    }
}
