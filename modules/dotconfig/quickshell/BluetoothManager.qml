import Quickshell
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts

SearchPopup {
    id: btPopup
    placeholderText: "Search bluetooth devices..."

    property var allDevices: []

    function refreshDevices() {
        var devs = [];
        var adapter = Bluetooth.defaultAdapter;
        if (!adapter) return;
        for (var i = 0; i < adapter.devices.count; i++) {
            devs.push(adapter.devices.get(i));
        }
        allDevices = devs;
    }

    property var filteredDevices: {
        let q = query.toLowerCase().trim();
        if (q === "") return allDevices;
        return allDevices.filter(function(dev) {
            let name = (dev.name || "").toLowerCase();
            let addr = (dev.address || "").toLowerCase();
            return name.includes(q) || addr.includes(q);
        });
    }

    model: filteredDevices.length
    onQueryChanged: currentIndex = 0

    onVisibleChanged: {
        if (visible) refreshDevices();
    }

    delegate: Rectangle {
        required property int index
        width: ListView.view.width
        height: Theme.itemHeight
        radius: Theme.radius / 2
        color: index === btPopup.currentIndex ? Theme.bg3 : "transparent"

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
                    let dev = btPopup.filteredDevices[index];
                    if (!dev) return "transparent";
                    return dev.connected ? "#4CAF50" : Theme.fg3;
                }
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                text: {
                    let dev = btPopup.filteredDevices[index];
                    if (!dev) return "";
                    return dev.name || dev.address;
                }
                color: index === btPopup.currentIndex ? Theme.fg1 : Theme.fg0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                elide: Text.ElideRight
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: {
                    let dev = btPopup.filteredDevices[index];
                    if (!dev || !dev.batteryAvailable) return "";
                    return Math.round(dev.battery * 100) + "%";
                }
                color: Theme.fg2
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: {
                    let dev = btPopup.filteredDevices[index];
                    if (!dev) return "";
                    if (dev.connected) return "connected";
                    if (dev.paired) return "paired";
                    return "";
                }
                color: Theme.fg2
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: btPopup.currentIndex = index
            onClicked: btPopup.accepted(index)
        }
    }

    onAccepted: function(index) {
        let dev = filteredDevices[index];
        if (dev) {
            if (dev.connected) {
                dev.disconnect();
            } else {
                dev.connect();
            }
        }
        close();
    }
}
