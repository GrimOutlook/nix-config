{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.default-programs.file-processing;
in
{
  options.host.default-programs.file-processing.enable =
    lib.mkEnableOption "Enable default file-processing program set";

  config.environment.systemPackages =
    with pkgs;
    lib.mkIf cfg.enable [
      # Command line csv viewer
      # https://github.com/YS-L/csvlens
      csvlens

      # Select, put and delete data from JSON, TOML, YAML, XML, INI, HCL and
      # CSV files with a single tool.
      # https://github.com/tomwright/dasel
      dasel

      # Like jq, but for HTML.
      htmlq

      # Command-line JSON processor
      # https://github.com/jqlang/jq
      jq

      # Conversion between documentation formats
      pandoc

      # A lightweight TUI application to view and query tabular data files, such as CSV, TSV, and parquet.
      # https://github.com/shshemi/tabiew
      tabiew

      # A terminal spreadsheet multitool for discovering and arranging data
      # https://github.com/saulpw/visidata
      visidata

      # Command-line YAML, XML, TOML processor - jq wrapper for YAML/XML/TOML documents
      # https://github.com/kislyuk/yq
      yq
    ];
}
