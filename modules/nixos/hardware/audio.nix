{ ... }:

{
  # Disable PulseAudio (replaced by PipeWire)
  services.pulseaudio.enable = false;

  # Enable PipeWire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;  # PulseAudio compatibility

    # WirePlumber session manager (default, but explicit)
    wireplumber.enable = true;
  };

  # Real-time scheduling for audio (recommended for low latency)
  security.rtkit.enable = true;
}
