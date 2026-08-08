# here we use a pull-up resistor to read the button state
# and update the LED state when the button is pressed (and the prior state was not pressed)

# import std/[]
import ../narduino/src/narduino

setup:
    Serial.begin(9600)
    delay(1000)
    pinMode(2, INPUT)
    pinMode(7, OUTPUT)

var
    ledState = false
    priorPressedState = false
    pressed = false

loop:
    pressed = if digitalRead(2).uint8 == HIGH: false else: true
    if pressed and not priorPressedState: ledState = not ledState
    priorPressedState = pressed
    digitalWrite(7, if ledState == true: HIGH else: LOW)
    delay(100)