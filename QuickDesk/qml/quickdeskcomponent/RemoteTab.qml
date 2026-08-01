// Remote Tab Component - Single tab in the tab bar
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../component"


Rectangle {
    id: control

    property string deviceId: ""
    property string deviceName: ""
    property int ping: 0
    property string connectionState: "connected"
    property bool isActive: false
    property int frameWidth: 0
    property int frameHeight: 0
    property int frameRate: 0
    property string routeType: ""  // "direct", "stun", "relay"

    signal clicked()
    signal closeRequested()

    implicitWidth: 250
    implicitHeight: 28

    color: {
        if (isActive) return Theme.surfaceVariant
        if (mouseArea.containsMouse) return Theme.surfaceHover
        return Theme.surface
    }

    border.width: Theme.borderWidthThin
    border.color: isActive ? Theme.primary : Theme.border
    radius: Theme.radiusSmall

    Behavior on color {
        ColorAnimation { duration: Theme.animationDurationFast }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingXSmall
        spacing: Theme.spacingXSmall

        Text {
            text: FluentIconGlyph.devicesGlyph
            font.family: "Segoe Fluent Icons"
            font.pixelSize: 14
            color: Theme.textSecondary
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingXSmall

            Text {
                text: deviceName || deviceId
                font.pixelSize: Theme.fontSizeSmall
                font.weight: isActive ? Font.DemiBold : Font.Normal
                color: Theme.text
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Rectangle {
                width: 7
                height: 7
                radius: 3.5
                visible: connectionState === "connected" && routeType !== ""
                color: (routeType === "direct" || routeType === "stun")
                       ? "#66BB6A" : routeType === "relay" ? "#FFA726"
                       : Theme.textDisabled
            }

            Text {
                text: routeType === "direct" ? "P2P"
                    : routeType === "stun" ? "STUN"
                    : routeType === "relay" ? "Relay" : ""
                font.pixelSize: Theme.fontSizeSmall - 1
                font.family: Theme.fontFamilyMono
                color: Theme.textSecondary
                visible: connectionState === "connected" && routeType !== ""
            }

            Rectangle {
                width: 7
                height: 7
                radius: 3.5
                visible: connectionState === "connected"
                color: {
                    if (ping < 50) return Theme.success
                    if (ping < 100) return Theme.warning
                    return Theme.error
                }

                Behavior on color {
                    ColorAnimation { duration: Theme.animationDurationFast }
                }
            }

            Text {
                text: ping + " ms"
                font.pixelSize: Theme.fontSizeSmall - 1
                font.family: Theme.fontFamilyMono
                color: Theme.textSecondary
                visible: connectionState === "connected"
            }

            Text {
                text: qsTr("Connecting...")
                font.pixelSize: Theme.fontSizeSmall - 1
                color: Theme.textSecondary
                visible: connectionState === "connecting"
            }
        }

        Rectangle {
            Layout.minimumWidth: 16
            Layout.minimumHeight: 16
            width: 16
            height: 16
            radius: 8
            color: closeArea.containsMouse ? Theme.error : "transparent"

            Behavior on color {
                ColorAnimation { duration: Theme.animationDurationFast }
            }

            Text {
                anchors.centerIn: parent
                text: FluentIconGlyph.cancelGlyph
                font.family: "Segoe Fluent Icons"
                font.pixelSize: 8
                color: closeArea.containsMouse ? Theme.textOnPrimary : Theme.textSecondary
            }

            MouseArea {
                id: closeArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: control.closeRequested()
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        anchors.rightMargin: 24
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: control.clicked()
    }

    QDToolTip {
        visible: mouseArea.containsMouse
        text: {
            if (connectionState === "connecting") {
                return qsTr("Connecting...")
            }
            if (frameWidth <= 0 || frameHeight <= 0) {
                return qsTr("Video information is unavailable")
            }
            return qsTr("Resolution: %1 × %2\nFrame rate: %3 fps")
                .arg(frameWidth)
                .arg(frameHeight)
                .arg(frameRate)
        }
    }
}
