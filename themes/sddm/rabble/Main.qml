// themes/sddm/rabble/Main.qml
// =============================================================================
// RaBbLE SDDM Theme
// Wayland-native QML greeter — matches RaBbLE palette exactly.
// =============================================================================

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SddmComponents

Rectangle {
    id: root

    // SDDM injects these
    property string notificationMessage: ""

    // ── Palette ───────────────────────────────────────────────────────────────
    readonly property color clrBg:       "#0d0f1a"
    readonly property color clrSurface:  "#12132a"
    readonly property color clrPrimary:  "#7c6fe0"
    readonly property color clrAccent:   "#4ecdc4"
    readonly property color clrText:     "#e8e6f0"
    readonly property color clrMuted:    "#6b6880"
    readonly property color clrError:    "#e05c6f"
    readonly property color clrBorder:   "#2a2840"

    width:  Screen.width
    height: Screen.height
    color:  clrBg

    // ── Background gradient ───────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#0d0f1a" }
            GradientStop { position: 1.0; color: "#0a0b15" }
        }
    }

    // ── Accent line at top ────────────────────────────────────────────────────
    Rectangle {
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 2
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: root.clrPrimary }
            GradientStop { position: 1.0; color: root.clrAccent  }
        }
    }

    // ── Clock ─────────────────────────────────────────────────────────────────
    Column {
        anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: parent.height * 0.15 }
        spacing: 8

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:  Qt.formatTime(new Date(), "HH:mm")
            color: root.clrText
            font { family: "JetBrainsMono Nerd Font"; pixelSize: 80; weight: Font.Light }

            Timer {
                interval: 1000
                running:  true
                repeat:   true
                onTriggered: parent.text = Qt.formatTime(new Date(), "HH:mm")
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:  Qt.formatDate(new Date(), "dddd, MMMM d")
            color: root.clrMuted
            font { family: "JetBrainsMono Nerd Font"; pixelSize: 20 }
        }
    }

    // ── Login panel ───────────────────────────────────────────────────────────
    Rectangle {
        id: loginPanel
        anchors.centerIn: parent
        width:  380
        height: loginColumn.implicitHeight + 48
        radius: 16
        color:  Qt.rgba(0.07, 0.075, 0.16, 0.90)
        border.color: root.clrBorder
        border.width: 1

        Column {
            id: loginColumn
            anchors { fill: parent; margins: 24 }
            spacing: 16

            // ── Logo / wordmark ───────────────────────────────────────────────
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text:  "RaBbLE"
                color: root.clrPrimary
                font { family: "JetBrainsMono Nerd Font"; pixelSize: 28; weight: Font.Bold }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text:  sddm.hostName
                color: root.clrMuted
                font { family: "JetBrainsMono Nerd Font"; pixelSize: 13 }
            }

            // ── Divider ───────────────────────────────────────────────────────
            Rectangle {
                width:  parent.width
                height: 1
                color:  root.clrBorder
            }

            // ── User selector ─────────────────────────────────────────────────
            ComboBox {
                id: userCombo
                width: parent.width
                model: userModel
                textRole: "name"
                currentIndex: userModel.lastIndex

                background: Rectangle {
                    color:        "#1a1b2e"
                    radius:       8
                    border.color: root.clrBorder
                    border.width: 1
                }

                contentItem: Text {
                    leftPadding: 12
                    text:  userCombo.displayText
                    color: root.clrText
                    font { family: "JetBrainsMono Nerd Font"; pixelSize: 13 }
                    verticalAlignment: Text.AlignVCenter
                }
            }

            // ── Password field ────────────────────────────────────────────────
            Rectangle {
                width:  parent.width
                height: 46
                radius: 8
                color:  "#1a1b2e"
                border.color: passField.activeFocus ? root.clrPrimary : root.clrBorder
                border.width: 1

                TextInput {
                    id: passField
                    anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                    echoMode:    TextInput.Password
                    color:       root.clrText
                    font       { family: "JetBrainsMono Nerd Font"; pixelSize: 14 }
                    verticalAlignment: TextInput.AlignVCenter
                    passwordCharacter: "●"
                    clip: true

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text:    "Password…"
                        color:   root.clrMuted
                        font:    parent.font
                        visible: parent.text.length === 0 && !parent.activeFocus
                    }

                    Keys.onReturnPressed: loginButton.doLogin()
                }
            }

            // ── Notification (error) message ──────────────────────────────────
            Text {
                width:   parent.width
                text:    root.notificationMessage
                color:   root.clrError
                font   { family: "JetBrainsMono Nerd Font"; pixelSize: 12 }
                wrapMode: Text.WordWrap
                visible: text.length > 0
                horizontalAlignment: Text.AlignHCenter
            }

            // ── Login button ──────────────────────────────────────────────────
            Rectangle {
                id: loginButton
                width:  parent.width
                height: 46
                radius: 8
                color:  loginMouse.containsMouse ? Qt.lighter(root.clrPrimary, 1.15)
                                                 : root.clrPrimary
                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text:  "Sign in"
                    color: "#ffffff"
                    font { family: "JetBrainsMono Nerd Font"; pixelSize: 14; weight: Font.Medium }
                }

                function doLogin() {
                    sddm.login(
                        userCombo.model.get(userCombo.currentIndex).name,
                        passField.text,
                        sessionCombo.currentIndex
                    )
                }

                MouseArea {
                    id: loginMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: loginButton.doLogin()
                }
            }
        }
    }

    // ── Session selector (bottom) ─────────────────────────────────────────────
    ComboBox {
        id: sessionCombo
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 32
        }
        width:  220
        model:  sessionModel
        textRole: "name"
        currentIndex: sessionModel.lastIndex

        background: Rectangle {
            color:        "transparent"
            radius:       8
            border.color: root.clrBorder
            border.width: 1
        }

        contentItem: Text {
            leftPadding: 12
            text:  sessionCombo.displayText
            color: root.clrMuted
            font { family: "JetBrainsMono Nerd Font"; pixelSize: 12 }
            verticalAlignment: Text.AlignVCenter
        }
    }

    // ── Power buttons (bottom-right) ──────────────────────────────────────────
    Row {
        anchors { right: parent.right; bottom: parent.bottom; margins: 24 }
        spacing: 12

        Repeater {
            model: [
                { label: "⏾", tip: "Suspend",  action: function() { sddm.suspend() } },
                { label: "↺", tip: "Reboot",   action: function() { sddm.reboot()  } },
                { label: "⏻", tip: "Power off", action: function() { sddm.powerOff()} },
            ]

            delegate: Rectangle {
                required property var modelData
                width:  38; height: 38
                radius: 8
                color:  powerMouse.containsMouse ? "#1a1b2e" : "transparent"
                border.color: root.clrBorder
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text:  modelData.label
                    color: root.clrMuted
                    font  { pixelSize: 18 }
                }

                ToolTip.text:    modelData.tip
                ToolTip.visible: powerMouse.containsMouse
                ToolTip.delay:   500

                MouseArea {
                    id: powerMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: modelData.action()
                }
            }
        }
    }

    // ── SDDM signal handlers ──────────────────────────────────────────────────
    Connections {
        target: sddm
        function onLoginFailed() {
            root.notificationMessage = "Incorrect username or password"
            passField.text = ""
            passField.forceActiveFocus()
        }
    }

    Component.onCompleted: passField.forceActiveFocus()
}
