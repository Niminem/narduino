# import std/[]
import ../narduino/src/narduino

setup:
    Serial.begin(9600)
    delay(1000)
    pinMode(6, INPUT_PULLUP) # Uses internal pull-up resistor inside of the Arduino board
                             # instead of using external resistor

loop:
    Serial.println(digitalRead(6).uint8)
    delay(100)