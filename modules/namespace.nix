{
  inputs,
  den,
  ...
}: {
  imports = [
    (inputs.den.namespace "FTS" true)
  ];

  _module.args.__findFile = den.lib.__findFile;
}
