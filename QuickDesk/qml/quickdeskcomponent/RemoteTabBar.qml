// Remote Tab Bar Component - Tab bar for remote desktop windows
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../component"
import "."

Rectangle {
    id: control
    
    // Properties
    property var connectionModel: null  // ConnectionListModel (C++ QAbstractListModel)
    property int currentIndex: 0
    property var performanceStatsMap: ({})
    property int statsVersion: 0  // Used to trigger updates
    property bool pinned: false
    
    // Signals
    signal tabClicked(int index)
    signal tabCloseRequested(int index)
    signal newTabRequested()
    signal pinToggled()
    
    // Style
    color: Theme.surface
    border.width: Theme.borderWidthThin
    border.color: Theme.border
    
    implicitHeight: 32
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: 2
        spacing: Theme.spacingXSmall
        
        // Scrollable tab area
        ListView {
            id: tabListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            orientation: ListView.Horizontal
            spacing: Theme.spacingXSmall
            clip: true
            
            model: control.connectionModel
            
            delegate: RemoteTab {
                required property int index
                required property string deviceId
                required property string name
                required property string state
                
                deviceName: name || deviceId || ""
                connectionState: state || "connected"
                isActive: index === control.currentIndex
                
                // Get performance stats from map
                property var stats: {
                    var _ = control.statsVersion
                    return control.performanceStatsMap[deviceId] || { ping: 0 }
                }
                ping: stats.ping
                routeType: stats.routeType || ""
                frameWidth: stats.frameWidth || 0
                frameHeight: stats.frameHeight || 0
                frameRate: stats.frameRate || 0
                
                onClicked: {
                    control.tabClicked(index)
                }
                
                onCloseRequested: {
                    control.tabCloseRequested(index)
                }
            }
            
            // Scroll buttons (if needed)
            ScrollBar.horizontal: ScrollBar {
                policy: ScrollBar.AlwaysOff
            }
        }

        QDIconButton {
            Layout.alignment: Qt.AlignVCenter
            iconSource: control.pinned ? FluentIconGlyph.pinnedFillGlyph : FluentIconGlyph.pinGlyph
            iconColor: control.pinned ? Theme.primary : Theme.textSecondary
            iconHoverColor: control.pinned ? Theme.primaryHover : Theme.primary
            toolTipText: control.pinned
                ? qsTr("Auto-hide tab bar")
                : qsTr("Keep tab bar visible")
            buttonSize: QDIconButton.Size.Small
            buttonStyle: QDIconButton.Style.Transparent
            onClicked: control.pinToggled()
        }
    }
}
