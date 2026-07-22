# narduino

Write and flash Arduino firmware with **Nim** using your favorite IDE — easily!

[Arduino CLI](https://arduino.github.io/arduino-cli/) powers the Arduino IDE and other official tooling. `narduino` provides abstractions on top of it and the Nim compiler so you can build firmware in Nim from any editor: your Nim code is translated to C++, placed into a standard Arduino sketch, and arduino-cli then compiles that sketch for your board and flashes it — all from one command.

```
nim source ──(nim cpp)──> generated .cpp/.h ──> sketch dir ──(arduino-cli)──> board
```

`narduino` is both a CLI tool and a library:

- **CLI**: detect boards, compile Nim into sketches, and flash — zero-config.
- **Bindings** (`import narduino`): the Arduino API in Nim — digital/analog I/O,
  time, interrupts, `Serial`, and `setup:` / `loop:` templates so firmware code needs
  no FFI boilerplate.
- **Toolchain** (`import narduino/toolchain`): everything the CLI does, as procs you
  can call from your own tools.

## Prerequisites

- [Nim](https://nim-lang.org/) >= 2.2.10
- [arduino-cli](https://arduino.github.io/arduino-cli/latest/installation/) available on your PATH

On macOS, this installs arduino-cli to a directory already on PATH (tested):

```sh
curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR=/usr/local/bin sh
```

No other dependencies. Stdlib only.

## Installation

Install via nimble:

```sh
nimble install narduino
```

Or clone and install from a local copy via git:

```sh
git clone https://github.com/Niminem/narduino
cd narduino
nimble install
```

## Quick start

Plug in your board, then clone this repo (or copy the blink example from
[Writing firmware in Nim](#writing-firmware-in-nim) below) and run from its root:

```sh
narduino flash --src:examples/blink.nim
```

*note: this example was tested on an Arduino UNO*

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
| `monitor` | Opens an interactive serial monitor (Ctrl+C to exit) |
| `help` | Shows help for all commands (also shown when run with no arguments) |

### `narduino sketch`

Compiles a Nim source file to C++ and places the generated files in an Arduino sketch directory (created as `sketch_<name>/` in the current directory if not specified).

| Flag | Description |
|---|---|
| `--src:<path>` | Path to the Nim source file **[required]** |
| `--dir:<path>` | Path to the sketch directory |
| `--cpu:<cpu>` | CPU for Nim compilation (ex: `avr`, `arm`) |

### `narduino upload`

Hands a sketch directory to arduino-cli, which compiles the C++ for the board and uploads it (the Nim-to-C++ step happens in `sketch`, not here). If no directory is given, uses the first `sketch_*` directory found in the current directory.

| Flag | Description |
|---|---|
| `--dir:<path>` | Path to the sketch directory |
| `--fqbn:<fqbn>` | Fully qualified board name (ex: `arduino:avr:uno`) |
| `--port:<port>` | Serial port of the board |
| `--autoinstall:<bool>` | Auto-install the board's core (default: `true`) |
| `--verbose:<bool>` | Verbose arduino-cli output (default: `false`) |

### `narduino flash`

Does `sketch` + `upload` in one shot, resolving the board once and reusing it for both steps. Accepts all flags from both commands (`--src` required).

Note: flags take the `--flag:value` form. Boolean flags need an explicit value, e.g.
`--verbose:true` or `--autoinstall:false`.

### `narduino monitor`

Opens an interactive serial monitor on the board's port. Data is streamed in real time; press Ctrl+C to exit.

| Flag | Description |
|---|---|
| `--port:<port>` | Serial port of the board |
| `--baud:<rate>` | Baud rate (default: `9600`) |

## Writing firmware in Nim

Importing `narduino` gives you the Arduino API in Nim, so a blink is just:

```nim
import narduino

setup:
  pinMode(LED_BUILTIN, OUTPUT)

loop:
  digitalWrite(LED_BUILTIN, HIGH)
  delay(1000)
  digitalWrite(LED_BUILTIN, LOW)
  delay(1000)
```

The `setup:` and `loop:` templates take care of the entry points the Arduino core expects (exported with C linkage, no name mangling) and of initializing the Nim runtime — no boilerplate in your firmware code.

The bindings cover the core API from the [official reference](https://docs.arduino.cc/language-reference/): digital and analog I/O, time, tone/pulse/shift, interrupts, random numbers, character tests, the `String` class, and `Serial` (see [src/narduino/bindings/](src/narduino/bindings/) for details):

```nim
import narduino

setup:
  Serial.begin(9600)

loop:
  if Serial.available() > 0:
    Serial.print("got: ")
    Serial.println(Serial.read())
```

Anything not (yet) wrapped can be bound by hand — that's all the bindings do under the hood:

```nim
proc bitRead(value: culong, bit: uint8): cint {.importc, header: "Arduino.h".}
```

If you write the entry points manually instead of using the templates, export `setup()`/`loop()` with `{.exportc.}` and call `NimMain()` first thing in `setup()` to initialize the Nim runtime.

Under the hood, narduino compiles with flags suited for embedded targets (`--os:any --mm:arc -d:useMalloc --noMain -d:danger ...`) and copies the generated C++ files plus `nimbase.h` into the sketch directory, where arduino-cli treats them as ordinary sketch sources.

## Using the toolchain as a library

Everything the CLI does is available programmatically via the `narduino/toolchain` module. It runs on your computer (not on the board), so keep it out of firmware code — `import narduino` alone stays firmware-safe:

```nim
import narduino/toolchain

# board discovery
let boards = listBoards()            # all detected ports + matching boards
let active = getActiveBoard()        # the single connected board (fqbn + port)

# core management
ensureCoreInstalled(active.fqbn)     # install the board's core if missing

# build & flash
let sketchDir = createSketch("blink.nim")  # nim -> c++ -> sketch dir
upload(sketchDir)                          # compile & upload via arduino-cli
```

All procs raise errors with user-ready messages on failure, and auto-detect the board when `fqbn`/`port`/`cpu` arguments are omitted.

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
*note: third-party cores are untested with narduino; see the [arduino-cli docs](https://arduino.github.io/arduino-cli/latest/getting-started/#adding-3rd-party-cores) for details on registering additional package indexes*

## Troubleshooting

**Garbled serial monitor output (Arduino UNO R4 WiFi):** the R4 WiFi routes serial through an ESP32-S3 bridge chip, which can produce garbled serial monitor output after plugging in or flashing. This is a [known hardware issue](https://github.com/arduino/uno-r4-wifi-usb-bridge/issues/77) — press the board's reset button before opening the monitor to resolve it.

**Board unresponsive after flashing:** some boards (including the R4 WiFi) can occasionally end up in a bad state after flashing — the board may stop responding or behave unexpectedly. If a reset doesn't fix it, disconnecting and reconnecting the USB cable reliably resolves the issue.

**Serial monitor line endings:** the Arduino IDE lets you choose "No line ending" when sending data, but `arduino-cli monitor` (which narduino uses under the hood) has no such option — your terminal's newline is sent as-is when you press Enter. If your firmware reads line-based input, one option is to use `readStringUntil('\n')` followed by `trim()` to strip the trailing `\r` that terminals send (see [examples/serial.nim](examples/serial.nim) for a working pattern). A built-in serial monitor with line-ending control is planned; PRs welcome.

## License

MIT — see [LICENSE](LICENSE).
