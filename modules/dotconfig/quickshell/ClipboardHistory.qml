import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

SearchPopup {
    id: clipPopup
    placeholderText: "Search clipboard..."

    property var allItems: []
    property var filteredItems: {
        let q = query.toLowerCase().trim();
        if (q === "") return allItems;
        return allItems.filter(function(item) {
            return item.toLowerCase().includes(q);
        });
    }

    model: filteredItems.length
    onQueryChanged: currentIndex = 0

    Process {
        id: clipList
        command: ["cliphist", "list"]
        stdout: SplitParser {
            onRead: function(line) {
                if (line.trim() !== "") {
                    clipPopup.allItems = clipPopup.allItems.concat([line]);
                }
            }
        }
    }

    Process {
        id: clipDecode
        command: ["sh", "-c", ""]
        stdinEnabled: true
        stdout: StdioCollector {
            onStreamFinished: {
                copyProc.command = ["wl-copy", this.text.trim()];
                copyProc.running = true;
            }
        }
    }

    Process {
        id: copyProc
        command: ["wl-copy"]
    }

    onVisibleChanged: {
        if (visible) {
            allItems = [];
            clipList.running = true;
        }
    }

    delegate: Rectangle {
        required property int index
        width: ListView.view.width
        height: Theme.itemHeight
        radius: Theme.radius / 2
        color: index === clipPopup.currentIndex ? Theme.bg3 : "transparent"

        Text {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            verticalAlignment: Text.AlignVCenter
            text: {
                let item = clipPopup.filteredItems[index];
                return item || "";
            }
            color: index === clipPopup.currentIndex ? Theme.fg1 : Theme.fg0
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            elide: Text.ElideRight
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: clipPopup.currentIndex = index
            onClicked: clipPopup.accepted(index)
        }
    }

    onAccepted: function(index) {
        let item = filteredItems[index];
        if (item) {
            // Pipe selection through cliphist decode then wl-copy
            let escaped = item.replace(/'/g, "'\\''");
            clipDecode.command = ["sh", "-c", "echo '" + escaped + "' | cliphist decode | wl-copy"];
            clipDecode.running = true;
        }
        close();
    }
}
