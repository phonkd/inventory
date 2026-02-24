import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

SearchPopup {
    id: ykPopup
    placeholderText: "Search YubiKey OATH accounts..."

    property var allAccounts: []
    property string serial: ""

    property var filteredAccounts: {
        let q = query.toLowerCase().trim();
        if (q === "") return allAccounts;
        return allAccounts.filter(function(acc) {
            return acc.toLowerCase().includes(q);
        });
    }

    model: filteredAccounts.length
    onQueryChanged: currentIndex = 0

    // Step 1: Get serial
    Process {
        id: ykList
        command: ["ykman", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                let output = this.text.trim();
                if (output === "") return;
                // Extract serial from first yubikey
                let match = output.match(/Serial:\s*(\d+)/);
                if (match) {
                    ykPopup.serial = match[1];
                    ykAccounts.command = ["ykman", "--device", ykPopup.serial, "oath", "accounts", "list"];
                    ykAccounts.running = true;
                }
            }
        }
    }

    // Step 2: List accounts
    Process {
        id: ykAccounts
        command: ["ykman", "oath", "accounts", "list"]
        stdout: SplitParser {
            onRead: function(line) {
                let trimmed = line.replace(/, TOTP$/, "").trim();
                if (trimmed !== "") {
                    ykPopup.allAccounts = ykPopup.allAccounts.concat([trimmed]);
                }
            }
        }
    }

    // Step 3: Get code and copy
    Process {
        id: ykCode
        command: ["ykman", "oath", "accounts", "code"]
        stdout: StdioCollector {
            onStreamFinished: {
                let output = this.text.trim();
                // Extract the code (last space-separated field)
                let parts = output.split(/\s+/);
                let code = parts[parts.length - 1];
                if (code) {
                    clipCopy.command = ["wl-copy", code];
                    clipCopy.running = true;
                }
            }
        }
    }

    Process {
        id: clipCopy
        command: ["wl-copy"]
    }

    onVisibleChanged: {
        if (visible) {
            allAccounts = [];
            serial = "";
            ykList.running = true;
        }
    }

    delegate: Rectangle {
        required property int index
        width: ListView.view.width
        height: Theme.itemHeight
        radius: Theme.radius / 2
        color: index === ykPopup.currentIndex ? Theme.bg3 : "transparent"

        Text {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            verticalAlignment: Text.AlignVCenter
            text: {
                let acc = ykPopup.filteredAccounts[index];
                return acc || "";
            }
            color: index === ykPopup.currentIndex ? Theme.fg1 : Theme.fg0
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            elide: Text.ElideRight
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: ykPopup.currentIndex = index
            onClicked: ykPopup.accepted(index)
        }
    }

    onAccepted: function(index) {
        let account = filteredAccounts[index];
        if (account && serial) {
            ykCode.command = ["ykman", "--device", serial, "oath", "accounts", "code", account];
            ykCode.running = true;
        }
        close();
    }
}
