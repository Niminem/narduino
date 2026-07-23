## Bindings to (most) Arduino functions and constants w/ helper templates.
## Firmware-safe: host-side toolchain procs live in narduino/toolchain,
## which is only pulled in by the CLI binary (below) or an explicit import.
import narduino/api
export api

when defined(nimdoc):
  import narduino/toolchain
  import narduino/libs/servo # TODO: add other libs here as they are created !!!

when isMainModule and not defined(nimdoc): # binary entry point (narduino cli)
  import narduino/cli
  runCommand(getArgs())