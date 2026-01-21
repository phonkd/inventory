{ config, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /mnt/Shares 0755 root root -"
    "d /mnt/Shares/Public 2775 smbpublic smbpublic -"
    "d /mnt/Shares/SemiPublic 2770 phonkd phonkd -"
    "d /mnt/Shares/this-is-my-own-private-property-and-you-are-not-welcome-here 0750 phonkd phonkd -" # give group phonkd execute access so jellyfin which is in this group can play videos
  ];

  users.users.smbpublic = {
    isSystemUser = true;
    description = "Samba guest share user";
    group = "smbpublic";
    home = "/var/empty"; # locked, no real home
    #shell = pkgs.util-linux.nologin;
  };

  users.groups.smbpublic = { };
  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "baaaalright";
        "netbios name" = "smbnix";
        "security" = "user";
        #"use sendfile" = "yes";
        #"max protocol" = "smb2";
        # note: localhost is the ipv6 localhost ::1
        "hosts allow" = "192.168.1.0/24 10.89.0.0/24 127.0.0.1 localhost 10.8.0.1/24";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "smbpublic";
        "map to guest" = "bad user";
        "host msdfs" = "no";
      };
      "public" = {
        "path" = "/mnt/Shares/Public";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0664";
        "directory mask" = "2775";
        "force user" = "smbpublic";
        "force group" = "smbpublic";
      };
      "semipublic" = {
        "path" = "/mnt/Shares/SemiPublic";
        "browseable" = "yes";
        "read only" = "yes";
        "guest ok" = "yes";
        "create mask" = "0664";
        "directory mask" = "2775";
        "write list" = "@phonkd phonkd";
        "force create mode" = "0660";
        "force directory mode" = "2770";
        "guest account" = "smbpublic";
      };
      "private" = {
        "path" = "/mnt/Shares/this-is-my-own-private-property-and-you-are-not-welcome-here";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "phonkd";
        "force group" = "phonkd";
      };
      # "tm_share" = {
      #   "path" = "/mnt/Shares/GD-leve8";
      #   "valid users" = "username";
      #   "public" = "no";
      #   "writeable" = "yes";
      #   "force user" = "username";
      #   "fruit:aapl" = "yes";
      #   "fruit:time machine" = "yes";
      #   "vfs objects" = "catia fruit streams_xattr";
      # };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
  #macos
  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };
  fileSystems."/mnt/Shares" = {
    device = "/dev/disk/by-id/virtio-vm-202-disk-1";
    fsType = "ext4";
    autoFormat = true;
    autoResize = true;
    options = [
      # If you don't have this options attribute, it'll default to "defaults"
      # boot options for fstab. Search up fstab mount options you can use
      "users" # Allows any user to mount and unmount
      "nofail" # Prevent system from failing if this drive doesn't mount

    ];
  };

}
