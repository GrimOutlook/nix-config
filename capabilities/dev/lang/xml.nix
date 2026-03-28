{
  flake.modules.homeManager.lang_xml =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        libxml2
      ];
    };
}
