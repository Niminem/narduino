## Bindings for the Arduino Serial (HardwareSerial) class.
##
## The function list mirrors the official reference:
## https://docs.arduino.cc/language-reference/en/functions/communication/serial/
## mapped against the local AVR core headers (1.8.8):
## HardwareSerial.h (begin/end/write/...), Stream.h (find/parse/read*/*Timeout),
## Print.h (print/println)
##
## Intentionally not wrapped:
## - the write(int/long/...) helpers, which silently truncate to one byte in
##   C++. write(uint8) covers them and makes out-of-range values an error
## - serialEvent(): only ever called by classic AVR cores (silent no-op on
##   modern boards). poll `available()` at the top of `loop:` instead

import wstring

type
  SerialObj* {.incompleteStruct, byref.} = object

{.push importc, nodecl, header:"Arduino.h".}
# Serial objects
var Serial*: SerialObj
var Serial1*: SerialObj
var Serial2*: SerialObj
var Serial3*: SerialObj
let
  # print / println number bases (from Print.h)
  DEC*: cint
  HEX*: cint
  OCT*: cint
  BIN*: cint
  # begin(baud, config) frame configs (from HardwareSerial.h)
  SERIAL_5N1*: uint8
  SERIAL_6N1*: uint8
  SERIAL_7N1*: uint8
  SERIAL_8N1*: uint8 # default
  SERIAL_5N2*: uint8
  SERIAL_6N2*: uint8
  SERIAL_7N2*: uint8
  SERIAL_8N2*: uint8
  SERIAL_5E1*: uint8
  SERIAL_6E1*: uint8
  SERIAL_7E1*: uint8
  SERIAL_8E1*: uint8
  SERIAL_5E2*: uint8
  SERIAL_6E2*: uint8
  SERIAL_7E2*: uint8
  SERIAL_8E2*: uint8
  SERIAL_5O1*: uint8
  SERIAL_6O1*: uint8
  SERIAL_7O1*: uint8
  SERIAL_8O1*: uint8
  SERIAL_5O2*: uint8
  SERIAL_6O2*: uint8
  SERIAL_7O2*: uint8
  SERIAL_8O2*: uint8
{.pop.}

type
  LookaheadMode* {.importcpp: "LookaheadMode", header: "Arduino.h", size: sizeof(cint).} = enum
    ## Lookahead options for parseInt() / parseFloat() (from Stream.h)
    SKIP_ALL,       ## all invalid characters are ignored (default)
    SKIP_NONE,      ## nothing is skipped; first waiting character must be valid
    SKIP_WHITESPACE ## only tabs, spaces, line feeds & carriage returns are skipped

const NO_IGNORE_CHAR* = '\x01'
  ## Default `ignore` for parseInt/parseFloat: a char not found in valid
  ## numeric fields (Stream.h #undefs its macro, so it's a Nim const here)

# if (Serial) - reports whether the port is ready (USB CDC boards
# return false until a host opens the port; classic AVR always true).
proc isReady*(s: SerialObj): bool {.importcpp: "((bool)(#))".}

{.push header: "Arduino.h".}

proc available*(s: SerialObj): cint {.importcpp.}
proc availableForWrite*(s: SerialObj): cint {.importcpp.}
proc begin*(s: SerialObj, baud: uint32) {.importcpp.}
proc begin*(s: SerialObj, baud: uint32, config: uint8) {.importcpp.}
proc `end`*(s: SerialObj) {.importcpp.}
proc find*(s: SerialObj, target: cstring): bool {.importcpp.}
proc find*(s: SerialObj, target: cstring, length: csize_t): bool {.importcpp.}
proc find*(s: SerialObj, target: char): bool {.importcpp: "#.find((char)#)".}
proc findUntil*(s: SerialObj, target: cstring, terminal: cstring): bool {.importcpp.}
proc flush*(s: SerialObj) {.importcpp.}
proc parseFloat*(s: SerialObj, lookahead: LookaheadMode = SKIP_ALL,
                 ignore: char = NO_IGNORE_CHAR): cfloat {.importcpp: "#.parseFloat(#, (char)#)".}
proc parseInt*(s: SerialObj, lookahead: LookaheadMode = SKIP_ALL,
                 ignore: char = NO_IGNORE_CHAR): int32 {.importcpp: "#.parseInt(#, (char)#)".}
proc peek*(s: SerialObj): cint {.importcpp.}
proc print*(s: SerialObj, value: cstring): csize_t {.importcpp, discardable.}
proc print*(s: SerialObj, value: char): csize_t {.importcpp: "#.print((char)#)", discardable.}
proc print*(s: SerialObj, value: cdouble, digits: cint = 2): csize_t {.importcpp, discardable.}
proc printSigned(s: SerialObj, value: int32, base: cint): csize_t
  {.importcpp: "#.print((long)(#), #)", discardable.}
proc printUnsigned(s: SerialObj, value: uint32, base: cint): csize_t
  {.importcpp: "#.print((unsigned long)(#), #)", discardable.}
proc println*(s: SerialObj): csize_t {.importcpp, discardable.}
proc println*(s: SerialObj, value: cstring): csize_t {.importcpp, discardable.}
proc println*(s: SerialObj, value: char): csize_t {.importcpp: "#.println((char)#)", discardable.}
proc println*(s: SerialObj, value: cdouble, digits: cint = 2): csize_t {.importcpp, discardable.}
proc printlnSigned(s: SerialObj, value: int32, base: cint): csize_t
  {.importcpp: "#.println((long)(#), #)", discardable.}
proc printlnUnsigned(s: SerialObj, value: uint32, base: cint): csize_t
  {.importcpp: "#.println((unsigned long)(#), #)", discardable.}
proc print*(s: SerialObj, value: String): csize_t {.importcpp, discardable.}
proc print*(s: SerialObj, value: ptr FlashStringHelper): csize_t {.importcpp, discardable.}
proc println*(s: SerialObj, value: String): csize_t {.importcpp, discardable.}
proc println*(s: SerialObj, value: ptr FlashStringHelper): csize_t {.importcpp, discardable.}
proc read*(s: SerialObj): cint {.importcpp.}
  ## Returns the next incoming byte, or -1 if none is available
proc readBytes*(s: SerialObj, buffer: ptr uint8, length: csize_t): csize_t {.importcpp.}
  ## Reads up to `length` bytes into `buffer`; stops early on timeout
  ## (setTimeout). Returns the number of bytes placed in the buffer.
proc readBytesUntil*(s: SerialObj, terminator: char, buffer: ptr uint8,
                     length: csize_t): csize_t {.importcpp: "#.readBytesUntil((char)#, #, #)".}
  ## As readBytes, but also stops at `terminator` (which is discarded
  ## from the stream and not stored in the buffer)
proc readString*(s: SerialObj): String {.importcpp.}
  ## Reads incoming serial data into a String until timeout (setTimeout)
proc readStringUntil*(s: SerialObj, terminator: char): String
  {.importcpp: "#.readStringUntil((char)#)".}
  ## Reads incoming serial data into a String until `terminator` or timeout
proc setTimeout*(s: SerialObj, time: uint32 = 1000'u32) {.importcpp.}
proc write*(s: SerialObj, value: uint8): csize_t {.importcpp, discardable.}
proc write*(s: SerialObj, str: cstring): csize_t {.importcpp, discardable.}
proc write*(s: SerialObj, buffer: ptr uint8, size: csize_t): csize_t {.importcpp, discardable.}
proc getTimeout*(s: SerialObj): uint32 {.importcpp.} ## technically from Stream.h

{.pop.}

template print*(s: SerialObj, value: SomeInteger, base: cint = 10): csize_t =
  when value is SomeUnsignedInt:
    printUnsigned(s, uint32(value), base)
  else:
    printSigned(s, int32(value), base)

template println*(s: SerialObj, value: SomeInteger, base: cint = 10): csize_t =
  when value is SomeUnsignedInt:
    printlnUnsigned(s, uint32(value), base)
  else:
    printlnSigned(s, int32(value), base)

# Convenience overloads taking any byte buffer (e.g. array[N, uint8]),
# deriving the length from the buffer itself so it can't be misstated
template readBytes*(s: SerialObj, buf: var openArray[uint8]): csize_t =
  readBytes(s, addr buf[0], csize_t(buf.len))
template readBytesUntil*(s: SerialObj, terminator: char,
                         buf: var openArray[uint8]): csize_t =
  readBytesUntil(s, terminator, addr buf[0], csize_t(buf.len))
template write*(s: SerialObj, buf: openArray[uint8]): csize_t =
  write(s, unsafeAddr buf[0], csize_t(buf.len))