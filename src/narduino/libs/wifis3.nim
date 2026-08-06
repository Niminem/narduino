## Bindings for the Arduino WiFiS3 library (WiFiS3.h).
##
## Wraps the CWifi, WiFiClient, WiFiServer, WiFiUDP, and WiFiSSLClient
## classes for the Arduino UNO R4 WiFi board's ESP32-S3 Wi-Fi
## co-processor. Bundled with the UNO R4 WiFi board package; no extra
## installation required.
## Ref: https://github.com/arduino/ArduinoCore-renesas/tree/main/libraries/WiFiS3
##
## Provides:
## - WiFi station and access-point management (CWifi / global ``WiFi``)
## - TCP client connections (WiFiClient)
## - TCP server hosting (WiFiServer)
## - UDP datagram communication (WiFiUDP)
## - SSL/TLS encrypted connections (WiFiSSLClient)
##
## WiFiSSLClient inherits from WiFiClient so all WiFiClient procs
## (connect, read, write, print, …) work on it directly; C++ virtual
## dispatch ensures the SSL implementations are called.
##
## The ``print`` / ``println`` procs come from the Arduino ``Print``
## base class inherited by WiFiClient and WiFiServer. Only the
## ``cstring`` overloads are exposed; use ``write`` for binary data.
##
## **Not bound:** WiFiFileSystem (modem flash filesystem for storing
## custom CA certificates). For typical TLS usage, ``setCACert`` on
## WiFiSSLClient is sufficient.

const header = "WiFiS3.h"

# ==========================================================================
# Constants
# ==========================================================================

const
  WL_SSID_MAX_LENGTH* = 32
    ## Maximum characters in an SSID.
  WL_WPA_KEY_MAX_LENGTH* = 63
    ## Maximum characters in a WPA passphrase (8–63).
  WL_WEP_KEY_MAX_LENGTH* = 13
    ## Maximum bytes in a WEP key (5 or 13).
  WL_MAC_ADDR_LENGTH* = 6
    ## Bytes in a MAC / BSSID address.
  WL_IPV4_LENGTH* = 4
    ## Bytes in an IPv4 address.
  WIFI_FIRMWARE_LATEST_VERSION* = "0.6.0"
    ## Expected firmware version string for the ESP32-S3 co-processor.
  WIFI_MAX_SSID_COUNT* = 10
    ## Maximum access points returned by ``scanNetworks``.

# -- Connection status (wl_status_t) --

const
  WL_IDLE_STATUS*: uint8 = 0
    ## Temporary status between state changes.
  WL_NO_SSID_AVAIL*: uint8 = 1
    ## Configured SSID not found during scan.
  WL_SCAN_COMPLETED*: uint8 = 2
    ## Network scan finished.
  WL_CONNECTED*: uint8 = 3
    ## Successfully connected to a network.
  WL_CONNECT_FAILED*: uint8 = 4
    ## Connection attempt failed.
  WL_CONNECTION_LOST*: uint8 = 5
    ## Previously established connection was lost.
  WL_DISCONNECTED*: uint8 = 6
    ## Explicitly disconnected or not yet connected.
  WL_AP_LISTENING*: uint8 = 7
    ## Access point is active and listening for clients.
  WL_AP_CONNECTED*: uint8 = 8
    ## A client has connected to the access point.
  WL_AP_FAILED*: uint8 = 9
    ## Access point creation failed.
  WL_NO_SHIELD*: uint8 = 255
    ## WiFi module not detected.
  WL_NO_MODULE* = WL_NO_SHIELD
    ## Alias for ``WL_NO_SHIELD``.

# -- Encryption types (wl_enc_type) --

const
  ENC_TYPE_WEP*: uint8 = 0
    ## Wired Equivalent Privacy (legacy, insecure).
  ENC_TYPE_WPA*: uint8 = 1
    ## WPA with TKIP cipher.
  ENC_TYPE_TKIP* = ENC_TYPE_WPA
    ## Alias for ``ENC_TYPE_WPA``.
  ENC_TYPE_WPA2*: uint8 = 2
    ## WPA2 with CCMP (AES) cipher.
  ENC_TYPE_CCMP* = ENC_TYPE_WPA2
    ## Alias for ``ENC_TYPE_WPA2``.
  ENC_TYPE_WPA2_ENTERPRISE*: uint8 = 3
    ## WPA2-Enterprise (802.1X / RADIUS).
  ENC_TYPE_WPA3*: uint8 = 4
    ## WPA3 (SAE).
  ENC_TYPE_NONE*: uint8 = 5
    ## Open network, no encryption.
  ENC_TYPE_AUTO*: uint8 = 6
    ## Automatic encryption selection.
  ENC_TYPE_UNKNOWN*: uint8 = 255
    ## Encryption type could not be determined.

# -- Ping result codes (wl_ping_result_t) --

const
  WL_PING_DEST_UNREACHABLE*: cint = -1
    ## Destination host unreachable.
  WL_PING_TIMEOUT*: cint = -2
    ## No reply within the timeout window.
  WL_PING_UNKNOWN_HOST*: cint = -3
    ## DNS resolution of the host failed.
  WL_PING_ERROR*: cint = -4
    ## General ping failure.

# ==========================================================================
# Types
# ==========================================================================

type
  IPAddress* {.importcpp: "IPAddress", header: header.} = object
    ## Arduino IPv4 address (from the core library, included via WiFiS3.h).

  CWifi* {.importcpp: "CWifi", header: header.} = object
    ## Wi-Fi manager. Use the pre-instantiated global ``WiFi``.

  WiFiClient* {.importcpp: "WiFiClient", header: header, inheritable.} = object
    ## TCP client for unencrypted connections.

  WiFiServer* {.importcpp: "WiFiServer", header: header.} = object
    ## TCP server that accepts incoming WiFiClient connections.

  WiFiUDP* {.importcpp: "WiFiUDP", header: header.} = object
    ## UDP socket for connectionless datagram I/O.

  WiFiSSLClient* {.importcpp: "WiFiSSLClient",
                   header: header.} = object of WiFiClient
    ## TCP client with SSL/TLS encryption. Inherits every WiFiClient proc;
    ## C++ virtual dispatch ensures the SSL implementations are called.

# ==========================================================================
# IPAddress
# ==========================================================================

proc initIPAddress*(): IPAddress
  {.importcpp: "IPAddress()", constructor, header: header.}
  ## Default address (0.0.0.0).

proc initIPAddress*(a, b, c, d: uint8): IPAddress
  {.importcpp: "IPAddress(@)", constructor, header: header.}
  ## Construct from four octets, e.g. ``initIPAddress(192, 168, 1, 1)``.

proc initIPAddress*(raw: uint32): IPAddress
  {.importcpp: "IPAddress(@)", constructor, header: header.}
  ## Construct from a raw 32-bit value (host byte order).

proc `[]`*(ip: IPAddress; idx: cint): uint8
  {.importcpp: "#[#]", header: header.}
  ## Read a single octet by index (0..3).

# ==========================================================================
# CWifi – constructor & static helpers
# ==========================================================================

proc initCWifi*(): CWifi
  {.importcpp: "CWifi()", constructor, header: header.}
  ## Create a CWifi instance. Normally the global ``WiFi`` is used instead.

proc firmwareVersion*(_: typedesc[CWifi]): cstring
  {.importcpp: "CWifi::firmwareVersion()", header: header.}
  ## Returns the ESP32-S3 firmware version string (static method).

# ==========================================================================
# CWifi – instance methods
# ==========================================================================

{.push header: header.}

proc firmwareVersionU32*(w: var CWifi): uint32 {.importcpp.}
  ## Firmware version as ``0x00_MAJOR_MINOR_PATCH``.

# -- Ping --

proc ping*(w: var CWifi; ip: IPAddress; ttl: uint8 = 128;
           count: uint8 = 1): cint {.importcpp.}
  ## Ping by IP address. Returns round-trip time in ms or a ``WL_PING_*`` error.

proc ping*(w: var CWifi; host: cstring; ttl: uint8 = 128;
           count: uint8 = 1): cint {.importcpp.}
  ## Ping by hostname. Returns round-trip time in ms or a ``WL_PING_*`` error.

# -- Station connect / disconnect --

proc begin*(w: var CWifi; ssid: cstring): cint {.importcpp, discardable.}
  ## Connect to an open (no-password) network.
  ## Returns ``WL_CONNECTED`` on success, ``WL_CONNECT_FAILED`` on failure.

proc begin*(w: var CWifi; ssid, passphrase: cstring): cint
  {.importcpp, discardable.}
  ## Connect to a WPA/WPA2-secured network.
  ## Returns ``WL_CONNECTED`` on success, ``WL_CONNECT_FAILED`` on failure.

proc disconnect*(w: var CWifi): cint {.importcpp, discardable.}
  ## Disconnect from the current network. Returns 1 on success.

proc `end`*(w: var CWifi) {.importcpp.}
  ## Reset and power-down the WiFi module.

# -- Access-point mode --

proc beginAP*(w: var CWifi; ssid: cstring): uint8 {.importcpp, discardable.}
  ## Start an open access point on channel 1.

proc beginAP*(w: var CWifi; ssid: cstring; channel: uint8): uint8
  {.importcpp, discardable.}
  ## Start an open access point on a specific channel.

proc beginAP*(w: var CWifi; ssid, passphrase: cstring): uint8
  {.importcpp, discardable.}
  ## Start a password-protected access point on channel 1.

proc beginAP*(w: var CWifi; ssid, passphrase: cstring;
              channel: uint8): uint8 {.importcpp, discardable.}
  ## Start a password-protected access point on a specific channel.
  ## Returns ``WL_AP_LISTENING`` on success, ``WL_AP_FAILED`` on error.

# -- Static IP / DNS configuration --

proc config*(w: var CWifi; localIp: IPAddress) {.importcpp.}
  ## Assign a static IP address (disables DHCP).

proc config*(w: var CWifi; localIp, dnsServer: IPAddress) {.importcpp.}
  ## Static IP with a custom DNS server.

proc config*(w: var CWifi; localIp, dnsServer, gateway: IPAddress) {.importcpp.}
  ## Static IP with custom DNS and gateway.

proc config*(w: var CWifi; localIp, dnsServer, gateway,
             subnet: IPAddress) {.importcpp.}
  ## Static IP with custom DNS, gateway, and subnet mask.

proc setDNS*(w: var CWifi; dns1: IPAddress) {.importcpp.}
  ## Set the primary DNS server.

proc setDNS*(w: var CWifi; dns1, dns2: IPAddress) {.importcpp.}
  ## Set primary and secondary DNS servers.

proc setHostname*(w: var CWifi; name: cstring) {.importcpp.}
  ## Set the hostname sent in DHCP requests.

# -- Network information --

proc macAddress*(w: var CWifi; mac: ptr uint8): ptr uint8 {.importcpp.}
  ## Write the 6-byte MAC into ``mac`` and return the same pointer.

proc localIP*(w: var CWifi): IPAddress {.importcpp.}
  ## Local IP address assigned to the device.

proc subnetMask*(w: var CWifi): IPAddress {.importcpp.}
  ## Subnet mask of the current connection.

proc gatewayIP*(w: var CWifi): IPAddress {.importcpp.}
  ## Gateway IP address of the current connection.

proc dnsIP*(w: var CWifi; n: cint = 0): IPAddress {.importcpp.}
  ## Primary (n = 0) or secondary (n = 1) DNS server address.

proc softAPIP*(w: var CWifi): IPAddress {.importcpp.}
  ## IP address of the soft access point interface.

proc SSID*(w: var CWifi): cstring {.importcpp.}
  ## SSID of the current connection or SoftAP.

proc BSSID*(w: var CWifi; bssid: ptr uint8): ptr uint8 {.importcpp.}
  ## Write the 6-byte BSSID into ``bssid``.

proc RSSI*(w: var CWifi): int32 {.importcpp.}
  ## Signal strength (dBm) of the current connection.

proc softAPSSID*(w: var CWifi): cstring {.importcpp.}
  ## SSID of the soft access point.

# -- Scanning --

proc scanNetworks*(w: var CWifi): int8 {.importcpp.}
  ## Scan for nearby networks; returns the count (negative on error).

proc SSID*(w: var CWifi; networkItem: uint8): cstring {.importcpp.}
  ## SSID of a scanned network by index.

proc encryptionType*(w: var CWifi; networkItem: uint8): uint8 {.importcpp.}
  ## Encryption type of a scanned network (one of ``ENC_TYPE_*``).

proc encryptionType*(w: var CWifi): uint8 {.importcpp.}
  ## Encryption type of the current connection.

proc BSSID*(w: var CWifi; networkItem: uint8;
            bssid: ptr uint8): ptr uint8 {.importcpp.}
  ## Write the 6-byte BSSID of a scanned network into ``bssid``.

proc channel*(w: var CWifi; networkItem: uint8): uint8 {.importcpp.}
  ## Channel number of a scanned network.

proc RSSI*(w: var CWifi; networkItem: uint8): int32 {.importcpp.}
  ## Signal strength (dBm) of a scanned network.

# -- Status / utility --

proc status*(w: var CWifi): uint8 {.importcpp.}
  ## One of the ``WL_*`` status constants.

proc reasonCode*(w: var CWifi): uint8 {.importcpp.}
  ## Deauthentication reason code.

proc hostByName*(w: var CWifi; hostname: cstring;
                 aResult: var IPAddress): cint {.importcpp.}
  ## DNS lookup. Stores the address in ``aResult``; returns 1 on success.

proc getTime*(w: var CWifi): culong {.importcpp.}
  ## Epoch seconds from the modem's NTP cache.

proc setTimeout*(w: var CWifi; timeout: culong) {.importcpp.}
  ## Set the connection timeout in milliseconds.

{.pop.}  # CWifi header

# ==========================================================================
# WiFiClient
# ==========================================================================

proc initWiFiClient*(): WiFiClient
  {.importcpp: "WiFiClient()", constructor, header: header.}
  ## Create an unconnected TCP client.

{.push header: header.}

proc connect*(c: var WiFiClient; ip: IPAddress; port: uint16): cint
  {.importcpp, discardable.}
  ## Connect to a server by IP and port. Returns 1 on success.

proc connect*(c: var WiFiClient; host: cstring; port: uint16): cint
  {.importcpp, discardable.}
  ## Connect to a server by hostname and port. Returns 1 on success.

proc write*(c: var WiFiClient; b: uint8): csize_t {.importcpp, discardable.}
  ## Write a single byte.

proc write*(c: var WiFiClient; buf: ptr uint8; size: csize_t): csize_t
  {.importcpp, discardable.}
  ## Write a raw byte buffer.

proc write*(c: var WiFiClient; str: cstring): csize_t
  {.importcpp, discardable.}
  ## Write a null-terminated string (inherited from Print).

proc available*(c: var WiFiClient): cint {.importcpp.}
  ## Bytes available for reading without blocking.

proc read*(c: var WiFiClient): cint {.importcpp.}
  ## Read one byte; returns -1 when nothing is available.

proc read*(c: var WiFiClient; buf: ptr uint8; size: csize_t): cint
  {.importcpp.}
  ## Read up to ``size`` bytes into ``buf``; returns bytes actually read.

proc peek*(c: var WiFiClient): cint {.importcpp.}
  ## Peek at the next byte without consuming it; -1 if empty.

proc flush*(c: var WiFiClient) {.importcpp.}
  ## Flush the transmit buffer.

proc stop*(c: var WiFiClient) {.importcpp.}
  ## Close the connection and clear receive buffer.

proc connected*(c: var WiFiClient): uint8 {.importcpp.}
  ## Returns 1 if connected, 0 otherwise.

proc isValid*(c: var WiFiClient): bool
  {.importcpp: "static_cast<bool>(#)".}
  ## True if the client holds a valid socket (C++ ``operator bool``).
  ## Distinct from ``connected``: a disconnected client may still be
  ## valid and hold buffered unread data.

proc remoteIP*(c: var WiFiClient): IPAddress {.importcpp.}
  ## IP address of the remote server.

proc remotePort*(c: var WiFiClient): uint16 {.importcpp.}
  ## Port number of the remote server.

proc setConnectionTimeout*(c: var WiFiClient; timeout: cint) {.importcpp.}
  ## Set the connection timeout in milliseconds.

proc `==`*(a, b: WiFiClient): bool
  {.importcpp: "# == #", header: header.}
  ## True if both clients refer to the same underlying socket.

proc `!=`*(a, b: WiFiClient): bool
  {.importcpp: "# != #", header: header.}
  ## True if the clients refer to different sockets.

# -- Print helpers (inherited from Arduino Print class) --

proc print*(c: var WiFiClient; s: cstring): csize_t
  {.importcpp, discardable.}
  ## Send a string without a line ending.

proc println*(c: var WiFiClient; s: cstring): csize_t
  {.importcpp, discardable.}
  ## Send a string followed by CR+LF.

proc println*(c: var WiFiClient): csize_t {.importcpp, discardable.}
  ## Send a bare CR+LF line ending.

{.pop.}  # WiFiClient header

# ==========================================================================
# WiFiServer
# ==========================================================================

proc initWiFiServer*(): WiFiServer
  {.importcpp: "WiFiServer()", constructor, header: header.}
  ## Create a server with no default port (call ``begin(port)`` later).

proc initWiFiServer*(port: cint): WiFiServer
  {.importcpp: "WiFiServer(@)", constructor, header: header.}
  ## Create a server that will listen on ``port``.

{.push header: header.}

proc available*(s: var WiFiServer): WiFiClient {.importcpp.}
  ## Returns the next pending client connection.

proc accept*(s: var WiFiServer): WiFiClient {.importcpp.}
  ## Accept an incoming client connection.

proc begin*(s: var WiFiServer; port: cint) {.importcpp.}
  ## Start listening on the specified port.

proc begin*(s: var WiFiServer) {.importcpp.}
  ## Start listening on the port given to the constructor.

proc write*(s: var WiFiServer; b: uint8): csize_t {.importcpp, discardable.}
  ## Write a single byte to all connected clients.

proc write*(s: var WiFiServer; buf: ptr uint8; size: csize_t): csize_t
  {.importcpp, discardable.}
  ## Write a raw byte buffer to all connected clients.

proc write*(s: var WiFiServer; str: cstring): csize_t
  {.importcpp, discardable.}
  ## Write a null-terminated string to all connected clients.

proc `end`*(s: var WiFiServer) {.importcpp.}
  ## Stop the server and close the listening socket.

proc isValid*(s: var WiFiServer): bool
  {.importcpp: "static_cast<bool>(#)".}
  ## True if the server socket is open (C++ ``explicit operator bool``).

proc `==`*(a, b: WiFiServer): bool
  {.importcpp: "# == #", header: header.}
  ## True if both servers refer to the same underlying socket.

proc `!=`*(a, b: WiFiServer): bool
  {.importcpp: "# != #", header: header.}
  ## True if the servers refer to different sockets.

# -- Print helpers --

proc print*(s: var WiFiServer; str: cstring): csize_t
  {.importcpp, discardable.}
  ## Send a string to all connected clients without a line ending.

proc println*(s: var WiFiServer; str: cstring): csize_t
  {.importcpp, discardable.}
  ## Send a string followed by CR+LF to all connected clients.

proc println*(s: var WiFiServer): csize_t {.importcpp, discardable.}
  ## Send a bare CR+LF to all connected clients.

{.pop.}  # WiFiServer header

# ==========================================================================
# WiFiUDP
# ==========================================================================

proc initWiFiUDP*(): WiFiUDP
  {.importcpp: "WiFiUDP()", constructor, header: header.}
  ## Create an unbound UDP socket.

{.push header: header.}

proc begin*(u: var WiFiUDP; port: uint16): uint8 {.importcpp, discardable.}
  ## Bind to a local UDP port. Returns 1 on success.

proc begin*(u: var WiFiUDP; ip: IPAddress; port: uint16): uint8
  {.importcpp, discardable.}
  ## Bind to a specific local IP and port.

proc beginMulticast*(u: var WiFiUDP; ip: IPAddress; port: uint16): uint8
  {.importcpp, discardable.}
  ## Join a multicast group on the given port. Returns 1 on success.

proc stop*(u: var WiFiUDP) {.importcpp.}
  ## Close the UDP socket and release resources.

# -- Packet construction & transmission --

proc beginMulticastPacket*(u: var WiFiUDP): cint {.importcpp, discardable.}
  ## Start building a multicast packet. Returns 1 on success.

proc beginPacket*(u: var WiFiUDP; ip: IPAddress; port: uint16): cint
  {.importcpp, discardable.}
  ## Start building a packet to the given IP and port.

proc beginPacket*(u: var WiFiUDP; host: cstring; port: uint16): cint
  {.importcpp, discardable.}
  ## Start building a packet to the given hostname and port.

proc endPacket*(u: var WiFiUDP): cint {.importcpp, discardable.}
  ## Finish and send the packet. Returns 1 on success.

proc write*(u: var WiFiUDP; b: uint8): csize_t {.importcpp, discardable.}
  ## Append a single byte to the current outgoing packet.

proc write*(u: var WiFiUDP; buf: ptr uint8; size: csize_t): csize_t
  {.importcpp, discardable.}
  ## Append a byte buffer to the current outgoing packet.

proc write*(u: var WiFiUDP; str: cstring): csize_t
  {.importcpp, discardable.}
  ## Append a null-terminated string to the current outgoing packet.

# -- Packet reception --

proc parsePacket*(u: var WiFiUDP): cint {.importcpp.}
  ## Start processing the next incoming packet; returns its size or 0.

proc available*(u: var WiFiUDP): cint {.importcpp.}
  ## Bytes remaining in the current incoming packet.

proc read*(u: var WiFiUDP): cint {.importcpp.}
  ## Read one byte from the current packet; -1 if none available.

proc read*(u: var WiFiUDP; buf: ptr uint8; size: csize_t): cint
  {.importcpp.}
  ## Read up to ``size`` bytes from the current packet into ``buf``.

proc peek*(u: var WiFiUDP): cint {.importcpp.}
  ## Peek at the next byte without consuming it; -1 if empty.

proc flush*(u: var WiFiUDP) {.importcpp.}
  ## Discard any bytes that have not yet been read from the current packet.

proc remoteIP*(u: var WiFiUDP): IPAddress {.importcpp.}
  ## IP address of the sender of the current incoming packet.

proc remotePort*(u: var WiFiUDP): uint16 {.importcpp.}
  ## Port of the sender of the current incoming packet.

proc `==`*(a, b: WiFiUDP): bool
  {.importcpp: "# == #", header: header.}
  ## True if both UDP sockets refer to the same underlying socket.

proc `!=`*(a, b: WiFiUDP): bool
  {.importcpp: "# != #", header: header.}
  ## True if the UDP sockets refer to different sockets.

{.pop.}  # WiFiUDP header

# ==========================================================================
# WiFiSSLClient  (extends WiFiClient — only SSL-specific additions below)
# ==========================================================================

proc initWiFiSSLClient*(): WiFiSSLClient
  {.importcpp: "WiFiSSLClient()", constructor, header: header.}
  ## Create an unconnected SSL/TLS client.

{.push header: header.}

proc setCACert*(c: var WiFiSSLClient; rootCa: cstring) {.importcpp.}
  ## Set a PEM-encoded root CA for server verification.
  ## Pass nil to use the built-in default CA bundle.

proc setEccSlot*(c: var WiFiSSLClient; slot: cint;
                 cert: ptr uint8; certLen: cint) {.importcpp.}
  ## Use an ECC508/608 hardware key slot and certificate for client
  ## authentication.

{.pop.}  # WiFiSSLClient header

# ==========================================================================
# Global WiFi instance
# ==========================================================================

var WiFi* {.importcpp: "WiFi", header: header, nodecl.}: CWifi
  ## Pre-instantiated global WiFi manager provided by the Arduino runtime.

# ==========================================================================
# Convenience templates
# ==========================================================================

template macAddress*(w: var CWifi; mac: var array[6, uint8]): ptr uint8 =
  ## Fill a Nim ``array[6, uint8]`` with the device MAC address.
  w.macAddress(addr mac[0])

template BSSID*(w: var CWifi; bssid: var array[6, uint8]): ptr uint8 =
  ## Fill a Nim ``array[6, uint8]`` with the current-connection BSSID.
  w.BSSID(addr bssid[0])

template BSSID*(w: var CWifi; networkItem: uint8;
                bssid: var array[6, uint8]): ptr uint8 =
  ## Fill a Nim ``array[6, uint8]`` with a scanned network's BSSID.
  w.BSSID(networkItem, addr bssid[0])

template hostByName*(w: var CWifi; hostname: cstring): IPAddress =
  ## Convenience wrapper: resolves ``hostname`` and returns the IP
  ## directly (0.0.0.0 on failure).
  var ip = initIPAddress()
  discard w.hostByName(hostname, ip)
  ip
