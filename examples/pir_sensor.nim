## PIR sensor example

# import std/[]
import ../narduino/src/narduino

setup:
    pinMode(2, INPUT) # PIR sensor pin
    Serial.begin(9600)
    delay(1000)

var motion: uint8

loop:
    motion = uint8 digitalRead(2)
    if motion == HIGH:
        Serial.println("Motion detected")
    else:
        Serial.println("No motion detected")
    delay(50)