## Bindings for the Arduino Servo library (Servo.h).
##
## Reference: https://github.com/arduino-libraries/Servo
## This library allows an Arduino board to control RC (hobby) servo motors.
## Wraps the Servo class which drives hobby servos via timer-based PWM.

{.push header: "Servo.h".}

const
  MIN_PULSE_WIDTH* = 544.cint       ## The shortest pulse sent to a servo (microseconds)
  MAX_PULSE_WIDTH* = 2400.cint      ## The longest pulse sent to a servo (microseconds)
  DEFAULT_PULSE_WIDTH* = 1500.cint  ## Default pulse width when servo is attached (microseconds)
  REFRESH_INTERVAL* = 20000.cint    ## Minimum time to refresh servos in microseconds
  INVALID_SERVO* = 255.uint8        ## Flag indicating an invalid servo index

type
  Servo* {.importcpp: "Servo".} = object
    ## Class for manipulating servo motors connected to Arduino pins.
    ## Servos are pulsed in the background using the value most recently
    ## written using the write() method.
    ##
    ## Note that analogWrite of PWM on pins associated with the timer are
    ## disabled when the first servo is attached.
    ## Timers are seized as needed in groups of 12 servos — 24 servos use
    ## two timers, 48 servos will use four.

proc initServo*(): Servo {.importcpp: "Servo()", constructor.}

proc attach*(s: var Servo, pin: cint): uint8 {.importcpp, discardable.}
  ## Attaches a servo motor to an I/O pin.
  ## Returns channel number or INVALID_SERVO on failure.
proc attach*(s: var Servo, pin: cint, min: cint, max: cint): uint8 {.importcpp, discardable.}
  ## Attaches to a pin setting min and max pulse widths in microseconds.
  ## Default min is 544, max is 2400.
proc detach*(s: var Servo) {.importcpp.}
  ## Stops an attached servo from pulsing its I/O pin.
proc write*(s: var Servo, value: cint) {.importcpp.}
  ## Sets the servo angle in degrees (0 to 180).
  ## If value is treated as invalid angle but valid as pulse width in
  ## microseconds, it is treated as microseconds.
proc writeMicroseconds*(s: var Servo, value: cint) {.importcpp.}
  ## Sets the servo pulse width in microseconds.
proc read*(s: Servo): cint {.importcpp.}
  ## Gets the last written servo pulse width as an angle between 0 and 180.
proc readMicroseconds*(s: Servo): cint {.importcpp.}
  ## Gets the last written servo pulse width in microseconds.
proc attached*(s: Servo): bool {.importcpp.}
  ## Returns true if there is a servo attached.

{.pop.}
