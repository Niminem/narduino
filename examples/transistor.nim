## Transister example
## Here an (active) buzzer is connected to pin 8.
## A 2K resistor is connected to the base of the transistor.

# import std/[]
import ../narduino/src/narduino

setup:
    pinMode(8, OUTPUT) # buzz pin
    Serial.begin(9600)
    delay(1000)

loop:
    digitalWrite(8, HIGH)
    delay(500)
    digitalWrite(8, LOW)
    delay(500)