import std/[parseopt, os, osproc, strutils, browsers]
import toolchain

type Args* = object
  command*, src*, dir*, cpu*, fqbn*,
   port*, autoinstall*, verbose*, baud*,
   lib*, query*: string


const HelpText = """
narduino - write and flash Arduino firmware with Nim using arduino-cli and your favorite IDE - easily!

Usage:
  narduino <command> [--flag:value]

Commands:
  boards    Lists connected boards (detected serial ports and their matches)
  active    Shows the active board (fqbn and port)
  install   Installs the core (platform) for the active board
  sketch    Creates a sketch directory and compiles Nim code into it
              --src:<path>        path to Nim source file [required]
              --dir:<path>        path to sketch directory
              --cpu:<cpu>         cpu to use for Nim compilation (ex: avr, arm)
  upload    Uploads a compiled sketch to the board
              --dir:<path>        path to sketch directory
              --fqbn:<fqbn>       fully qualified board name (ex: arduino:avr:uno)
              --port:<port>       serial port of the board
              --autoinstall:<bool> auto-install the board's core (default: true)
              --verbose:<bool>    verbose arduino-cli output (default: false)
  flash     One-shot sketch + upload
              --src:<path>        path to Nim source file [required]
              --dir:<path>        path to sketch directory
              --cpu:<cpu>         cpu to use for Nim compilation (ex: avr, arm)
              --fqbn:<fqbn>       fully qualified board name (ex: arduino:avr:uno)
              --port:<port>       serial port of the board
              --autoinstall:<bool> auto-install the board's core (default: true)
              --verbose:<bool>    verbose arduino-cli output (default: false)
  monitor   Opens an interactive serial monitor (Ctrl+C to exit)
              --port:<port>       serial port of the board
              --baud:<rate>       baud rate (default: 9600)
  libsearch   Searches the Arduino library index
                --query:<text>      search query [required]
  libinstall  Installs an Arduino library
                --lib:<name>        library name, supports versioned (e.g. "Servo@1.2.1") [required]
  docs      Opens the API documentation in your default browser
  help      Shows this help message

Flags are optional unless marked required: the fqbn, port, and cpu are
auto-detected from the connected board when omitted."""


proc getArgs*(): Args =
  for kind, key, val in getopt(commandLineParams()):
    case kind
    of cmdEnd: break
    of cmdShortOption, cmdLongOption:
      if key == "": continue
      if val == "": quit "Invalid Option: " & key & "\nRun 'narduino help' for a list of valid options."
      # assign values to action
      if key == "src": result.src = val
      elif key == "dir": result.dir = val
      elif key == "cpu": result.cpu = val
      elif key == "fqbn": result.fqbn = val
      elif key == "port": result.port = val
      elif key == "autoinstall": result.autoinstall = val
      elif key == "verbose": result.verbose = val
      elif key == "baud": result.baud = val
      elif key == "lib": result.lib = val
      elif key == "query": result.query = val
      else:
        quit "Invalid Option: " & key & "\nRun 'narduino help' for a list of valid options."
    of cmdArgument:
      result.command = key


proc runBoardsCommand*() =
  let boards = $(listBoards())
  echo boards


proc runActiveCommand*() =
  echo "Active Board: " & $getActiveBoard()


proc runInstallCommand*() =
  let coreId = coreFromFqbn(getActiveBoard().fqbn)
  if isCoreInstalled(coreId):
    echo "Core '" & coreId & "' is already installed for active board."
  else:
    installCore(coreId)


proc runSketchCommand*(args: Args) =
  if args.src.len == 0:
    quit "Missing required option: --src:<path to Nim source file>"
  createSketch(args.src, args.dir, args.cpu)


proc runUploadCommand*(args: Args) =
  var isAutoInstall = true
  if args.autoInstall.len > 0:
    if args.autoInstall == "false":
      isAutoInstall = false
  upload(args.dir, args.fqbn, args.port,
    autoInstallCore=isAutoInstall,
    verbose=args.verbose == "true")


proc runFlashCommand*(args: Args) =
  ## One-shot sketch + upload. Resolves the board a single time and passes
  ## explicit values down so createSketch/upload don't each re-detect it.
  if args.src.len == 0:
    quit "Missing required option: --src:<path to Nim source file>"

  var fqbn = args.fqbn
  var port = args.port
  var cpu = args.cpu
  if fqbn.len == 0 or port.len == 0:
    let activeBoard = getActiveBoard()
    if fqbn.len == 0: fqbn = activeBoard.fqbn
    if port.len == 0: port = activeBoard.port
  if cpu.len == 0:
    cpu = cpuFromFqbn(fqbn)

  var isAutoInstall = true
  if args.autoInstall.len > 0:
    if args.autoInstall == "false":
      isAutoInstall = false

  let sketchDir = createSketch(args.src, args.dir, cpu)
  upload(sketchDir, fqbn, port,
    autoInstallCore=isAutoInstall,
    verbose=args.verbose == "true")


proc runMonitorCommand*(args: Args) =
  var baud = 9600
  if args.baud.len > 0:
    try:
      baud = parseInt(args.baud)
    except ValueError:
      quit "Invalid baud rate: '" & args.baud & "'. Must be an integer."
  monitor(args.port, baud)


proc runLibSearchCommand*(args: Args) =
  if args.query.len == 0:
    quit "Missing required option: --query:<search text>"
  searchLib(args.query)


proc runLibInstallCommand*(args: Args) =
  if args.lib.len == 0:
    quit "Missing required option: --lib:<library name>"
  installLib(args.lib)


const DevDocsIndex = currentSourcePath().parentDir().parentDir().parentDir() / "docs" / "theindex.html"

proc runDocsCommand*() =
  if fileExists(DevDocsIndex):
    openDefaultBrowser("file://" & DevDocsIndex)
    return
  let (pkgPath, exitCode) = execCmdEx("nimble path narduino")
  if exitCode == 0:
    let indexPath = pkgPath.strip() / "docs" / "theindex.html"
    if fileExists(indexPath):
      openDefaultBrowser("file://" & indexPath)
      return
  quit "Documentation not found.\nRun 'nimble docs' from the project root to generate it."

proc runHelpCommand*() =
  echo HelpText


proc runCommand*(args: Args) =
  case args.command
  of "boards": runBoardsCommand()
  of "active": runActiveCommand()
  of "install": runInstallCommand()
  of "sketch": runSketchCommand(args)
  of "upload": runUploadCommand(args)
  of "flash": runFlashCommand(args)
  of "monitor": runMonitorCommand(args)
  of "libsearch": runLibSearchCommand(args)
  of "libinstall": runLibInstallCommand(args)
  of "docs": runDocsCommand()
  of "help", "": runHelpCommand()
  else:
    quit "Invalid Command: " & args.command & "\nRun 'narduino help' for a list of valid commands."