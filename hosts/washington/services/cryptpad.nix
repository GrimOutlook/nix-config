{ host_info, ... }:
let
  ports = host_info.services.cryptpad.ports;
in
{
  services.cryptpad = {
    enable = true;
    settings = {
      httpUnsafeOrigin = ports.web.secure-fqdn;
      httpSafeOrigin = ports.websocket.secure-fqdn;

      httpPort = ports.web.number;
      websocketPort = ports.websocket.number;
    };
  };
}
