{
  config,
  pkgs,
  lib,
  ...
}:

{
  # 1. Audio Setup (PipeWire System-Wide)
  security.rtkit.enable = true;

  services.pipewire = {
    enable = lib.mkForce true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    systemWide = true;
  };

  # 2. Spotifyd Service (Unstable)
  services.spotifyd = {
    enable = true;
    # package = pkgs.unstable.spotifyd; # User removed this
    settings = {
      global = {
        device_name = "nixos-headless";
        backend = "pulseaudio";
        use_mpris = false;
        bitrate = 320;
        cache_path = "/var/cache/spotifyd";
        volume_controller = "softvol";
        zeroconf_port = 57621;
      };
    };
  };

  # 3. EasyEffects Web GUI (X11 + VNC + noVNC)
  # Broadway failed due to Qt dependencies in EasyEffects.
  # We switch to a robust Xvfb -> x11vnc -> noVNC stack.

  users.users.easyeffects = {
    isSystemUser = true;
    group = "easyeffects";
    extraGroups = [
      "audio"
      "pipewire"
    ];
    home = "/var/lib/easyeffects";
    createHome = true;
  };
  users.groups.easyeffects = { };

  systemd.services.headless-gui = {
    description = "EasyEffects Headless Session (noVNC)";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network.target"
      "pipewire.service"
    ];
    requires = [ "pipewire.service" ];

    environment = {
      "DISPLAY" = ":5";
      "PIPEWIRE_RUNTIME_DIR" = "/run/pipewire";
      "XDG_RUNTIME_DIR" = "/run/easyeffects";
      "GDK_BACKEND" = "x11";
      "QT_QPA_PLATFORM" = "xcb";
      "LIBGL_ALWAYS_SOFTWARE" = "1";
      "QT_XCB_GL_INTEGRATION" = "none";
      "QT_QUICK_BACKEND" = "software";
      "QMLSCENE_DEVICE" = "softwarecontext";
    };

    path = with pkgs; [
      bash
      xorg.xorgserver
      xorg.xauth
      x11vnc
      python3Packages.websockify
      dbus
      pkgs.unstable.easyeffects
    ];

    script = ''
      rm -f /tmp/.X5-lock /tmp/.X11-unix/X5

      ${pkgs.dbus}/bin/dbus-run-session -- bash -c '
        # 1. Start Xvfb
        Xvfb :5 -screen 0 1920x1080x24 &
        sleep 2

        # 2. Start VNC Server
        x11vnc -display :5 -forever -shared -nopw -bg -q

        # 3. Start WebSockify (Background)
        ${pkgs.python3Packages.websockify}/bin/websockify -D --web ${pkgs.novnc}/share/webapps/novnc 8085 localhost:5900

        # 4. Start EasyEffects (Blocking)
        exec easyeffects
      '
    '';

    serviceConfig = {
      User = "easyeffects";
      Group = "easyeffects";
      Restart = "always";
      RuntimeDirectory = "easyeffects";
      RuntimeDirectoryMode = "0700";
    };
  };

  # 4. Networking & Firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      57621 # Spotify Connect
      4713 # PulseAudio Network
      8085 # noVNC Web Interface
    ];
    allowedUDPPorts = [ 5353 ];
  };

  # 5. User Permissions
  users.users.spotifyd = {
    extraGroups = [
      "audio"
      "pipewire"
    ];
    isSystemUser = true;
    group = "spotifyd";
  };
  users.groups.spotifyd = { };
}
