## This example is a simple blink program that blinks the built-in LED on the board.
## This example is successfully tested with Arduino UNO board.

import ../src/narduino

setup: # setup function is called once when the board is powered on
    pinMode(LED_BUILTIN, OUTPUT) # set built-in LED pin to output (sends HIGH / LOW to pin)

loop: # loop function is called repeatedly after setup
    digitalWrite(LED_BUILTIN, HIGH) # send HIGH to pin (turns on LED)
    delay(100) # wait 100 milliseconds (1/10th of a second)
    digitalWrite(LED_BUILTIN, LOW) # send LOW to pin (turns off LED)
    delay(100)