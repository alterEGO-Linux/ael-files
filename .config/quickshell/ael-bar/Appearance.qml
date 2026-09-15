pragma Singleton

import QtQuick
import Quickshell

Singleton {

    readonly property color backgroundColor: "#ff0d1012"
    readonly property color borderColor: "#3a3e4b"

    // --- [PopupWindow] ------------------------------------------------------
    readonly property int popupWindowWidth: 340
    readonly property int popupWindowHeight: 300
    readonly property int popupWindowRectTLRadius: 10
    readonly property int popupWindowRectTRRadius: 10
    readonly property int popupWindowRectBLRadius: 0
    readonly property int popupWindowRectBRRadius: 0

    // Icons
    readonly property int iconSize: 20
}
