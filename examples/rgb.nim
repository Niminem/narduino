# import std/[]
import ../narduino/src/narduino

setup:
    Serial.begin(9600)
    delay(1000)
    pinMode(11, OUTPUT) # RGB LED (Red)
    pinMode(10, OUTPUT) # RGB LED (Green)
    pinMode(9, OUTPUT) # RGB LED (Blue)
    pinMode(4, INPUT_PULLUP) # Red Button
    pinMode(3, INPUT_PULLUP) # Green Button
    pinMode(2, INPUT_PULLUP) # Blue Button

var
    redLeDState = false
    priorRedPressedState = false
    redPressed = false

proc updateRedLED =
    redPressed = if digitalRead(4).uint8 == HIGH: false else: true
    if redPressed and not priorRedPressedState: redLEDState = not redLEDState
    priorRedPressedState = redPressed
    digitalWrite(11, if redLEDState == true: HIGH else: LOW)

var
    greenLeDState = false
    priorGreenPressedState = false
    greenPressed = false

proc updateGreenLED =
    greenPressed = if digitalRead(3).uint8 == HIGH: false else: true
    if greenPressed and not priorGreenPressedState: greenLEDState = not greenLEDState
    priorGreenPressedState = greenPressed
    digitalWrite(10, if greenLEDState == true: HIGH else: LOW)

var
    blueLeDState = false
    priorBluePressedState = false
    bluePressed = false

proc updateBlueLED =
    bluePressed = if digitalRead(2).uint8 == HIGH: false else: true
    if bluePressed and not priorBluePressedState: blueLEDState = not blueLEDState
    priorBluePressedState = bluePressed
    digitalWrite(9, if blueLEDState == true: HIGH else: LOW)


loop:
    updateRedLED()
    updateGreenLED()
    updateBlueLED()
    # let
    #     redButtonPress = if digitalRead(4).uint8 == HIGH: false else: true
    #     greenButtonPress = if digitalRead(3).uint8 == HIGH: false else: true
    #     blueButtonPress = if digitalRead(2).uint8 == HIGH: false else: true
    # analogwrite(11, if redButtonPress: 255 else: 0)
    # analogwrite(10, if greenButtonPress: 255 else: 0)
    # analogwrite(9, if blueButtonPress: 255 else: 0)
    delay(50)