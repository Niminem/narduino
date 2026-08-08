# import std/[]
import ../narduino/src/narduino

setup:
    pinMode(A0, INPUT)
    Serial.begin(9600)
    delay(1000)

loop:
    let lightVal = analogRead(A0)
    Serial.println(lightVal) # goes up when more light else goes down
    delay(100)