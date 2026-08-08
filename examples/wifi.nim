## Simple WiFi example
## This is based on the Arduino WiFiS3 library, bundled with
## arduino r4 wifi board.
## 
## Toggle the built-in LED from a browser (Arduino UNO R4 WiFi, WiFiS3 lib).
##
## How it works:
##   1. setup: join the WiFi network, start a TCP server on port 80,
##      print the board's IP over serial.
##   2. loop: when a browser connects, read its HTTP request line
##      (e.g. "GET /on HTTP/1.1"), switch the LED accordingly, and
##      reply with a tiny HTML page containing /on and /off links.
##
## Usage: modify the ssid variable, put the WiFi password in wifi_secret.txt,
## flash, open the serial monitor, and browse to the printed http://<board-ip>.

import std/[strutils]
import ../narduino/src/narduino
import ../narduino/src/narduino/libs/wifis3

const
    ssid = cstring "TheRod" # name of your WiFi network
    secret = cstring staticRead("wifi_secret.txt").strip()
    # The whole "web page": two links that request /on and /off.
    page = cstring """<!DOCTYPE html>
<html><body style="font-family:sans-serif;text-align:center">
<h1>UNO R4 LED</h1>
<p><a href="/on">Turn LED on</a></p>
<p><a href="/off">Turn LED off</a></p>
</body></html>"""

let pin = LED_BUILTIN
var server = initWiFiServer(80)

proc printIP(ip: IPAddress) =
    ## Serial has no IPAddress overload, so print the four octets by hand.
    for i in 0..3:
        Serial.print(ip[cint i])
        if i < 3: Serial.print('.')
    Serial.println()

proc connectWiFi() =
    ## Join the network and (re)start the TCP server.
    # begin() blocks and returns a WL_* status; retry until connected.
    while WiFi.begin(ssid, secret) != cint WL_CONNECTED:
        Serial.println("connecting...")
        delay(3000)
    server.begin()
    Serial.print("connected, open http://")
    printIP WiFi.localIP()

setup:
    Serial.begin(9600)
    delay(1000)
    pinMode(pin, OUTPUT)
    connectWiFi()

loop:
    if WiFi.status() != WL_CONNECTED:
        Serial.println("wifi lost, reconnecting...")
        server.`end`() # close the stale listening socket first
        connectWiFi()
    var client = server.available()
    if client.isValid: # a browser has connected
        # Grab the request line ("GET /on HTTP/1.1"); headers end at a blank line.
        var reqLine = ""
        var line = ""
        while client.connected() == 1:
            let c = client.read()
            if c < 0: continue
            let ch = char c
            if ch == '\n':
                if line.len == 0: break            # blank line: request done
                if reqLine.len == 0: reqLine = line # first line is the request line
                line = ""
            elif ch != '\r':
                line.add ch
        if reqLine.contains("GET /on"):
            digitalWrite(pin, HIGH)
        elif reqLine.contains("GET /off"):
            digitalWrite(pin, LOW)
        # Reply: status line + headers, blank line, then the page.
        client.println("HTTP/1.1 200 OK")
        client.println("Content-Type: text/html")
        client.println("Connection: close")
        client.println()
        client.println(page)
        delay(10)          # let the modem flush before we close
        client.stop()