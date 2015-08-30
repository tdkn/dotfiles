function FindProxyForURL(url, host) {
  if (shExpMatch(host, "*.dev.local")) {
    return "PROXY 10.0.1.4";
  } else if(shExpMatch(host, "*.local")) {
    return "PROXY 10.0.1.4";
  }
  return "DIRECT";
}
