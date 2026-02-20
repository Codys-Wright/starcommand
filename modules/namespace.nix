{
  inputs,
  den,
  ...
}: {
  imports = [
    (inputs.den.namespace "FTS" true)
    (inputs.den.namespace "deployment" true)
  ];

  _module.args.__findFile = den.lib.__findFile;
}
