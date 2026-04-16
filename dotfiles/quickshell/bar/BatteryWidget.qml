// dotfiles/quickshell/bar/BatteryWidget.qml
import Quickshell.Services.UPower
import QtQuick

Item {
    width:  visible ? batText.implicitWidth + 20 : 0
    height: parent.height

    // Hide on desktops with no battery
    visible: UPower.displayDevice?.isPresent ?? false

    Text {
        id: batText
        anchors.centerIn: parent
        color: {
            const pct = UPower.displayDevice?.percentage ?? 100
            if (pct <= 15) return "#e05c6f"
            if (pct <= 30) return "#f7a8d4"
            return "#e8e6f0"
        }
        font { family: "JetBrainsMono Nerd Font"; pixelSize: 12 }

        readonly property real  pct:      UPower.displayDevice?.percentage ?? 100
        readonly property bool  charging: UPower.displayDevice?.state === UPowerDeviceState.Charging

        text: {
            const icon = charging ? "󰂄" :
                         pct > 90 ? "󰁹" : pct > 70 ? "󰂀" : pct > 50 ? "󰁿" :
                         pct > 30 ? "󰁾" : pct > 15 ? "󰁼" : "󰁺"
            return icon + " " + Math.round(pct) + "%"
        }
    }
}
