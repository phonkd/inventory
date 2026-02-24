import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

SearchPopup {
    id: audioPopup
    placeholderText: "Select audio output..."

    property var sinkNodes: []

    function refreshSinks() {
        var nodes = [];
        if (!Pipewire.ready) return;
        for (var i = 0; i < Pipewire.nodes.count; i++) {
            var node = Pipewire.nodes.get(i);
            if (node && node.audio && node.isSink && !node.isStream) {
                nodes.push(node);
            }
        }
        sinkNodes = nodes;
    }

    property var filteredNodes: {
        let q = query.toLowerCase().trim();
        if (q === "") return sinkNodes;
        return sinkNodes.filter(function(node) {
            let desc = (node.description || "").toLowerCase();
            let name = (node.name || "").toLowerCase();
            let nick = (node.nickname || "").toLowerCase();
            return desc.includes(q) || name.includes(q) || nick.includes(q);
        });
    }

    model: filteredNodes.length
    onQueryChanged: currentIndex = 0

    onVisibleChanged: {
        if (visible) {
            refreshSinks();
            // Pre-select current default
            var def = Pipewire.defaultAudioSink;
            if (def) {
                for (var i = 0; i < filteredNodes.length; i++) {
                    if (filteredNodes[i].name === def.name) {
                        currentIndex = i;
                        break;
                    }
                }
            }
        }
    }

    delegate: Rectangle {
        required property int index
        width: ListView.view.width
        height: Theme.itemHeight
        radius: Theme.radius / 2
        color: index === audioPopup.currentIndex ? Theme.bg3 : "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 8

            Rectangle {
                Layout.preferredWidth: 8
                Layout.preferredHeight: 8
                radius: 4
                color: {
                    let node = audioPopup.filteredNodes[index];
                    let def = Pipewire.defaultAudioSink;
                    return (def && node && node.name === def.name) ? Theme.bg3 : "transparent";
                }
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                text: {
                    let node = audioPopup.filteredNodes[index];
                    if (!node) return "";
                    return node.description || node.nickname || node.name;
                }
                color: index === audioPopup.currentIndex ? Theme.fg1 : Theme.fg0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                elide: Text.ElideRight
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: audioPopup.currentIndex = index
            onClicked: audioPopup.accepted(index)
        }
    }

    onAccepted: function(index) {
        let node = filteredNodes[index];
        if (node) {
            Pipewire.preferredDefaultAudioSink = node;
        }
        close();
    }
}
