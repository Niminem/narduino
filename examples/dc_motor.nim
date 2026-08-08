## Simple DC Motor control example
## uses sunfounder TA6586 Motor Controller
## https://www.youtube.com/watch?v=lvqnM10uWLU
## NOTE: DO NOT reverse direction by max speed, it can damage things

# import std/[]
import ../narduino/src/narduino

let
    BI = uint8 10 # backward input
    FI = uint8 9 # forward input
var MS: cint

setup:
    pinMode(BI, OUTPUT)
    pinMode(FI, OUTPUT)
    Serial.begin(9600)
    delay(1000)

loop:
    Serial.println("Enter speed (0-255):") # NOTE: SAFE START IT AT 50+ !!! (lower vals won't turn the motor but you'll hear something)
    while Serial.available() == cint 0:
        discard
    var raw = Serial.readStringUntil('\n')
    raw.trim()
    MS = cint raw.toInt()
    # forward
    analogWrite(FI, MS) # NOTE: YOU CAN SIMPLY USE DIGITALWRITE FOR HIGH/LOW
    analogWrite(BI, 0)
    delay(1000) # turn motor off
    analogWrite(FI, 0)
    analogWrite(BI, 0)
    delay(1000)
    # backward
    analogWrite(FI, 0)
    analogWrite(BI, MS)
    delay(1000) # turn motor off
    analogWrite(FI, 0)
    analogWrite(BI, 0)
    delay(1000)