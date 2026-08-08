# import std/[]
import ../narduino/src/narduino
import ../narduino/src/narduino/libs/servo

var servoMotor = initServo()

setup:
    Serial.begin(9600)
    pinMode(A0, INPUT) # potentiometer input
    pinMode(11, OUTPUT) # servo motor
    delay(1000) # wait for serial to connect
    discard servoMotor.attach(11) # attach servo to pin 11
loop:
    let value = analogRead(A0)
    Serial.println(value)
    let angle = map(value, 0, 1023, 0, 180) # converts analog value to servo angle
    servoMotor.write(angle)
    delay(20)