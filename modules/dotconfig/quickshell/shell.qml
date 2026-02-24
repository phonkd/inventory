import Quickshell
import Quickshell.Hyprland

ShellRoot {
    AppLauncher {
        id: appLauncher
    }

    AudioSelector {
        id: audioSelector
    }

    ClipboardHistory {
        id: clipboardHistory
    }

    BluetoothManager {
        id: bluetoothManager
    }

    YubiKeyOath {
        id: yubiKeyOath
    }

    // Global shortcuts registered via Hyprland protocol
    // Bind in hyprland.conf: bind = SUPER, D, global, quickshell:launcher
    GlobalShortcut {
        name: "launcher"
        description: "Application launcher"
        onPressed: {
            if (appLauncher.visible) appLauncher.close();
            else appLauncher.open();
        }
    }

    GlobalShortcut {
        name: "audio"
        description: "Audio output selector"
        onPressed: {
            if (audioSelector.visible) audioSelector.close();
            else audioSelector.open();
        }
    }

    GlobalShortcut {
        name: "clipboard"
        description: "Clipboard history"
        onPressed: {
            if (clipboardHistory.visible) clipboardHistory.close();
            else clipboardHistory.open();
        }
    }

    GlobalShortcut {
        name: "bluetooth"
        description: "Bluetooth device manager"
        onPressed: {
            if (bluetoothManager.visible) bluetoothManager.close();
            else bluetoothManager.open();
        }
    }

    GlobalShortcut {
        name: "yubikey"
        description: "YubiKey OATH codes"
        onPressed: {
            if (yubiKeyOath.visible) yubiKeyOath.close();
            else yubiKeyOath.open();
        }
    }
}
