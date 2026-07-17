## This example is for internal testing of the board and breadbox across my machines.
## Same thing as blink.nim, but we're using pin 12 to pass an output to the breadbox,
## blink the LED on the breadbox, and send the output back to the board.

import ../src/narduino

setup:
    pinMode(12, OUTPUT)

loop:
    digitalWrite(12, HIGH)
    delay(1000)
    digitalWrite(12, LOW)
    delay(1000)