# Package
version       = "0.5.0"
author        = "Leon Lysak (Niminem)"
description   = "Write and flash Arduino firmware with Nim using your favorite IDE - easily!"
license       = "MIT"
srcDir        = "src"
bin           = @["narduino"]
installDirs   = @["docs"]

# Dependencies
requires "nim >= 2.2.10"

# Tasks

task docs, "Generate API documentation":
  exec "nim doc --project --index:on --outdir:docs src/narduino.nim"