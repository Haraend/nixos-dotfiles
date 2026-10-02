{ ... }:

{
  services.fprintd.enable = true;

  security.pam.services = {
    # Lockscreen-only: Noctalia uses this via NOCTALIA_PAM_SERVICE
    noctalia-lock.fprintAuth = true;

    # Explicitly off everywhere else (fprintd.enable defaults these to true)
    greetd.fprintAuth = false;
    login.fprintAuth = false;
    sudo.fprintAuth = false;
    su.fprintAuth = false;
  };
}
