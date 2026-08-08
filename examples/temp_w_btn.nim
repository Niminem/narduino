import std/[math] # isNaN
import ../narduino/src/narduino
import ../narduino/src/narduino/libs/dht_sensor
import ../narduino/src/narduino/libs/arduino_led_matrix

const DHTPIN: uint8 = 2 # which pin (on board) to use
const DHTTYPE: uint8 = DHT11 # which type of sensor to use

var dht = initDHT(DHTPIN, DHTTYPE)
var matrix = initArduinoLEDMatrix()
let setupDelay = culong 1000 # if read too quickly after setup can result in issues
let measurementDelay = culong 2000 # if read too frequently can result in issues

setup:
    Serial.begin(9600)
    pinMode(3, INPUT_PULLUP) # Blue Button
    matrix.begin()
    dht.begin()
    delay(setupDelay)

var
    blueButtonState = false
    priorBlueButtonPressedState = false

proc updateBlueButtonState = 
    let blueButtonPressed = if digitalRead(3).uint8 == HIGH: false else: true
    blueButtonState = blueButtonPressed and not priorBlueButtonPressedState
    priorBlueButtonPressedState = blueButtonPressed

loop:
    let tmp = dht.readTemperature(true) # fahrenheit
    let hum = dht.readHumidity()
    if tmp.isNaN() or hum.isNaN():
        Serial.println("Failed to read from DHT sensor!")
        return
    let heatIndex = dht.computeHeatIndex(tmp, hum, true) # fahrenheit

    updateBlueButtonState()
    if blueButtonState:
        Serial.println("Blue Button Pressed")
        matrix.beginDraw()
        matrix.clear()
        matrix.textScrollSpeed(75)
        matrix.textFont(Font_5x7) # standard font (fits within the internal 8x12 matrix)
        matrix.beginText(5, 1, 255, 0, 0) # x = 0, y = 6 (red)
        matrix.println("Temp: " & $tmp & "°F Hum: " & $hum & "% HIdx: " & $heatIndex & "°F")
        matrix.endText(SCROLL_LEFT)
        matrix.endDraw()
    else:
        Serial.println("Blue Button Not Pressed")
    delay(measurementDelay)