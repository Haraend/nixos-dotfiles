# Brave managed policies for web-app outbound links (webapp-open → Zen).
# Applies to every Brave process; origins are scoped so random sites cannot auto-launch.
{
  environment.etc."brave/policies/managed/webapp-open.json".text = builtins.toJSON {
    AutoLaunchProtocolsFromOrigins = [
      {
        protocol = "webapp-open";
        allowed_origins = [
          "https://web.whatsapp.com"
          "https://gemini.google.com"
        ];
      }
    ];
  };
}
