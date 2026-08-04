## Bindings for the Arduino Stepper library (Stepper.h).
##
## Drives unipolar, bipolar, or five-phase stepper motors using
## 2, 4, or 5 control wires.
##
## When wiring multiple stepper motors to a microcontroller, you quickly run
## out of output pins, with each motor requiring 4 connections.
##
## By making use of the fact that at any time two of the four motor coils are
## the inverse of the other two, the number of control connections can be
## reduced from 4 to 2 for the unipolar and bipolar motors.
##
## A slightly modified circuit around a Darlington transistor array or an
## L293 H-bridge connects to only 2 microcontroller pins, inverts the signals
## received, and delivers the 4 (2 plus 2 inverted ones) output signals
## required for driving a stepper motor. Similarly the Arduino motor shields
## 2 direction pins may be used.
##
## Control signal sequences:
##
## 5-phase, 5 wires::
##
##   Step C0 C1 C2 C3 C4
##      1  0  1  1  0  1
##      2  0  1  0  0  1
##      3  0  1  0  1  1
##      4  0  1  0  1  0
##      5  1  1  0  1  0
##      6  1  0  0  1  0
##      7  1  0  1  1  0
##      8  1  0  1  0  0
##      9  1  0  1  0  1
##     10  0  0  1  0  1
##
## 4 wires::
##
##   Step C0 C1 C2 C3
##      1  1  0  1  0
##      2  0  1  1  0
##      3  0  1  0  1
##      4  1  0  0  1
##
## 2 wires::
##
##   Step C0 C1
##      1  0  1
##      2  1  1
##      3  1  0
##      4  0  0
##
## Reference: https://github.com/arduino-libraries/Stepper
## Circuits: http://www.arduino.cc/en/Tutorial/Stepper
## Install via `narduino libinstall --lib:"Stepper"`

const header = "Stepper.h"

{.push header: header.}

type
  Stepper* {.importcpp: "Stepper".} = object

proc initStepper*(numberOfSteps: cint,
                  motorPin1, motorPin2: cint): Stepper
  {.importcpp: "Stepper(@)", constructor.}
  ## 2-wire constructor. Uses an H-bridge or Darlington array to drive
  ## the motor with only two control pins.

proc initStepper*(numberOfSteps: cint,
                  motorPin1, motorPin2,
                  motorPin3, motorPin4: cint): Stepper
  {.importcpp: "Stepper(@)", constructor.}
  ## 4-wire constructor for direct unipolar or bipolar wiring.

proc initStepper*(numberOfSteps: cint,
                  motorPin1, motorPin2,
                  motorPin3, motorPin4,
                  motorPin5: cint): Stepper
  {.importcpp: "Stepper(@)", constructor.}
  ## 5-wire constructor for five-phase stepper motors.

proc setSpeed*(s: var Stepper, whatSpeed: clong) {.importcpp.}
  ## Set the motor speed in RPM.

proc step*(s: var Stepper, numberOfSteps: cint) {.importcpp.}
  ## Rotate the motor a given number of steps. Positive values turn
  ## one direction, negative values turn the other.

proc version*(s: Stepper): cint {.importcpp.}
  ## Return the library version number.

{.pop.}
