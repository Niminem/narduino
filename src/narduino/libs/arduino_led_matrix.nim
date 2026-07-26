## Bindings for the Arduino LED Matrix library (Arduino_LED_Matrix.h).
##
## Wraps the ArduinoLEDMatrix class for the UNO R4 WiFi's built-in
## 12x8 charlieplexed LED matrix. Included in the R4 WiFi board package.
##
## ArduinoLEDMatrix derives from ArduinoGraphics, so every proc from
## arduino_graphics (beginDraw, beginText, text, set, endText, print,
## println, ...) works directly on an ArduinoLEDMatrix. That module is
## imported and re-exported here; the ArduinoGraphics library MUST be
## installed (narduino libinstall --lib:ArduinoGraphics), which also
## enables the graphics half of the C++ class itself.
##
## The C++ overrides (set, endText, endDraw, textScrollSpeed) are virtual,
## so the base-class bindings dispatch to the matrix implementations —
## they are not redeclared here. begin() and clear() shadow the base
## versions in C++ and therefore have their own bindings below.

import arduino_graphics
export arduino_graphics

const header = "Arduino_LED_Matrix.h"

const NUM_LEDS* = 96
  ## Total number of individually addressable LEDs in the matrix (12x8).

type
  ArduinoLEDMatrix* {.importcpp: "ArduinoLEDMatrix",
                      header: header.} = object of ArduinoGraphics
    ## The Arduino LED Matrix controller for the UNO R4 WiFi's built-in
    ## 12x8 charlieplexed LED array. Inherits from ArduinoGraphics.

# ==========================================================================
# Constructor
# ==========================================================================

proc initArduinoLEDMatrix*(): ArduinoLEDMatrix
  {.importcpp: "ArduinoLEDMatrix()", constructor, header: header.}
  ## Create a new ArduinoLEDMatrix instance.

# ==========================================================================
# Core methods
# ==========================================================================

{.push header: header.}

proc begin*(m: var ArduinoLEDMatrix): cint {.importcpp, discardable.}
  ## Initialize the LED matrix timer and ISR. Returns non-zero on success.

proc autoscroll*(m: var ArduinoLEDMatrix, interval_ms: uint32) {.importcpp.}
  ## Set the auto-advance interval (in milliseconds) for frame sequences.
  ## The ISR will call next() automatically at this interval.

proc on*(m: var ArduinoLEDMatrix, pin: csize_t) {.importcpp.}
  ## Turn on a single LED by its linear index (0..95).

proc off*(m: var ArduinoLEDMatrix, pin: csize_t) {.importcpp.}
  ## Turn off a single LED by its linear index (0..95).

proc next*(m: var ArduinoLEDMatrix) {.importcpp.}
  ## Advance to the next frame in the currently loaded sequence.

proc loadFrame*(m: var ArduinoLEDMatrix, buffer: ptr uint32) {.importcpp.}
  ## Display a single 96-bit frame. `buffer` must point to 3 consecutive
  ## uint32 values encoding the 12x8 pixel state.

proc renderFrame*(m: var ArduinoLEDMatrix, frameNumber: uint8) {.importcpp.}
  ## Jump to and display a specific frame number in the loaded sequence.

proc play*(m: var ArduinoLEDMatrix, loop: bool = false) {.importcpp.}
  ## Start playing the loaded frame sequence. If `loop` is true, the
  ## sequence repeats indefinitely.

proc sequenceDone*(m: var ArduinoLEDMatrix): bool {.importcpp.}
  ## Returns true (once) when the loaded sequence has finished playing.
  ## Resets the internal flag after returning true.

proc loadPixels*(m: var ArduinoLEDMatrix, arr: ptr uint8, size: csize_t)
  {.importcpp.}
  ## Load a frame from a flat pixel byte array of the given size.

proc loadWrapper*(m: var ArduinoLEDMatrix, frames: ptr array[4, uint32],
                  howMany: uint32)
  {.importcpp: "#.loadWrapper((const uint32_t(*)[4])(#), #)".}
  ## Load a sequence of frames. `frames` points to a contiguous array of
  ## [4]uint32 entries (3 words of pixel data + 1 word duration per frame).
  ## `howMany` is the total byte size of the frames array.

proc setCallback*(m: var ArduinoLEDMatrix, callBack: proc() {.cdecl.})
  {.importcpp.}
  ## Register a callback invoked (from ISR context) when the sequence
  ## loops or completes. Keep the callback extremely short.

proc clear*(m: var ArduinoLEDMatrix) {.importcpp.}
  ## Turn off all LEDs and wipe the drawing canvas. Shadows (does not
  ## override) ArduinoGraphics.clear in C++, so this binding must exist
  ## for the matrix behavior to be selected.

{.pop.}

# ==========================================================================
# Static utility
# ==========================================================================

proc loadPixelsToBuffer*(arr: ptr uint8, size: csize_t, dst: ptr uint32)
  {.importcpp: "ArduinoLEDMatrix::loadPixelsToBuffer(@)", header: header.}
  ## Convert a flat pixel byte array into a 3x uint32 frame buffer.
  ## `dst` must point to space for at least 3 uint32 values.

# ==========================================================================
# ArduinoGraphics-dependent methods
# ==========================================================================

proc endTextToAnimationBuffer*(m: var ArduinoLEDMatrix,
                               scrollDirection: cint,
                               frames: ptr array[4, uint32],
                               howManyMax: uint32,
                               howManyUsed: var uint32)
  {.importcpp: "#.endTextToAnimationBuffer(#, (uint32_t(*)[4])(#), #, #)",
    header: header.}
  ## Render scrolling text into a frame buffer for later playback.
  ## `frames` points to a pre-allocated buffer of [4]uint32 entries.
  ## `howManyMax` is the total byte size of the buffer.
  ## `howManyUsed` receives the number of bytes actually written.

# ==========================================================================
# Convenience templates (replacing C preprocessor macros)
# ==========================================================================

template loadFrame*(m: var ArduinoLEDMatrix, buffer: var array[3, uint32]) =
  ## Display a single frame from a Nim array of 3 uint32.
  m.loadFrame(addr buffer[0])

template loadSequence*[N: static int](m: var ArduinoLEDMatrix,
                                      frames: var array[N, array[4, uint32]]) =
  ## Load a frame sequence from a Nim array. Each element is
  ## [pixel0, pixel1, pixel2, duration_ms].
  m.loadWrapper(addr frames[0], uint32(sizeof(frames)))

template renderBitmap*[R, C: static int](m: var ArduinoLEDMatrix,
                                         bitmap: var array[R, array[C, uint8]]) =
  ## Load and display a 2D bitmap array as a single frame.
  ## Rows and columns are inferred from the array dimensions.
  m.loadPixels(cast[ptr uint8](addr bitmap[0][0]), csize_t(R * C))

template endTextAnimation*[N: static int](m: var ArduinoLEDMatrix,
                                          scrollDirection: cint,
                                          frames: var array[N, array[4, uint32]],
                                          used: var uint32) =
  ## Render the pending scrolling text into `frames` for later playback
  ## (replaces the endTextAnimation C macro). `used` receives the number
  ## of bytes written; pass both to loadTextAnimationSequence afterwards.
  m.endTextToAnimationBuffer(scrollDirection, addr frames[0],
                             uint32(sizeof(frames)), used)

template loadTextAnimationSequence*[N: static int](m: var ArduinoLEDMatrix,
                                                   frames: var array[N, array[4, uint32]],
                                                   used: uint32) =
  ## Load a text animation previously captured with endTextAnimation
  ## (replaces the loadTextAnimationSequence C macro).
  m.loadWrapper(addr frames[0], used)
