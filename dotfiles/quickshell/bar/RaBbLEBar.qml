// dotfiles/quickshell/bar/RaBbLEBar.qml
// =============================================================================
// RaBbLE top bar — workspaces · window title · tray · clock · system
// =============================================================================

import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: bar
    required property var screen

    anchors {
        top:   true
        left:  true
        right: true
    }

    height:      36
    color:       "transparent"
    exclusiveZone: height

    // ── Blur background ───────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color:  Qt.rgba(0.05, 0.06, 0.10, 0.88)
        radius: 0

        // Bottom accent line
        Rectangle {
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: 1
            color:  "#7c6fe0"
            opacity: 0.5
        }
    }

    // ── Layout ────────────────────────────────────────────────────────────────
    RowLayout {
        anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
        spacing: 0

        // Left: workspaces
        WorkspaceBar {
            id: wsBar
            Layout.alignment: Qt.AlignVCenter
        }

        // Left separator
        BarSeparator {}

        // Left: active window title
        WindowTitle {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: 8
        }

        // Right: system tray
        SystemTrayWidget {
            Layout.alignment: Qt.AlignVCenter
            Layout.rightMargin: 4
        }

        BarSeparator {}

        // Right: network + audio quick-status
        NetworkWidget  { Layout.alignment: Qt.AlignVCenter }
        //AudioWidget    { Layout.alignment: Qt.AlignVCenter }
        BatteryWidget  { Layout.alignment: Qt.AlignVCenter }

        BarSeparator {}

        // Right: clock
        ClockWidget {
            Layout.alignment: Qt.AlignVCenter
            Layout.rightMargin: 4
        }
    }
}
