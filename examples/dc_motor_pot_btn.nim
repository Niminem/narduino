## Here we set up a basic DC motor control system with a potentiometer and a button
## Button toggles direction and reduces speed to 0 when pressed
## Potentiometer controls speed
## If potentiometer value is less than 50, we turn motor off (set val to 0)

# import std/[]
import ../narduino/src/narduino

const
    Forward = true
    Backward = false

let
    motorForwardPin: uint8 = 9
    motorBackwardPin: uint8 = 10

var
    direction: bool = Forward # default direction is forward
    prevBtnPressed: bool = false

setup:
    pinMode(motorForwardPin, OUTPUT) # motor forward input
    pinMode(motorBackwardPin, OUTPUT) # motor backward input
    pinMode(7, INPUT_PULLUP) # button (uses internal pull-up resistor)
    pinMode(A0, INPUT) # potentiometer
    Serial.begin(9600)
    delay(1000)

loop:
    # button check
    let btnPressed = if digitalRead(7) == cint HIGH: false else: true # PULLUP RESISTOR IS USED -> LOW IS PRESSED
    if btnPressed and not prevBtnPressed:
        direction = not direction # toggle the direction
        Serial.println("Direction toggled: " & $direction)
        # reduce speed to 0
        analogWrite(motorForwardPin, 0)
        analogWrite(motorBackwardPin, 0)
        delay(1000) # short delay to reduce motor speed to 0
    prevBtnPressed = btnPressed

    # check value of potentiometer
    let potValue = analogRead(A0) # range: 0-1023

    # ----- motor control -----

    # set motor speed based on potentiometer value
    let motorSpeed = map(potValue, 0, 1023, 0, 255)
    if motorSpeed < 50:
        analogWrite(motorForwardPin, 0)
        analogWrite(motorBackwardPin, 0)
    else:
        analogWrite(motorForwardPin, if direction == Forward: motorSpeed else: 0)
        analogWrite(motorBackwardPin, if direction == Backward: motorSpeed else: 0)

    # debug output
    Serial.println("Potentiometer value: " & $potValue)
    Serial.println("Motor speed: " & $motorSpeed)
    Serial.println("Direction: " & $direction)
    Serial.println("Button pressed: " & $btnPressed)
    Serial.println("--------------------------------")

    delay(50) # small delay