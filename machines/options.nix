{ lib, ... }:

{
  options.label = {
    labels = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Labels to categorize machines.";
    };
  };
}
