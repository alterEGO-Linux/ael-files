pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property bool available: pipWindow !== null
    readonly property bool floating: available && !!pipWindow.floating
    readonly property bool pinned: available && !!pipWindow.pinned
    readonly property string title: available ? (pipWindow.title || "Picture in picture") : ""
    readonly property string application: available
        ? ((pipWindow.class && pipWindow.class.length > 0) ? pipWindow.class : "Chromium")
        : ""

    property var pipWindow: null
    property var monitors: []
    property string corner: "bottom-right"
    property int savedWidth: 576
    property real savedRatio: 16 / 9
    property string lastError: ""

    // Adjust this if the bar height or its screen margin changes.
    property int edgeMargin: 20
    property int barClearance: 60

    property var commandQueue: []

    function luaWindow() {
        return "\"address:" + pipWindow.address + "\""
    }

    function dispatch(expression) {
        lastError = ""
        enqueue(["hyprctl", "dispatch", expression])
    }

    function hasPipTag(client) {
        const tags = client.tags || []
        for (let i = 0; i < tags.length; ++i) {
            if (String(tags[i]).replace(/\*$/, "") === "ael-pip")
                return true
        }

        // Fallback makes the widget usable while pip.lua is being installed.
        return client.initialTitle === "Picture-in-Picture"
            || client.initialTitle === "Picture in picture"
    }

    function parseClients(text) {
        try {
            const clients = JSON.parse(text)
            let found = null

            for (let i = 0; i < clients.length; ++i) {
                if (hasPipTag(clients[i])) {
                    found = clients[i]
                    break
                }
            }

            pipWindow = found

            if (found && found.size && found.size.length === 2 && found.size[1] > 0) {
                savedRatio = found.size[0] / found.size[1]
                if (found.floating)
                    savedWidth = found.size[0]
            }
        } catch (error) {
            console.warn("PiPService: cannot parse hyprctl clients:", error)
        }
    }

    function parseMonitors(text) {
        try {
            monitors = JSON.parse(text)
        } catch (error) {
            console.warn("PiPService: cannot parse hyprctl monitors:", error)
        }
    }

    function refresh() {
        if (!clientsProcess.running)
            clientsProcess.running = true
        if (!monitorsProcess.running)
            monitorsProcess.running = true
    }

    function addressSelector() {
        return available ? "address:" + pipWindow.address : ""
    }

    function monitorForPip() {
        if (!available)
            return null

        for (let i = 0; i < monitors.length; ++i) {
            if (monitors[i].id === pipWindow.monitor)
                return monitors[i]
        }

        return monitors.length > 0 ? monitors[0] : null
    }

    function monitorGeometry(monitor) {
        const scale = monitor.scale || 1
        return {
            x: monitor.x || 0,
            y: monitor.y || 0,
            width: Math.round(monitor.width / scale),
            height: Math.round(monitor.height / scale)
        }
    }

    function enqueue(args) {
        commandQueue = commandQueue.concat([args])
        runNextCommand()
    }

    function runNextCommand() {
        if (actionProcess.running || commandQueue.length === 0)
            return

        const next = commandQueue[0]
        commandQueue = commandQueue.slice(1)
        actionProcess.command = next
        actionProcess.running = true
    }

    function requestResize(width) {
        if (!available || !floating)
            return

        savedWidth = Math.max(240, Math.round(width))
        resizeDebounce.restart()
    }

    function applyRequestedResize() {
        if (!available || !floating)
            return

        const height = Math.max(135, Math.round(savedWidth / savedRatio))

        dispatch("hl.dsp.window.resize({ x = " + savedWidth
            + ", y = " + height
            + ", relative = false, window = " + luaWindow() + " })")
        enqueueMove(corner, savedWidth, height)
    }

    function moveTo(targetCorner) {
        if (!available || !floating)
            return

        corner = targetCorner
        const width = pipWindow.size ? pipWindow.size[0] : savedWidth
        const height = pipWindow.size ? pipWindow.size[1] : Math.round(width / savedRatio)
        enqueueMove(targetCorner, width, height)
    }

    function enqueueMove(targetCorner, width, height) {
        const monitor = monitorForPip()
        if (!monitor)
            return

        const geometry = monitorGeometry(monitor)
        const x = geometry.x + geometry.width - width - edgeMargin
        const y = targetCorner === "top-right"
            ? geometry.y + edgeMargin
            : geometry.y + geometry.height - height - barClearance

        dispatch("hl.dsp.window.move({ x = " + Math.round(x)
            + ", y = " + Math.round(y)
            + ", relative = false, window = " + luaWindow() + " })")
    }

    function setTiled() {
        if (!available)
            return

        if (floating && pipWindow.size) {
            savedWidth = pipWindow.size[0]
            if (pipWindow.size[1] > 0)
                savedRatio = pipWindow.size[0] / pipWindow.size[1]
        }

        if (pinned)
            dispatch("hl.dsp.window.pin({ action = \"disable\", window = "
                + luaWindow() + " })")
        if (floating)
            dispatch("hl.dsp.window.float({ action = \"disable\", window = "
                + luaWindow() + " })")
    }

    function setFloating() {
        if (!available)
            return

        const height = Math.max(135, Math.round(savedWidth / savedRatio))

        if (!floating)
            dispatch("hl.dsp.window.float({ action = \"enable\", window = "
                + luaWindow() + " })")
        if (!pinned)
            dispatch("hl.dsp.window.pin({ action = \"enable\", window = "
                + luaWindow() + " })")

        dispatch("hl.dsp.window.resize({ x = " + savedWidth
            + ", y = " + height
            + ", relative = false, window = " + luaWindow() + " })")
        enqueueMove(corner, savedWidth, height)
        dispatch("hl.dsp.window.alter_zorder({ mode = \"top\", window = "
            + luaWindow() + " })")
    }

    function focus() {
        if (available)
            dispatch("hl.dsp.focus({ window = " + luaWindow() + " })")
    }

    function close() {
        if (available)
            dispatch("hl.dsp.window.close({ window = " + luaWindow() + " })")
    }

    Process {
        id: clientsProcess
        command: ["hyprctl", "-j", "clients"]
        stdout: StdioCollector {
            onStreamFinished: root.parseClients(text)
        }
    }

    Process {
        id: monitorsProcess
        command: ["hyprctl", "-j", "monitors"]
        stdout: StdioCollector {
            onStreamFinished: root.parseMonitors(text)
        }
    }

    Process {
        id: actionProcess
        stderr: StdioCollector {
            onStreamFinished: {
                const message = text.trim()
                if (message.length > 0) {
                    root.lastError = message
                    console.warn("PiPService:", message)
                }
            }
        }
        onExited: {
            root.runNextCommand()
            settleRefresh.restart()
        }
    }

    Timer {
        id: resizeDebounce
        interval: 55
        repeat: false
        onTriggered: root.applyRequestedResize()
    }

    Timer {
        id: settleRefresh
        interval: 120
        repeat: false
        onTriggered: root.refresh()
    }

    Timer {
        interval: 750
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
