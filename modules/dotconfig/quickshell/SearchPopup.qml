import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

PanelWindow {
    id: popup

    property alias query: searchField.text
    property alias placeholderText: searchField.placeholderText
    property alias delegate: listView.delegate
    property alias model: listView.model
    property alias currentIndex: listView.currentIndex
    property alias count: listView.count

    signal accepted(int index)
    signal dismissed()

    visible: false
    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "quickshell-popup"

    exclusionMode: ExclusionMode.Ignore
    focusable: true

    function open() {
        searchField.text = "";
        listView.currentIndex = 0;
        visible = true;
        searchField.forceActiveFocus();
    }

    function close() {
        visible = false;
        dismissed();
    }

    // Click outside to close
    MouseArea {
        anchors.fill: parent
        onClicked: popup.close()
    }

    // Centered card
    Rectangle {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Math.max(parent.height * 0.2, 120)
        width: Theme.windowWidth
        height: contentCol.implicitHeight + Theme.padding * 2
        radius: Theme.radius
        color: Theme.bg0
        border.color: Theme.fg3
        border.width: 1

        // Prevent click-through to dimmer
        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            id: contentCol
            anchors.fill: parent
            anchors.margins: Theme.padding
            spacing: 8

            // Search field
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                radius: Theme.radius / 2
                color: Theme.bg1

                TextInput {
                    id: searchField
                    anchors.fill: parent
                    anchors.margins: 10
                    color: Theme.fg0
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    clip: true
                    verticalAlignment: TextInput.AlignVCenter
                    property string placeholderText: "Search..."

                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        text: searchField.placeholderText
                        color: Theme.fg2
                        font: searchField.font
                        visible: !searchField.text && !searchField.activeFocus
                    }

                    Keys.onEscapePressed: popup.close()
                    Keys.onReturnPressed: {
                        if (listView.count > 0)
                            popup.accepted(listView.currentIndex);
                    }
                    Keys.onDownPressed: {
                        if (listView.currentIndex < listView.count - 1)
                            listView.currentIndex++;
                    }
                    Keys.onUpPressed: {
                        if (listView.currentIndex > 0)
                            listView.currentIndex--;
                    }
                    Keys.onTabPressed: {
                        if (listView.currentIndex < listView.count - 1)
                            listView.currentIndex++;
                        else
                            listView.currentIndex = 0;
                    }
                }
            }

            // Results list
            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(count * Theme.itemHeight, Theme.itemHeight * 8)
                clip: true
                highlightMoveDuration: 80
                visible: count > 0
            }
        }
    }
}
