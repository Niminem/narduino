## Bindings to (most) Arduino functions and constants w/ helper templates.
## Firmware-safe: host-side toolchain procs live in narduino/toolchain,
## which is only pulled in by the CLI binary (below) or an explicit import.
import narduino/api
export api

when defined(nimdoc):
  import narduino/toolchain
  import narduino/libs/servo
  import narduino/libs/arduino_graphics
  import narduino/libs/arduino_led_matrix
  import narduino/libs/adafruit_sensor
  import narduino/libs/dht_sensor # TODO: add other libs here as they are created !!!
  # TODO: make macros that will loop through and include the libs here !!!

when isMainModule and not defined(nimdoc): # binary entry point (narduino cli)
  import narduino/cli
  runCommand(getArgs())