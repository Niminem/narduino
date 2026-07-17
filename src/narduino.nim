## CLI tool, toolchain functions, and bindings to (most) Arduino functions and constants w/ helper templates
import narduino/[toolchain, bindings]
export toolchain, bindings # notice we're not exporting narduino/cli as that is just for the CLI tool


when isMainModule: # binary entry point (narduino cli)
  import narduino/cli
  runCommand(getArgs())