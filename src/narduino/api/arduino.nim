## Bindings for the core Arduino API: free functions (digital/analog I/O,
## time, interrupts, ...) and constants, plus the `setup:` /
## `loop:` templates that export the entry points the core expects
## (setup also runs NimMain to init the Nim runtime).

proc NimMain() {.importc.} # has to be fwd declared
template setup*(body) =
  ## Template for the setup function
  ## No name mangling as Arduino expects this function
  ## Includes NimMain() to initialize the Nim runtime for convenience
  proc setup {.exportc.} =
    NimMain()
    body

template loop*(body) =
  ## Template for the loop function
  ## No name mangling as Arduino expects this function
  proc loop {.exportc.} =
    body


{.push importc, nodecl, header:"Arduino.h".}
let
  # digitalWrite / digitalRead values
  HIGH*: uint8
  LOW*: uint8
  # pinMode modes
  INPUT*: uint8
  OUTPUT*: uint8
  INPUT_PULLUP*: uint8
  # pins (board-dependent, from pins_arduino.h)
  LED_BUILTIN*: uint8
  A0*: uint8
  A1*: uint8
  A2*: uint8
  A3*: uint8
  A4*: uint8
  A5*: uint8
  A6*: uint8
  A7*: uint8
  # shiftIn / shiftOut bit order
  LSBFIRST*: uint8
  MSBFIRST*: uint8
  # attachInterrupt modes (LOW above is also a valid mode, cast to cint)
  CHANGE*: cint
  FALLING*: cint
  RISING*: cint
  # digitalPinToInterrupt failure result
  NOT_AN_INTERRUPT*: cint
  # digitalPinToPort / digitalPinToBitMask failure results
  NOT_A_PIN*: uint8
  NOT_A_PORT*: uint8
  # analogReference modes (board-specific INTERNAL* variants intentionally omitted)
  DEFAULT*: uint8
  EXTERNAL*: uint8
{.pop.}


# Hook called by the core inside busy-wait loops (e.g. delay);
# named yieldArduino since `yield` is a reserved word in Nim
proc yieldArduino*() {.importc: "yield", header:"Arduino.h".}

{.push importc, header:"Arduino.h".}
# Digital I/O
proc pinMode*(pin, mode: uint8)
proc digitalWrite*(pin, value: uint8)
proc digitalRead*(pin: uint8): cint

# Analog I/O
proc analogRead*(pin: uint8): cint
proc analogReadResolution*(bits: cint)
proc analogReference*(mode: uint8)
proc analogWrite*(pin: uint8, value: cint)
proc analogWriteResolution*(bits: cint)

# Time
proc delay*(ms: culong)
proc delayMicroseconds*(us: cuint)
proc micros*(): culong
proc millis*(): culong

# Math (from WMath)
proc map*(x, inMin, inMax, outMin, outMax: clong): clong

# Words
proc makeWord*(w: uint16): uint16
proc makeWord*(h, l: uint8): uint16

# External interrupts
proc attachInterrupt*(interruptNum: uint8, userFunc: proc() {.cdecl.}, mode: cint)
proc detachInterrupt*(interruptNum: uint8)
proc digitalPinToInterrupt*(pin: uint8): cint

# Interrupts (macros over sei/cli)
proc interrupts*()
proc noInterrupts*()

# Advanced I/O
proc tone*(pin: uint8, frequency: cuint, duration: culong = 0)
proc noTone*(pin: uint8)
proc pulseIn*(pin, state: uint8, timeout: culong = 1_000_000): culong
proc pulseInLong*(pin, state: uint8, timeout: culong = 1_000_000): culong
proc shiftIn*(dataPin, clockPin, bitOrder: uint8): uint8
proc shiftOut*(dataPin, clockPin, bitOrder, value: uint8)

# Random numbers
proc random*(howbig: clong): clong
proc random*(howsmall, howbig: clong): clong
proc randomSeed*(seed: culong)

# Characters (from WCharacter.h)
proc isAlpha*(c: cint): bool
proc isAlphaNumeric*(c: cint): bool
proc isAscii*(c: cint): bool
proc isControl*(c: cint): bool
proc isDigit*(c: cint): bool
proc isGraph*(c: cint): bool
proc isHexadecimalDigit*(c: cint): bool
proc isLowerCase*(c: cint): bool
proc isPrintable*(c: cint): bool
proc isPunct*(c: cint): bool
proc isSpace*(c: cint): bool
proc isUpperCase*(c: cint): bool
proc isWhitespace*(c: cint): bool
proc toAscii*(c: cint): cint
proc toLowerCase*(c: cint): cint
proc toUpperCase*(c: cint): cint

{.pop.}
