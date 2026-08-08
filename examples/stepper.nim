## Stepper Motor Example
## This example shows how to use the stepper library to control a stepper motor.
## These things are precise and have high torque, but are slow.
## We use the 28BYJ-48 stepper motor
## We use the ULN2003 driver board to control the motor
## See notes below about the wiring / pin ordering.

# import std/[]
import ../narduino/src/narduino
import ../narduino/src/narduino/libs/stepper

const Steps = 2038 # 2038 steps per revolution for stepper motor
const Rpm = 15 # revolutions per minute

var myStepper = initStepper(Steps, 2, 3, 4, 5)
# Pin ordering: the Stepper library pairs arguments (1st & 3rd) and
# (2nd & 4th) as coil pairs internally. If your motor's coil pairs
# don't match that grouping, you need to swap the middle two arguments
# so the library's pairs line up with the physical coil pairs.
#
# For example, if you wire IN1=2, IN2=3, IN3=4, IN4=5 but the motor
# pairs coils as (IN1,IN2) and (IN3,IN4), you'd call:
#   initStepper(Steps, 2, 4, 3, 5)   — swapping the middle two pins.
# If the motor spins erratically or not at all, try swapping the
# middle two pin arguments.
#
# This varies per motor and driver. Check your motor's datasheet for
# its coil pair wiring. You can also figure it out with a multimeter:
# pins on the same coil pair will have lower resistance between them
# than pins on different coils.
# NOTE: we wired the pins this way so we can just pass the pins in order.

setup:
    Serial.begin(9600)
    delay(1000)
    myStepper.setSpeed(Rpm)

loop:
    myStepper.step(Steps)
    delay(1000)
    myStepper.step(-Steps)
    delay(1000)