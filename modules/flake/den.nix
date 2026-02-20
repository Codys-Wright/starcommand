{ inputs, ... }:
{
  imports = [ inputs.den.flakeModule ];

  # Server-only config — no home-manager by default
}
