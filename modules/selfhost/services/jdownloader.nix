# JDownloader Service
# Headless download manager with web UI via OCI container
{
  FTS,
  inputs,
  lib,
  ...
}:
{
  FTS.selfhost._.jdownloader =
    {
      domain,
      subdomain,
      # Optional parameters
      ssl ? null,
      sslCertName ? domain,
      downloadDir ? "/mnt/storage/downloads",
      port ? 5800,
      # SSO integration
      authEndpoint ? null,
      ...
    }@args:
    {
      class,
      aspect-chain,
    }:
    {
      description = ''
        JDownloader 2 - Download manager with web UI.

        Features:
        - Browser-based GUI (noVNC)
        - MyJDownloader remote management
        - Link grabbing and extraction
        - Automatic reconnect and captcha solving

        Access at https://${subdomain}.${domain}
      '';

      nixos =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          fqdn = "${subdomain}.${domain}";
          sslCert = if ssl != null then ssl else config.shb.certs.certs.letsencrypt.${sslCertName};
        in
        {
          # Enable podman for OCI containers
          virtualisation.podman.enable = true;
          virtualisation.oci-containers.backend = "podman";

          # JDownloader container
          virtualisation.oci-containers.containers.jdownloader = {
            image = "jlesage/jdownloader-2:latest";
            autoStart = true;
            ports = [
              "127.0.0.1:${toString port}:5800"
            ];
            volumes = [
              "/var/lib/jdownloader:/config:rw"
              "${downloadDir}:/output:rw"
            ];
            environment = {
              TZ = "America/Chicago";
              KEEP_APP_RUNNING = "1";
              CLEAN_TMP_DIR = "1";
              # Dark theme for web UI
              DARK_MODE = "1";
              # Set reasonable memory limits
              JD_JAVA_OPTIONS = "-Xms256m -Xmx1024m";
            };
          };

          # Ensure directories exist
          systemd.tmpfiles.rules = [
            "d /var/lib/jdownloader 0755 root root -"
            "d ${downloadDir} 0777 root root -"
          ];

          # Nginx reverse proxy
          services.nginx.virtualHosts."${fqdn}" = {
            forceSSL = true;
            sslCertificate = "${sslCert.paths.cert}";
            sslCertificateKey = "${sslCert.paths.key}";

            locations."/" = {
              proxyPass = "http://127.0.0.1:${toString port}";
              proxyWebsockets = true;
              extraConfig = ''
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
              ''
              + lib.optionalString (authEndpoint != null) ''
                # Authelia SSO
                auth_request /authelia;
                auth_request_set $target_url $scheme://$http_host$request_uri;
                auth_request_set $user $upstream_http_remote_user;
                auth_request_set $groups $upstream_http_remote_groups;
                error_page 401 =302 ${authEndpoint}/?rd=$target_url;
              '';
            };

            # Authelia auth endpoint
            locations."/authelia" = lib.mkIf (authEndpoint != null) {
              extraConfig = ''
                internal;
                proxy_pass ${authEndpoint}/api/verify;
                proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header Content-Length "";
                proxy_pass_request_body off;
              '';
            };
          };
        };
    };
}
