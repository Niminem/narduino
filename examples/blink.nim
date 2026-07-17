## This example is a simple blink program that blinks the built-in LED on the board.
## Successfully tested with an Arduino UNO on MacOS.

var
    LED_BUILTIN {.importc,nodecl,header:"Arduino.h".}: cint
    OUTPUT {.importc,nodecl,header:"Arduino.h".}: cint
    HIGH {.importc,nodecl,header:"Arduino.h".}: cint
    LOW {.importc,nodecl,header:"Arduino.h".}: cint

proc pinMode(pin, mode: cint) {.importc,header:"Arduino.h".}
proc digitalWrite(pin, value: cint) {.importc,header:"Arduino.h".}
proc delay(ms: culong) {.importc,header:"Arduino.h".}

var globalVariable: cint = 0
var globalVariable2: cint = 0
var thisString = "Hello, World"

proc NimMain() {.importc.} # has to be fwd declared
proc setup() {.exportc.} =
    NimMain() # this is required for the Nim runtime to be initialized
    pinMode(LED_BUILTIN, OUTPUT)
proc loop() {.exportc.} =
    if thisString.len == 13: # let's us know the string is initialized
        digitalWrite(LED_BUILTIN, HIGH)
        delay(1000)
        digitalWrite(LED_BUILTIN, LOW)
        delay(1000)
    else:
        digitalWrite(LED_BUILTIN, HIGH)
        delay(100)
        digitalWrite(LED_BUILTIN, LOW)
        delay(100)
    globalVariable += 1
    if globalVariable == 100: globalVariable = 1
    globalVariable2 += 1
    if globalVariable2 == 100: globalVariable2 = 1