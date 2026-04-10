# Centralized default aspects applied to all hosts and users
#
# den automatically includes den._.define-user, den._.inputs', and den._.self'
# in den.default — we only add project-specific defaults here.
{ __findFile, den, ... }:
{
  den.default = {
    includes = [
      <FTS/base-host>
      <FTS/hostname>
    ];
  };

  # Enable mutual-provider: host aspects with homeManager blocks automatically
  # contribute to users, and user aspects with nixos blocks contribute to hosts.
  den.ctx.user.includes = [ den._.mutual-provider ];
}
