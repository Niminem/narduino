## WiFi UDP example: Arduino listener + host-side Nim client in one file.
##
## The board (UNO R4 WiFi) binds UDP port 2390 and toggles the built-in
## LED when a datagram saying "on" or "off" arrives, acking each one.
## The client is an interactive prompt on your computer that sends those
## commands. `-d:client` selects which half of this file gets compiled.
##
## Quick start:
##   1. Set `ssid` below and put your WiFi password in wifi_secret.txt.
##   2. Flash the board:  narduino flash --src:projects/wifi_udp.nim
##   3. Open the serial monitor and note the IP the board prints.
##   4. Run the client:   nim r -d:client -d:ip=<board-ip> projects/wifi_udp.nim
##      (or skip -d:ip and pass the IP as a runtime arg: ./wifi_udp <board-ip>)
##   5. Type on / off to toggle the LED; quit exits.
##
## UDP is connectionless and gives no delivery guarantee, so the board
## replies to every packet and the client waits up to 1 s for that ack.

const udpPort = 2390 # shared by both sides so they always agree

# The two halves have separate imports: the Arduino bindings only build
# with the cross toolchain, and std/net only exists on the host.
when defined(client):
    # ----------------------------------------------------------------
    # Host-side UDP client
    # ----------------------------------------------------------------
    import std/[net, os, strutils, nativesockets]

    const ip {.strdefine.} = "" # board IP baked in via -d:ip=<board-ip>

    proc main() =
        # Board IP: compile-time -d:ip wins, then the first runtime arg.
        let boardIp =
            if ip.len > 0: ip
            elif paramCount() >= 1: paramStr(1)
            else: quit "usage: wifi_udp <board-ip>  (or compile with -d:ip=<board-ip>)"
        var sock = newSocket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
        echo "sending to ", boardIp, ":", udpPort
        while true:
            stdout.write "led (on/off/quit)> "
            stdout.flushFile()
            var cmd: string
            try:
                cmd = stdin.readLine().strip().toLowerAscii()
            except EOFError:
                break
            if cmd == "quit": break
            if cmd notin ["on", "off"]:
                echo "unknown command: ", cmd
                continue
            sock.sendTo(boardIp, Port(udpPort), cmd)
            # UDP gives no delivery guarantee, so wait (up to 1 s) for the ack.
            var fds = @[sock.getFd()]
            if selectRead(fds, 1000) > 0:
                var
                    resp = ""
                    fromIp = ""
                    fromPort: Port
                discard sock.recvFrom(resp, 64, fromIp, fromPort)
                echo "board: ", resp
            else:
                echo "no reply (packet or ack lost?)"
        sock.close()

    main()

else:
    # ----------------------------------------------------------------
    # Arduino UDP listener (UNO R4 WiFi, WiFiS3 lib)
    # ----------------------------------------------------------------
    import std/strutils
    import ../narduino/src/narduino
    import ../narduino/src/narduino/libs/wifis3

    const
        ssid = cstring "TheRod" # name of your WiFi network
        secret = cstring staticRead("wifi_secret.txt").strip()
    let pin = LED_BUILTIN
    var udp = initWiFiUDP()

    proc printIP(ip: IPAddress) =
        ## Serial has no IPAddress overload, so print the four octets by hand.
        for i in 0..3:
            Serial.print(ip[cint i])
            if i < 3: Serial.print('.')
        Serial.println()

    proc connectWiFi() =
        ## Join the network and (re)bind the UDP socket.
        # begin() blocks and returns a WL_* status; retry until connected.
        while WiFi.begin(ssid, secret) != cint WL_CONNECTED:
            Serial.println("connecting...")
            delay(3000)
        udp.begin(uint16 udpPort)
        Serial.print("connected, listening on udp://")
        printIP WiFi.localIP()

    setup:
        Serial.begin(9600)
        delay(1000)
        pinMode(pin, OUTPUT)
        connectWiFi()

    loop:
        if WiFi.status() != WL_CONNECTED:
            Serial.println("wifi lost, reconnecting...")
            udp.stop() # old socket on the co-processor is stale after a drop
            connectWiFi()
        # parsePacket returns the size of the next datagram, or 0 if none
        # arrived; it never blocks, so the loop keeps spinning freely.
        let size = udp.parsePacket()
        if size > 0:
            # Read the datagram payload into a Nim string.
            var buf: array[64, uint8]
            let n = udp.read(addr buf[0], csize_t min(size, buf.len))
            var cmd = ""
            for i in 0 ..< n:
                cmd.add char buf[i]
            var reply: string
            if cmd == "on":
                digitalWrite(pin, HIGH)
                reply = "ok:on"
            elif cmd == "off":
                digitalWrite(pin, LOW)
                reply = "ok:off"
            else:
                reply = "err:unknown command"
            # Ack back to whoever sent the packet.
            udp.beginPacket(udp.remoteIP(), udp.remotePort())
            udp.write("from arduino: " & reply)
            udp.endPacket()
