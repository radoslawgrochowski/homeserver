{ ... }: {
  services.wyoming.faster-whisper = {
    servers.hass = {
      enable = true;
      # see https://github.com/rhasspy/rhasspy3/blob/master/programs/asr/faster-whisper/script/download.py
      model = "base-int8";
      uri = "tcp://0.0.0.0:10300";
      device = "cpu";
      language = "en";
    };
  };

  services.wyoming.piper = {
    servers.hass = {
      enable = true;
      uri = "tcp://0.0.0.0:10200";
      voice = "en-us-ryan-medium";
    };
  };
}
