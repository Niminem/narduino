## Bindings for the ArduinoGraphics library (ArduinoGraphics.h), including
## the Font (Font.h) and Image (Image.h) helper types that ship with it.
##
## Base class providing drawing, text, and shape methods for
## ArduinoGraphics-compatible displays.
## Install via: narduino libinstall --lib:ArduinoGraphics
##
## ArduinoGraphics is abstract (pure virtual `set`). It cannot be
## instantiated directly — use a concrete subclass like ArduinoLEDMatrix,
## whose Nim type inherits from ArduinoGraphics so every proc in this
## module can be called on it directly.

import ../api/wstring

{.emit: """#include "ArduinoGraphics.h"""".} # IMPORTANT: must be included before
                                          # any other imports that reference it

const header = "ArduinoGraphics.h"

# ==========================================================================
# Constants
# ==========================================================================

const
  # Scroll directions for endText (anonymous enum in ArduinoGraphics.h)
  NO_SCROLL*: cint = 0
  SCROLL_LEFT*: cint = 1
  SCROLL_RIGHT*: cint = 2
  SCROLL_UP*: cint = 3
  SCROLL_DOWN*: cint = 4

const
  # Image pixel encodings (anonymous enum in Image.h)
  ENCODING_NONE*: cint = -1
  ENCODING_RGB*: cint = 0
  ENCODING_RGB24*: cint = 1
  ENCODING_RGB16*: cint = 2

# ==========================================================================
# Types
# ==========================================================================

type
  ArduinoGraphics* {.importcpp: "ArduinoGraphics", header: header,
                     inheritable, byref.} = object
    ## Abstract base class for ArduinoGraphics-compatible displays.
    ## Cannot be instantiated directly. `inheritable` so concrete display
    ## wrappers (e.g. ArduinoLEDMatrix) can derive from it and reuse all
    ## procs in this module; `byref` because the class is abstract and
    ## must never be copied.

  Font* {.importcpp: "Font", header: header, byref.} = object
    ## Bitmap font descriptor (Font.h). `byref` because the C++ API only
    ## ever takes it by const reference, so Nim must not copy it.

  Image* {.importcpp: "Image", header: header, byref.} = object
    ## Image descriptor (Image.h). Holds a pointer to caller-owned pixel
    ## data; it does not copy it. `byref` because the C++ API only ever
    ## takes it by const reference.

# ==========================================================================
# Built-in fonts
# ==========================================================================

{.push importc, nodecl, header: header.}
let
  Font_4x6*: Font
  Font_5x7*: Font
{.pop.}

{.push header: header.}

# ==========================================================================
# Font construction and accessors
# ==========================================================================

proc initFont*(width, height: cint, data: ptr ptr uint8): Font
  {.importcpp: "(Font{#, #, (const uint8_t**)(#)})".}
  ## Create a custom font. `data` points to an array of per-character
  ## glyph bitmaps (one byte per row, MSB = leftmost pixel). The glyph
  ## data is not copied and must outlive the Font.

proc width*(f: Font): cint {.importcpp: "#.width".}
  ## Glyph width in pixels.

proc height*(f: Font): cint {.importcpp: "#.height".}
  ## Glyph height in pixels.

proc data*(f: Font): ptr ptr uint8 {.importcpp: "((uint8_t**)(#.data))".}
  ## Raw glyph bitmap table.

# ==========================================================================
# Image construction and accessors
# ==========================================================================

proc initImage*(): Image {.importcpp: "Image()", constructor.}
  ## Empty, invalid image (ENCODING_NONE, no data). isValid returns false.

proc initImage*(encoding: cint, data: ptr uint8, width, height: cint): Image
  {.importcpp: "Image(@)", constructor.}
  ## Image over byte-oriented pixel data (e.g. ENCODING_RGB: 3 bytes per
  ## pixel). The pixel data is not copied and must outlive the Image.

proc initImage*(encoding: cint, data: ptr uint16, width, height: cint): Image
  {.importcpp: "Image(@)", constructor.}
  ## Image over 16-bit pixel data (ENCODING_RGB16: RGB565 per pixel).
  ## The pixel data is not copied and must outlive the Image.

proc initImage*(encoding: cint, data: ptr uint32, width, height: cint): Image
  {.importcpp: "Image(@)", constructor.}
  ## Image over 32-bit pixel data (ENCODING_RGB24: 0x00RRGGBB per pixel).
  ## The pixel data is not copied and must outlive the Image.

proc encoding*(img: Image): cint {.importcpp.}
  ## Pixel encoding (one of the ENCODING_* constants).

proc data*(img: Image): ptr uint8 {.importcpp: "((uint8_t*)(#.data()))".}
  ## Raw pixel data pointer.

proc width*(img: Image): cint {.importcpp.}
  ## Image width in pixels.

proc height*(img: Image): cint {.importcpp.}
  ## Image height in pixels.

proc isValid*(img: Image): bool {.importcpp: "((bool)(#))".}
  ## C++ `operator bool`: true when the image has a valid encoding,
  ## data pointer, and dimensions.

# ==========================================================================
# Lifecycle
# ==========================================================================

proc begin*(g: var ArduinoGraphics): cint {.importcpp, discardable.}
  ## Initialize the graphics subsystem. Returns non-zero on success.

proc endGraphics*(g: var ArduinoGraphics) {.importcpp: "#.end()".}
  ## End the graphics subsystem. Named endGraphics because `end` is a
  ## Nim keyword.

# ==========================================================================
# Properties
# ==========================================================================

proc width*(g: ArduinoGraphics): cint {.importcpp.}
  ## Canvas width in pixels.

proc height*(g: ArduinoGraphics): cint {.importcpp.}
  ## Canvas height in pixels.

proc background*(g: ArduinoGraphics): uint32 {.importcpp.}
  ## Get the current background color as a packed uint32.

# ==========================================================================
# Drawing state
# ==========================================================================

proc beginDraw*(g: var ArduinoGraphics) {.importcpp.}
  ## Begin a drawing operation. Call endDraw() when finished.

proc endDraw*(g: var ArduinoGraphics) {.importcpp.}
  ## End a drawing operation and display the result.

proc background*(g: var ArduinoGraphics, r, g2, b: uint8)
  {.importcpp: "#.background(@)".}
  ## Set the background color (RGB).

proc background*(g: var ArduinoGraphics, color: uint32)
  {.importcpp: "#.background(@)".}
  ## Set the background color (packed uint32).

proc clear*(g: var ArduinoGraphics) {.importcpp.}
  ## Clear the entire canvas to the background color.

proc clear*(g: var ArduinoGraphics, x, y: cint)
  {.importcpp: "((ArduinoGraphics&)#).clear(@)".}
  ## Clear a single pixel at (x, y) to the background color.
  ## Uses an explicit base-class cast because derived classes (e.g.
  ## ArduinoLEDMatrix) declare their own clear() which hides this overload.

proc fill*(g: var ArduinoGraphics, r, g2, b: uint8)
  {.importcpp: "#.fill(@)".}
  ## Set the fill color (RGB) for shapes.

proc fill*(g: var ArduinoGraphics, color: uint32)
  {.importcpp: "#.fill(@)".}
  ## Set the fill color (packed uint32) for shapes.

proc noFill*(g: var ArduinoGraphics) {.importcpp.}
  ## Disable fill for subsequent shapes.

proc stroke*(g: var ArduinoGraphics, r, g2, b: uint8)
  {.importcpp: "#.stroke(@)".}
  ## Set the stroke (outline) color (RGB).

proc stroke*(g: var ArduinoGraphics, color: uint32)
  {.importcpp: "#.stroke(@)".}
  ## Set the stroke (outline) color (packed uint32).

proc noStroke*(g: var ArduinoGraphics) {.importcpp.}
  ## Disable stroke for subsequent shapes.

# ==========================================================================
# Shapes
# ==========================================================================

proc circle*(g: var ArduinoGraphics, x, y, diameter: cint) {.importcpp.}

proc ellipse*(g: var ArduinoGraphics, x, y, width, height: cint) {.importcpp.}

proc line*(g: var ArduinoGraphics, x1, y1, x2, y2: cint) {.importcpp.}

proc point*(g: var ArduinoGraphics, x, y: cint) {.importcpp.}

proc rect*(g: var ArduinoGraphics, x, y, width, height: cint) {.importcpp.}

# ==========================================================================
# Text
# ==========================================================================

proc text*(g: var ArduinoGraphics, str: cstring, x: cint = 0, y: cint = 0)
  {.importcpp.}
  ## Draw a text string at (x, y).

proc text*(g: var ArduinoGraphics, str: String, x: cint = 0, y: cint = 0)
  {.importcpp.}
  ## Draw an Arduino String at (x, y).

proc textFont*(g: var ArduinoGraphics, which: Font) {.importcpp.}
  ## Set the font for text rendering (e.g. Font_4x6, Font_5x7).

proc textSize*(g: var ArduinoGraphics, s: uint8) {.importcpp.}
  ## Set uniform text scale.

proc textSize*(g: var ArduinoGraphics, sx, sy: uint8) {.importcpp.}
  ## Set independent horizontal and vertical text scale.

proc textFontWidth*(g: ArduinoGraphics): cint {.importcpp.}
  ## Width of the current font in pixels.

proc textFontHeight*(g: ArduinoGraphics): cint {.importcpp.}
  ## Height of the current font in pixels.

proc beginText*(g: var ArduinoGraphics, x: cint = 0, y: cint = 0)
  {.importcpp.}
  ## Begin text rendering at (x, y). Use print/println/write to add
  ## characters, then call endText() to display.

proc beginText*(g: var ArduinoGraphics, x, y: cint, r, g2, b: uint8)
  {.importcpp: "#.beginText(@)".}
  ## Begin text rendering at (x, y) with the given RGB color.

proc beginText*(g: var ArduinoGraphics, x, y: cint, color: uint32)
  {.importcpp: "#.beginText(@)".}
  ## Begin text rendering at (x, y) with a packed uint32 color.

proc endText*(g: var ArduinoGraphics, scroll: cint = NO_SCROLL) {.importcpp.}
  ## Finish text rendering and display the result.

proc textScrollSpeed*(g: var ArduinoGraphics, speed: culong = 150)
  {.importcpp.}
  ## Set the scroll speed (in ms per step) for text animations.

# ==========================================================================
# Image
# ==========================================================================

proc image*(g: var ArduinoGraphics, img: Image, x, y: cint) {.importcpp.}
  ## Draw an image at (x, y) at its native size.

proc image*(g: var ArduinoGraphics, img: Image, x, y, width, height: cint)
  {.importcpp.}
  ## Draw an image at (x, y) scaled to width x height.

# ==========================================================================
# Pixel
# ==========================================================================

proc set*(g: var ArduinoGraphics, x, y: cint, r, g2, b: uint8)
  {.importcpp: "#.set(@)".}
  ## Set a pixel at (x, y) using RGB values. Pure virtual in the base
  ## class — must be implemented by subclasses.

proc set*(g: var ArduinoGraphics, x, y: cint, color: uint32)
  {.importcpp: "((ArduinoGraphics&)#).set(@)".}
  ## Set a pixel at (x, y) using a packed uint32 color.
  ## Uses an explicit base-class cast because derived classes (e.g.
  ## ArduinoLEDMatrix) declare set(x,y,r,g,b) which hides this overload.

# ==========================================================================
# Print (inherited from the Arduino Print base class)
#
# Between beginText()/endText() these append to the text buffer, the
# same way `matrix.println("...")` is used in the official C++ examples.
# ==========================================================================

proc write*(g: var ArduinoGraphics, b: uint8): csize_t
  {.importcpp, discardable.}
  ## Write a single byte to the text buffer.

proc write*(g: var ArduinoGraphics, str: cstring): csize_t
  {.importcpp: "((Print&)#).write((const char*)#)", discardable.}
  ## Write a NUL-terminated string to the text buffer.
  ## Casts to Print& because ArduinoGraphics::write(uint8_t) hides
  ## this overload from the Print base class.

proc write*(g: var ArduinoGraphics, buffer: ptr uint8, size: csize_t): csize_t
  {.importcpp: "((Print&)#).write((const uint8_t*)#, #)", discardable.}
  ## Write `size` bytes from `buffer` to the text buffer.
  ## Casts to Print& because ArduinoGraphics::write(uint8_t) hides
  ## this overload from the Print base class.

proc flush*(g: var ArduinoGraphics) {.importcpp.}
  ## Flush pending output.

proc print*(g: var ArduinoGraphics, value: cstring): csize_t
  {.importcpp, discardable.}
proc print*(g: var ArduinoGraphics, value: char): csize_t
  {.importcpp: "#.print((char)#)", discardable.}
proc print*(g: var ArduinoGraphics, value: cdouble, digits: cint = 2): csize_t
  {.importcpp, discardable.}
proc print*(g: var ArduinoGraphics, value: String): csize_t
  {.importcpp, discardable.}
proc print*(g: var ArduinoGraphics, value: ptr FlashStringHelper): csize_t
  {.importcpp, discardable.}
proc printSigned(g: var ArduinoGraphics, value: int32, base: cint): csize_t
  {.importcpp: "#.print((long)(#), #)", discardable.}
proc printUnsigned(g: var ArduinoGraphics, value: uint32, base: cint): csize_t
  {.importcpp: "#.print((unsigned long)(#), #)", discardable.}

proc println*(g: var ArduinoGraphics): csize_t {.importcpp, discardable.}
proc println*(g: var ArduinoGraphics, value: cstring): csize_t
  {.importcpp, discardable.}
proc println*(g: var ArduinoGraphics, value: char): csize_t
  {.importcpp: "#.println((char)#)", discardable.}
proc println*(g: var ArduinoGraphics, value: cdouble, digits: cint = 2): csize_t
  {.importcpp, discardable.}
proc println*(g: var ArduinoGraphics, value: String): csize_t
  {.importcpp, discardable.}
proc println*(g: var ArduinoGraphics, value: ptr FlashStringHelper): csize_t
  {.importcpp, discardable.}
proc printlnSigned(g: var ArduinoGraphics, value: int32, base: cint): csize_t
  {.importcpp: "#.println((long)(#), #)", discardable.}
proc printlnUnsigned(g: var ArduinoGraphics, value: uint32, base: cint): csize_t
  {.importcpp: "#.println((unsigned long)(#), #)", discardable.}

{.pop.}

template print*(g: var ArduinoGraphics, value: SomeInteger,
                base: cint = 10): csize_t =
  when value is SomeUnsignedInt:
    printUnsigned(g, uint32(value), base)
  else:
    printSigned(g, int32(value), base)

template println*(g: var ArduinoGraphics, value: SomeInteger,
                  base: cint = 10): csize_t =
  when value is SomeUnsignedInt:
    printlnUnsigned(g, uint32(value), base)
  else:
    printlnSigned(g, int32(value), base)
