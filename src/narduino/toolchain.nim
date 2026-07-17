import std/[compilesettings, os, osproc, tempfiles, strutils, json, tables, options]
export options, tables

{.warning[ImplicitDefaultValue]: off.}

type
  Port* = object
    address*: string
    label*: string
    protocol*: string
    protocol_label*: string
    properties*: Table[string, string]
    hardware_id*: Option[string]
  MatchingBoard* = object
    name*: string
    fqbn*: string
  DetectedPort* = object
    port*: Port
    matching_boards*: Option[seq[MatchingBoard]]
  BoardList* = seq[DetectedPort]
  Board* = object
    fqbn*, port*: string


const NimLibDir = querySetting(SingleValueSetting.libPath)
const NimBaseH = NimLibDir / "nimbase.h"


proc `$`*(detectedPort: DetectedPort): string =
  result = "Port: " & detectedPort.port.address & " (" & detectedPort.port.protocol_label & ")\n"
  if detectedPort.matching_boards.isSome:
    for board in detectedPort.matching_boards.get():
      result &= "Matching Board: " & board.name & " (" & board.fqbn & ")\n"
  else:
    result &= "  - No matching boards found\n"


proc `$`*(boardList: BoardList): string =
  for detectedPort in boardList:
    result &= $detectedPort & "\n"


proc `$`*(board: Board): string =
  result = board.fqbn & " on " & board.port


proc cpuFromFqbn*(fqbn: string): string =
  let arch = fqbn.split(':')[1]
  case arch
  of "avr", "megaavr", "attiny":
    return "avr"
  of "samd", "sam", "renesas_uno", "renesas_portenta",
     "mbed_nano", "mbed_rp2040", "mbed_portenta", "mbed_giga", "mbed_opta",
     "mbed_nicla", "mbed_edge", "zephyr", "silabs",
     "stm32", "rp2040", "nrf52", "apollo3":
    return "arm"
  of "ch32v", "ch32": return "riscv32"
  of "esp8266":
    return "esp"
  of "esp32":
    return "esp"
  of "teensy":
    raise newException(ValueError,
      "Teensy boards report 'teensy' or 'avr' regardless of actual CPU " &
      "(2.x is AVR, 3.x/4.x are ARM). Pass the cpu explicitly.")
  else:
    raise newException(ValueError,
      "Don't know the Nim --cpu for architecture '" & arch & "'. Pass it explicitly.")


proc listBoards*(): BoardList =
  let (output, exitCode) = execCmdEx("arduino-cli board list --json")
  if exitCode != 0: raise newException(IOError, "Failed to list boards:\n" & output)
  let outputJson = parseJson(output)
  result = outputJson["detected_ports"].to(BoardList)


proc getActiveBoard*(): Board =
  var boards: seq[Board]
  for detectedPort in listBoards():
    if detectedPort.matchingBoards.isSome:
      for board in detectedPort.matchingBoards.get():
        boards.add(Board(fqbn: board.fqbn, port: detectedPort.port.address))
  if boards.len == 0:
    raise newException(IOError,
      "No active board found. Is a board connected to your computer?")
  elif boards.len > 1:
    var output = "Multiple active boards found:\n\n"
    for board in boards:
      output &= "  - " & board.fqbn & " on " & board.port & "\n"
    raise newException(IOError, output)
  else:
    result = boards[0]


proc coreFromFqbn*(fqbn: string): string =
  ## Extracts the core (platform) id from a fqbn.
  ## ex: "arduino:avr:uno" -> "arduino:avr"
  let parts = fqbn.split(':')
  if parts.len < 2:
    raise newException(ValueError, "Invalid fqbn: '" & fqbn & "'")
  result = parts[0] & ":" & parts[1]


proc isCoreInstalled*(coreId: string): bool =
  let (output, exitCode) = execCmdEx("arduino-cli core list --json")
  if exitCode != 0: raise newException(IOError, "Failed to list cores:\n" & output)
  # with zero cores installed, "platforms" can be missing or null depending on cli version
  let platforms = parseJson(output).getOrDefault("platforms")
  if platforms.isNil or platforms.kind != JArray: return false
  for platform in platforms:
    if platform["id"].getStr() == coreId: return true


proc installCore*(coreId: string) =
  ## Installs a core (platform) via arduino-cli. Requires network access.
  # refresh the package index first: on a fresh arduino-cli setup, `core install`
  # fails without it, and updating is idempotent
  echo "Updating core index..."
  let (indexOutput, indexExitCode) = execCmdEx("arduino-cli core update-index")
  if indexExitCode != 0:
    raise newException(IOError, "Failed to update core index:\n" & indexOutput)
  echo "Installing core for active board: '" & coreId & "' (this may take a while)..."
  let (output, exitCode) = execCmdEx("arduino-cli core install " & coreId)
  if exitCode != 0:
    raise newException(IOError, "Failed to install core '" & coreId & "':\n" & output)
  echo "Successfully installed core '" & coreId & "'."


proc ensureCoreInstalled*(fqbn: string, autoInstall: bool = true) =
  ## Makes sure the core for the given fqbn is installed, installing it if allowed.
  let coreId = coreFromFqbn(fqbn)
  if isCoreInstalled(coreId): return
  if autoInstall:
    installCore(coreId)
  else:
    raise newException(IOError,
      "Core '" & coreId & "' is not installed.\n" &
      "Install it by running: 'arduino-cli core install " & coreId & "' or 'narduino install' for the active board.")


proc copyNimbaseH(destinationDir: string) =
  if not fileExists(NimBaseH):
    raise newException(IOError, "nimbase.h not found at: '" & NimBaseH & "'")
  if not dirExists(destinationDir):
    raise newException(IOError, "Destination directory: '" & destinationDir & "' does not exist")
  copyFileToDir(NimBaseH, destinationDir)


proc createSketchDir(sketchName: string, parentDirPath: string = ""): string =
  ## Creates a new sketch directory (+ ino stub file) with the given name and path.
  ## ex: createSketchDir("MySketch", parentDirPath="~/Desktop/Arduino/")
  ## will create a directory at "~/Desktop/Arduino/sketch_MySketch"
  ## if no path is provided, the sketch will be created in the current working directory.
  ## returns full path to the sketch directory.
  for c in sketchName:
    if c notin {'a' .. 'z', 'A' .. 'Z', '0' .. '9', '_'}:
      raise newException(ValueError, "Sketch name must contain only letters, numbers, and underscores.")
  let fullSketchName = "sketch_" & sketchName
  result = (if parentDirPath.len == 0: getCurrentDir() else: parentDirPath) / fullSketchName
  createDir(result)
  let stubContent = "// Sketch entry (stub). Implementation lives in the generated .cpp files from Nim."
  writeFile(result / fullSketchName & ".ino", stubContent)


proc createSketch*(nimSrcFile: string, sketchDir, cpu: string = ""): string {.discardable.} =
  ## Creates a new sketch directory (+ ino stub file) if not provided,
  ## compiles the Nim code, and copies the generated files to the sketch directory.
  ## Returns full path to the sketch directory.
  ## If no cpu is provided, the cpu will attempt to be determined from the active board.

  # initial file check
  if not fileExists(nimSrcFile):
    raise newException(IOError, "Source file: '" & nimSrcFile & "' does not exist")

  echo "Creating sketch directory and compiling Nim code...\n"

  # sketch directory & ino stub file
  var finalSketchDir = sketchDir
  if finalSketchDir.len == 0:
    finalSketchDir = createSketchDir(nimSrcFile.splitFile().name)

  # remove current nim generated files from sketch directory (if any)
  var removalList: seq[string]
  for item in walkDir(finalSketchDir):
    if item.kind != pcFile: continue
    let path = item.path
    if path.endsWith(".json") or path.contains("@"): removalList.add(item.path)
  for path in removalList.items:
    removeFile(path)

  # create a temporary directory for the nim generated files
  var tmpDir = createTempDir("sketch_", "_tmp")
  defer: removeDir(tmpDir)

  # determine the cpu to use (if not passed explicitly)
  var finalCpu = cpu
  if finalCpu.len == 0:
    try:
      finalCpu = cpuFromFqbn(getActiveBoard().fqbn)
    except:
      let output = getCurrentExceptionMsg() & "\nAlternatively, specify the cpu explicitly when compiling Nim."
      raise newException(CatchableError, output)

  # build the command
  # note: we are providing flags like this in order to more easily modify the command later
  var cmd = "nim cpp "
  let flags = @[
    "--cpu:" & finalCpu,
    "--os:any",
    "--mm:arc",
    "-d:noSignalHandler",
    "--noMain:on",
    "-d:useMalloc",
    "-d:nimAllocPagesViaMalloc",
    "-d:release",
    "-d:danger",
    "--compileOnly",
    "--exceptions:goto",
    "-f",
    "--nimcache:" & tmpDir,
    nimSrcFile,
  ]
  cmd &= flags.join(" ")
  
  # execute the command
  let (output, exitCode) = execCmdEx(cmd)
  if exitCode != 0: # testing
    raise newException(IOError, "Failed to compile nim:\n" & output)

  # copy nim generated files to sketch dir
  for item in walkDir(tmpDir):
    if item.path.contains("@"): copyFileToDir(item.path, finalSketchDir)

  # copy nimbase.h to sketch dir (refreshing it to avoid any potential conflicts)
  copyNimbaseH(finalSketchDir)

  echo "Successfully compiled nim to Sketch directory!"

  # return the sketch directory
  result = finalSketchDir


proc upload*(sketchDir, fqbn, port: string = "", autoInstallCore: bool = true, verbose: bool = false) =
  
  var finalSketchDir = sketchDir
  if finalSketchDir.len == 0:
    for item in walkDir(getCurrentDir()):
      if item.kind == pcDir and item.path.contains("sketch_"):
        finalSketchDir = item.path
        break
  else:
    if not dirExists(finalSketchDir):
      raise newException(IOError, "Sketch directory: '" & finalSketchDir & "' does not exist.\n" &
        "Alternatively, specify the sketch directory explicitly when uploading / flashing.") 

  # determine the fqbn and port to use (if not passed explicitly)
  var finalFqbn = fqbn
  var finalPort = port
  if finalFqbn.len == 0 or finalPort.len == 0:
    try:
      let activeBoard = getActiveBoard()
      if finalFqbn.len == 0: finalFqbn = activeBoard.fqbn
      if finalPort.len == 0: finalPort = activeBoard.port
    except:
      let output = getCurrentExceptionMsg() & "\nAlternatively, specify the fqbn and port explicitly when uploading / flashing."
      raise newException(CatchableError, output)

  # make sure the board's core is installed before compiling / uploading
  ensureCoreInstalled(finalFqbn, autoInstallCore)

  echo "Uploading, flashing to board (" & finalFqbn & " on " & finalPort & ")...\n"

  # build the command
  # ref: https://arduino.github.io/arduino-cli/1.5/getting-started/
  var cmd = "arduino-cli compile -b " & finalFqbn & " -p " & finalPort & " --clean --upload --verify "
  if verbose: cmd &= "-v "
  cmd &= finalSketchDir

  # execute the command
  let output = execProcess(cmd) # here we use execProcess instead of execCmdEx because we want the output regardless
  echo "Arduino-CLI output:\n\n" & output



when isMainModule: # dummy testing
  let sketchDir = createSketch(currentSourcePath.parentDir.parentDir.parentDir / "examples" / "blink.nim")
  upload(verbose=false)
  let activeBoard = getActiveBoard()
  echo activeBoard.fqbn & " on " & activeBoard.port
  let boards = listBoards()
  for board in boards:
    echo board