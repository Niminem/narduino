## DHT sensor example — exercises both the basic DHT and DHT_Unified APIs.
## Requires:
##   narduino libinstall --lib:"DHT sensor library"
## (Adafruit Unified Sensor is installed automatically as a dependency)

import std/[math] # isNaN
import ../narduino/src/narduino
import ../narduino/src/narduino/libs/dht_sensor

const DHTPIN: uint8 = 2 # which pin (on board) to use
const DHTTYPE: uint8 = DHT11 # which type of sensor to use

var dht = initDHT(DHTPIN, DHTTYPE)

let setupDelay = culong 1000 # if read too quickly after setup can result in issues
let measurementDelay = culong 2000 # if read too frequently can result in issues

setup:
    Serial.begin(9600)
    dht.begin()
    delay(setupDelay)

loop:
    let tmp = dht.readTemperature(true) # fahrenheit
    let hum = dht.readHumidity()
    let heatIndex = dht.computeHeatIndex(tmp, hum, true) # fahrenheit

    if tmp.isNaN() or hum.isNaN():
        Serial.println("Failed to read from DHT sensor!")
        return

    Serial.println("Temperature: " & $tmp & "°F")
    Serial.println("Humidity: " & $hum & "%")
    Serial.println("Heat Index: " & $heatIndex & "°F")
    Serial.println()
    delay(measurementDelay)