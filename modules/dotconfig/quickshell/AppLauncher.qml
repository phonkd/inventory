import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

SearchPopup {
    id: launcher
    placeholderText: "Launch application..."

    property var allEntries: []

    function refreshEntries() {
        var entries = [];
        var apps = DesktopEntries.applications;
        for (var i = 0; i < apps.count; i++) {
            entries.push(apps.get(i));
        }
        allEntries = entries;
    }

    property var filteredEntries: {
        let q = query.toLowerCase().trim();
        if (q === "") return allEntries;
        return allEntries.filter(function(entry) {
            let name = (entry.name || "").toLowerCase();
            let generic = (entry.genericName || "").toLowerCase();
            let comment = (entry.comment || "").toLowerCase();
            let kw = (entry.keywords || []).join(" ").toLowerCase();
            return name.includes(q) || generic.includes(q) || comment.includes(q) || kw.includes(q);
        }).sort(function(a, b) {
            let aName = (a.name || "").toLowerCase();
            let bName = (b.name || "").toLowerCase();
            let aStarts = aName.startsWith(q);
            let bStarts = bName.startsWith(q);
            if (aStarts && !bStarts) return -1;
            if (!aStarts && bStarts) return 1;
            return aName.localeCompare(bName);
        });
    }

    model: filteredEntries.length
    onQueryChanged: currentIndex = 0

    onVisibleChanged: {
        if (visible) refreshEntries();
    }

    delegate: Rectangle {
        required property int index
        width: ListView.view.width
        height: Theme.itemHeight
        radius: Theme.radius / 2
        color: index === launcher.currentIndex ? Theme.bg3 : "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 8

            Image {
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22
                source: {
                    let entry = launcher.filteredEntries[index];
                    if (!entry || !entry.icon) return "";
                    return "image://icon/" + entry.icon;
                }
                sourceSize: Qt.size(22, 22)
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                text: {
                    let entry = launcher.filteredEntries[index];
                    return entry ? entry.name : "";
                }
                color: index === launcher.currentIndex ? Theme.fg1 : Theme.fg0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                elide: Text.ElideRight
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: {
                    let entry = launcher.filteredEntries[index];
                    return entry ? (entry.genericName || "") : "";
                }
                color: Theme.fg2
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
                elide: Text.ElideRight
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: launcher.currentIndex = index
            onClicked: launcher.accepted(index)
        }
    }

    onAccepted: function(index) {
        let entry = filteredEntries[index];
        if (entry) {
            entry.execute();
        }
        close();
    }
}
