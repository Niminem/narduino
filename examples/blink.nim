## This example is a simple blink program that blinks the built-in LED on the board.
## Successfully tested with Arduino UNO board

import ../src/narduino

setup:
    pinMode(LED_BUILTIN, OUTPUT)

loop:
    digitalWrite(LED_BUILTIN, HIGH)
    delay(100)
    digitalWrite(LED_BUILTIN, LOW)
    delay(100)