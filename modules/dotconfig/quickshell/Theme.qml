pragma Singleton

import Quickshell
import QtQuick

Singleton {
    // Colors matching the old rofi theme (dark with orange accent)
    readonly property color bg0: "#2d2d2d"
    readonly property color bg1: "#2A2A2A"
    readonly property color bg2: Qt.rgba(0.24, 0.24, 0.24, 0.5)
    readonly property color bg3: Qt.rgba(0.96, 0.49, 0.0, 0.95) // #F57C00
    readonly property color fg0: "#E6E6E6"
    readonly property color fg1: "#FFFFFF"
    readonly property color fg2: "#969696"
    readonly property color fg3: "#3D3D3D"

    readonly property int radius: 16
    readonly property int windowWidth: 480
    readonly property int itemHeight: 36
    readonly property int padding: 12
    readonly property string fontFamily: "Sans"
    readonly property int fontSize: 13
}
