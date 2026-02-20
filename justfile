# Starcommand — Self-hosting infrastructure

# Deploy to starcommand server
deploy host="starcommand":
    nix run .#deploy-rs -- .#{{host}}

# Build a host configuration (check it evaluates)
build host="starcommand":
    nixos-rebuild build --flake .#{{host}}

# Run flake checks
test:
    nix flake check

# Format all nix files
fmt:
    nixfmt .

# Edit secrets for a host or user
edit-secrets name:
    SOPS_AGE_KEY_FILE=sops.key sops {{name}}/secrets.yaml

# SSH into starcommand
ssh:
    ssh starcommand
