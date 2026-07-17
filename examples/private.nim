## This example is for internal testing of the board and breadbox across my machines.
## Same thing as blink.nim, but we're using pin 12 to pass an output to the breadbox,
## blink the LED on the breadbox, and send the output back to the board.

var
    LED_BUILTIN {.importc,nodecl,header:"Arduino.h".}: cint
    OUTPUT {.importc,nodecl,header:"Arduino.h".}: cint
    HIGH {.importc,nodecl,header:"Arduino.h".}: cint
    LOW {.importc,nodecl,header:"Arduino.h".}: cint

proc pinMode(pin, mode: cint) {.importc,header:"Arduino.h".}
proc digitalWrite(pin, value: cint) {.importc,header:"Arduino.h".}
proc delay(ms: culong) {.importc,header:"Arduino.h".}

proc NimMain() {.importc.}
proc setup() {.exportc.} =
    NimMain()
    pinMode(12, OUTPUT)
proc loop() {.exportc.} =
    digitalWrite(12, HIGH)
    delay(1000)
    digitalWrite(12, LOW)
    delay(1000)