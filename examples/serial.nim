## Serial echo example — reads lines from the serial monitor and echoes them back.
## Flash, then run `narduino monitor` to interact.
## NOTE: If you'd like to see 'Ready!' in the serial monitor,
## open the monitor first (then hit the reset button).

import ../src/narduino

setup:
    Serial.begin(9600)
    delay(2000)
    Serial.println("Ready! Type a line and press Enter:")

loop:
    if Serial.available() > 0:
        var input = Serial.readStringUntil('\n')
        input.trim()  # strip \r\n or trailing whitespace from terminal
        if input.length() > 0:
            Serial.print("Echo: ")
            Serial.println(input)