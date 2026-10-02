# Docker and Docker Compose configuration
{ pkgs, vars, ... }:

{
  # Enable Docker daemon
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false; # start on demand: sudo systemctl start docker
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # Add user to docker group (run docker without sudo)
  users.users.${vars.username}.extraGroups = [ "docker" ];

  # Docker Compose
  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}
