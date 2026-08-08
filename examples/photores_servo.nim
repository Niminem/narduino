# photoresistor and servo motor example

# import std/[]
import ../narduino/src/narduino
import ../narduino/src/narduino/libs/servo

var myServo = initServo()

setup:
    pinMode(A0, INPUT)
    myServo.attach(11) # pin 11 on board
    Serial.begin(9600)
    delay(1000)

loop:
    let lightVal = analogRead(A0) # goes up when more light else goes down (0-1023 aka 10-bit)
    let lightMsg = initString("Light level: " & $lightVal)
    let lightValMapped = map(lightVal, 0, 1023, 0, 180)
    myServo.write(lightValMapped)
    delay(50)