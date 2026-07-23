## Servo sweep example — smoothly rotates a servo back and forth between 0° and 180°.
## Connect a servo signal wire to pin 11 (power to 5V, ground to GND).
## NOTE: This was tested on a small SG90 servo that comes with a typical Arduino kit.

import ../src/narduino
import ../src/narduino/libs/servo

let
    servoPin = cint 11
    br = cint 9600
    delayTime = culong 20 # ms between each degree step

var myServo = initServo()

setup:
    Serial.begin(uint32 br)
    myServo.attach(servoPin)

loop:
    for i in 0..180: # sweep from 0° to 180°
        myServo.write(i)
        delay(delayTime)
    for i in countdown(180, 0): # sweep back from 180° to 0°
        myServo.write(i)
        delay(delayTime)
