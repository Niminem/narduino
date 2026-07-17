## Bindings to (most) Arduino functions and constants w/ helper templates.
## Firmware-safe: host-side toolchain procs live in narduino/toolchain,
## which is only pulled in by the CLI binary (below) or an explicit import.
import narduino/bindings
export bindings

when isMainModule: # binary entry point (narduino cli)
  import narduino/cli
  runCommand(getArgs())