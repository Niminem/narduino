# narduino

Write and flash Arduino firmware with **Nim** using your favorite IDE- easily!

[Arduino CLI](https://arduino.github.io/arduino-cli/) powers the Arduino IDE and other
official tooling. `narduino` provides abstractions on top of it and the Nim compiler so
you can build firmware in Nim from any editor: your Nim code is translated to C++,
placed into a standard Arduino sketch, and arduino-cli then compiles that sketch for
your board and flashes it — all from one command.

```
nim source ──(nim cpp)──> generated .cpp/.h ──> sketch dir ──(arduino-cli)──> board
```

## Prerequisites

- [Nim](https://nim-lang.org/) >= 2.2.10
- [arduino-cli](https://arduino.github.io/arduino-cli/latest/installation/) available on your PATH

On macOS, this installs arduino-cli to a directory already on PATH (tested):

```sh
curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR=/usr/local/bin sh
```

## Installation

--- TODO ---

## Quick start

Plug in your board, and from the root directory run:

```sh
narduino flash --src:examples/blink.nim
```

*note: this example was tested on an Arduino UNO running on MacOS*

That's it. narduino detects the connected board, installs its core if needed, compiles the Nim code, and uploads it. The built-in LED should start blinking.

Zero-config is the default everywhere: the board's fqbn, serial port, and target cpu are auto-detected from whatever is plugged in.

Every flag exists only to override that detection (multiple boards connected, boards like Teensy that can't report their cpu, uploading to a board that isn't currently attached, etc.).

## CLI reference

```
narduino <command> [--flag:value]
```

| Command | What it does |
|---|---|
| `boards` | Lists connected boards (detected serial ports and their matches) |
| `active` | Shows the active board (fqbn and port) |
| `install` | Installs the core (platform) for the active board |
| `sketch` | Creates a sketch directory and compiles Nim code into it |
| `upload` | Uploads a compiled sketch to the board |
| `flash` | One-shot `sketch` + `upload` |
| `help` | Shows help for all commands (also shown when run with no arguments) |

### `narduino sketch`

Compiles a Nim source file to C++ and places the generated files in an Arduino sketch
directory (created as `sketch_<name>/` in the current directory if not specified).

| Flag | Description |
|---|---|
| `--src:<path>` | Path to the Nim source file **[required]** |
| `--dir:<path>` | Path to the sketch directory |
| `--cpu:<cpu>` | CPU for Nim compilation (ex: `avr`, `arm`) |

### `narduino upload`

Compiles and uploads a sketch directory to the board via arduino-cli. If no directory is
given, uses the first `sketch_*` directory found in the current directory.

| Flag | Description |
|---|---|
| `--dir:<path>` | Path to the sketch directory |
| `--fqbn:<fqbn>` | Fully qualified board name (ex: `arduino:avr:uno`) |
| `--port:<port>` | Serial port of the board |
| `--autoinstall:<bool>` | Auto-install the board's core (default: `true`) |
| `--verbose:<bool>` | Verbose arduino-cli output (default: `false`) |

### `narduino flash`

Does `sketch` + `upload` in one shot, resolving the board once and reusing it for both
steps. Accepts all flags from both commands (`--src` required).

Note: flags take the `--flag:value` form. Boolean flags need an explicit value, e.g.
`--verbose:true` or `--autoinstall:false`.

## Writing firmware in Nim

A minimal blink ([examples/blink.nim](examples/blink.nim)):

```nim
var
    LED_BUILTIN {.importc,nodecl,header:"Arduino.h".}: cint
    OUTPUT {.importc,nodecl,header:"Arduino.h".}: cint
    HIGH {.importc,nodecl,header:"Arduino.h".}: cint
    LOW {.importc,nodecl,header:"Arduino.h".}: cint

proc pinMode(pin, mode: cint) {.importc,header:"Arduino.h".}
proc digitalWrite(pin, value: cint) {.importc,header:"Arduino.h".}
proc delay(ms: culong) {.importc,header:"Arduino.h".}

proc NimMain() {.importc.} # has to be fwd declared
proc setup() {.exportc.} =
    NimMain() # required: initializes the Nim runtime
    pinMode(LED_BUILTIN, OUTPUT)
proc loop() {.exportc.} =
    digitalWrite(LED_BUILTIN, HIGH)
    delay(1000)
    digitalWrite(LED_BUILTIN, LOW)
    delay(1000)
```

The rules of the game:

- Export `setup()` and `loop()` with `{.exportc.}` — the sketch's `.ino` file is just a
  stub; your Nim code provides the real implementations.
- Call `NimMain()` first thing in `setup()` to initialize the Nim runtime (global
  variable initialization, etc.).
- Bind to Arduino functions/constants with `{.importc, header:"Arduino.h".}`.

Under the hood, narduino compiles with flags suited for embedded targets
(`--os:any --mm:arc -d:useMalloc --noMain -d:danger ...`) and copies the generated
C++ files plus `nimbase.h` into the sketch directory, where arduino-cli treats them
as ordinary sketch sources.

## Using narduino as a library

Everything the CLI does is available programmatically:

```nim
import narduino

# board discovery
let boards = listBoards()            # all detected ports + matching boards
let active = getActiveBoard()        # the single connected board (fqbn + port)

# core management
ensureCoreInstalled(active.fqbn)     # install the board's core if missing

# build & flash
let sketchDir = createSketch("blink.nim")  # nim -> c++ -> sketch dir
upload(sketchDir)                          # compile & upload via arduino-cli
```

All procs raise `IOError`/`ValueError` with user-ready messages on failure, and
auto-detect the board when `fqbn`/`port`/`cpu` arguments are omitted.

## Supported boards

Board detection works for anything arduino-cli recognizes. The Nim `--cpu` is derived
automatically from the board's architecture — AVR (UNO, Mega, Nano, ...), ARM (SAMD,
RP2040, Renesas UNO R4, STM32, nRF52, ...), ESP8266/ESP32, and CH32V RISC-V boards.
Teensy boards need an explicit `--cpu` since they don't report which CPU they carry
(2.x is AVR, 3.x/4.x are ARM).

Third-party cores that aren't in the official package index (ESP8266, ATTinyCore, ...)
work too: register the core's package index URL with arduino-cli once, and narduino's
core installation picks it up automatically from your arduino-cli configuration.

```sh
arduino-cli config add board_manager.additional_urls https://arduino.esp8266.com/stable/package_esp8266com_index.json
```
*note: third-party core installation is untested but documented in [official docs](https://arduino.github.io/arduino-cli/1.5/) and the arduino-cli via helper flag*

## License

MIT — see [LICENSE](LICENSE).
