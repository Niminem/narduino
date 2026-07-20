## Serial echo example — reads characters from the serial monitor and echoes them back.
## Flash, then run `narduino monitor` to interact.
## NOTE: If you'd like to see 'Ready! Type something:' in the serial monitor,
## you need to open the monitor first (then hit reset button).

import ../src/narduino

setup:
    Serial.begin(9600) # common baud rate for Arduino boards
    delay(2000) # gives a delay to the serial port to stabilize (arduinor4 wifi quirk)
    Serial.println("Ready! Type something:") # won't see unless you open monitor
                                             # first (then hit reset button)

loop:
    if Serial.available() > 0:
        let c = Serial.read() # read the incoming character (type something in monitor)
        Serial.print("Got: ")
        Serial.println(char c) # print the character to the serial monitor