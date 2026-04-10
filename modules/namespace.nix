{
  inputs,
  den,
  lib,
  ...
}: {
  imports = [
    (inputs.den.namespace "FTS" true)
  ];

  # Enable den angle brackets syntax in modules
  _module.args.__findFile = den.lib.__findFile;

  # No home-manager in this server flake — empty user classes
  den.schema.user.classes = lib.mkDefault [ ];
}
