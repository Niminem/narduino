## Bindings for the Arduino String class (WString.h) and related types.
##
## The Arduino String is a heap-allocating, mutable string class backed by
## a NUL-terminated char buffer on the free store.  On small AVR targets it
## is prone to heap fragmentation; prefer fixed-size char buffers
## (readBytes/readBytesUntil) when memory is tight.
##
## Compiler note (from WString.h): the following avr-gcc flags can
## dramatically improve performance and RAM efficiency for code using
## this class, typically with little or no increase in code size:
##
## .. code-block::
##   -felide-constructors
##   -std=c++0x


type
  FlashStringHelper* {.importcpp: "__FlashStringHelper",
                       header: "WString.h", incompleteStruct, byref.} = object
    ## Opaque handle for a string stored in program memory (flash/PROGMEM).
    ## Obtained via the F() macro.

  String* {.importcpp: "String", header: "WString.h".} = object
    ## The Arduino String class.  Heap-allocating and fragmentation-prone on
    ## small targets; prefer caller-owned buffers (readBytes/readBytesUntil)
    ## when memory is tight.

proc F*(s: cstring): ptr FlashStringHelper {.importc: "F", header: "Arduino.h".}
  ## Places a string literal in flash (PROGMEM) and returns a pointer
  ## suitable for passing to String/print overloads that accept
  ## FlashStringHelper.  Only meaningful with compile-time string literals.

# ==========================================================================
# Constructors
# ==========================================================================

{.push header: "WString.h".}

proc initString*(): String {.importcpp: "String()", constructor.}
  ## Empty string (zero length, allocated).
proc initString*(cstr: cstring): String {.importcpp: "String(@)", constructor.}
  ## Copy from a NUL-terminated C string.
proc initString*(s: String): String {.importcpp: "String(@)", constructor.}
  ## Copy constructor.
proc initString*(s: ptr FlashStringHelper): String {.importcpp: "String(@)", constructor.}
  ## Copy from a PROGMEM string (F() result).
proc initString*(c: char): String {.importcpp: "String((char)#)", constructor.}
  ## Single character.
proc initString*(val: cfloat, decimalPlaces: uint8 = 2): String
  {.importcpp: "String((float)(#), (unsigned char)(#))", constructor.}
  ## Float formatted to `decimalPlaces` digits after the point.
proc initString*(val: cdouble, decimalPlaces: uint8 = 2): String
  {.importcpp: "String((double)(#), (unsigned char)(#))", constructor.}
  ## Double formatted to `decimalPlaces` digits after the point.

proc initStringSigned(val: int32, base: uint8): String
  {.importcpp: "String((long)(#), (unsigned char)(#))", constructor.}
proc initStringUnsigned(val: uint32, base: uint8): String
  {.importcpp: "String((unsigned long)(#), (unsigned char)(#))", constructor.}

{.pop.}

template initString*(val: SomeInteger, base: uint8 = 10): String =
  ## Integer formatted in the given base (default decimal).
  ## Use DEC (10), HEX (16), OCT (8), or BIN (2).
  when val is SomeUnsignedInt:
    initStringUnsigned(uint32(val), base)
  else:
    initStringSigned(int32(val), base)

# ==========================================================================
# Validity check (safe-bool idiom)
# ==========================================================================

proc isValid*(s: String): bool {.importcpp: "((#) ? true : false)", header: "WString.h".}
  ## True when the String holds a valid (allocated) buffer.
  ## Use `if myStr.isValid:` to check for allocation success.

# ==========================================================================
# Memory management
# ==========================================================================

{.push header: "WString.h".}

proc reserve*(s: var String, size: cuint): bool {.importcpp.}
  ## Pre-allocate internal buffer to at least `size` bytes.
  ## Returns true on success; on failure the string is unchanged.
  ## `reserve(0)` on an invalid string makes it valid (empty).

proc length*(s: String): cuint {.importcpp.}
  ## Current number of characters (excluding the NUL terminator).

proc len*(s: String): cuint {.importcpp: "#.length()".}
  ## Alias for `length` — Nim convention.

# ==========================================================================
# Concatenation (in-place append)
# ==========================================================================

proc concat*(s: var String, str: String): bool {.importcpp.}
proc concat*(s: var String, cstr: cstring): bool {.importcpp.}
proc concat*(s: var String, c: char): bool {.importcpp: "#.concat((char)#)".}
proc concatSigned(s: var String, num: int32): bool
  {.importcpp: "#.concat((long)#)".}
proc concatUnsigned(s: var String, num: uint32): bool
  {.importcpp: "#.concat((unsigned long)#)".}
proc concat*(s: var String, num: cfloat): bool {.importcpp.}
proc concat*(s: var String, num: cdouble): bool {.importcpp.}
proc concat*(s: var String, str: ptr FlashStringHelper): bool {.importcpp.}

{.pop.}

template concat*(s: var String, val: SomeInteger): bool =
  when val is SomeUnsignedInt:
    concatUnsigned(s, uint32(val))
  else:
    concatSigned(s, int32(val))

template add*(s: var String, val: String) = discard s.concat(val)
template add*(s: var String, val: cstring) = discard s.concat(val)
template add*(s: var String, val: char) = discard s.concat(val)
template add*(s: var String, val: cfloat) = discard s.concat(val)
template add*(s: var String, val: cdouble) = discard s.concat(val)
template add*(s: var String, val: ptr FlashStringHelper) = discard s.concat(val)
template add*(s: var String, val: SomeInteger) =
  when val is SomeUnsignedInt:
    discard concatUnsigned(s, uint32(val))
  else:
    discard concatSigned(s, int32(val))


template `&=`*(s: var String, val: String) = discard s.concat(val)
template `&=`*(s: var String, val: cstring) = discard s.concat(val)
template `&=`*(s: var String, val: char) = discard s.concat(val)
template `&=`*(s: var String, val: cfloat) = discard s.concat(val)
template `&=`*(s: var String, val: cdouble) = discard s.concat(val)
template `&=`*(s: var String, val: ptr FlashStringHelper) = discard s.concat(val)
template `&=`*(s: var String, val: SomeInteger) =
  when val is SomeUnsignedInt:
    discard concatUnsigned(s, uint32(val))
  else:
    discard concatSigned(s, int32(val))

# ==========================================================================
# Concatenation (creating a new String — via C++ operator+)
# ==========================================================================
#
# The C++ `+` uses StringSumHelper friend functions; importcpp delegates
# overload resolution to the C++ compiler.

{.push header: "WString.h".}

proc `+`*(a, b: String): String {.importcpp: "(# + #)".}
proc `+`*(a: String, b: cstring): String {.importcpp: "(# + #)".}
proc `+`*(a: String, b: char): String {.importcpp: "(# + (char)#)".}
proc `+`*(a: String, b: int32): String {.importcpp: "(# + (long)#)".}
proc `+`*(a: String, b: uint32): String {.importcpp: "(# + (unsigned long)#)".}
proc `+`*(a: String, b: cfloat): String {.importcpp: "(# + #)".}
proc `+`*(a: String, b: cdouble): String {.importcpp: "(# + #)".}
proc `+`*(a: String, b: ptr FlashStringHelper): String {.importcpp: "(# + #)".}

{.pop.}

# Nim-idiomatic `&` as alias for `+`
template `&`*(a, b: String): String = a + b
template `&`*(a: String, b: cstring): String = a + b
template `&`*(a: String, b: char): String = a + b

# ==========================================================================
# Comparison
# ==========================================================================

{.push header: "WString.h".}

proc compareTo*(s: String, other: String): cint {.importcpp.}
  ## Lexicographic compare: <0, 0, or >0.

proc equals*(s: String, other: String): bool {.importcpp.}
proc equals*(s: String, cstr: cstring): bool {.importcpp.}
proc equalsIgnoreCase*(s: String, other: String): bool {.importcpp.}

proc startsWith*(s: String, prefix: String): bool {.importcpp.}
proc startsWith*(s: String, prefix: String, offset: cuint): bool {.importcpp.}
proc endsWith*(s: String, suffix: String): bool {.importcpp.}

{.pop.}

# Nim operators — `!=` and `>` are auto-derived from `==` and `<`.
proc `==`*(a, b: String): bool {.importcpp: "(# == #)", header: "WString.h".}
proc `==`*(a: String, b: cstring): bool {.importcpp: "(# == #)", header: "WString.h".}
proc `<`*(a, b: String): bool {.importcpp: "(# < #)", header: "WString.h".}
proc `<=`*(a, b: String): bool {.importcpp: "(# <= #)", header: "WString.h".}

# ==========================================================================
# Character access
# ==========================================================================

{.push header: "WString.h".}

proc charAt*(s: String, index: cuint): char {.importcpp.}
proc setCharAt*(s: var String, index: cuint, c: char)
  {.importcpp: "#.setCharAt(#, (char)#)".}

proc `[]`*(s: String, index: cuint): char {.importcpp.}
proc `[]=`*(s: var String, index: cuint, c: char)
  {.importcpp: "#[#] = (char)(#)".}

proc getBytes*(s: String, buf: ptr uint8, bufsize: cuint, index: cuint = 0)
  {.importcpp.}
  ## Copies up to `bufsize` bytes of the String (from `index`) into `buf`.
proc toCharArray*(s: String, buf: cstring, bufsize: cuint, index: cuint = 0)
  {.importcpp.}
  ## Same as getBytes but typed for a char buffer.
proc c_str*(s: String): cstring {.importcpp.}
  ## Direct pointer to the internal NUL-terminated buffer.  Valid only as
  ## long as the String is not modified or destroyed.

{.pop.}

template getBytes*(s: String, buf: var openArray[uint8]) =
  getBytes(s, addr buf[0], cuint(buf.len))

# ==========================================================================
# Search
# ==========================================================================

{.push header: "WString.h".}

proc indexOf*(s: String, ch: char): cint {.importcpp: "#.indexOf((char)#)".}
proc indexOf*(s: String, ch: char, fromIndex: cuint): cint
  {.importcpp: "#.indexOf((char)#, #)".}
proc indexOf*(s: String, str: String): cint {.importcpp.}
proc indexOf*(s: String, str: String, fromIndex: cuint): cint {.importcpp.}

proc lastIndexOf*(s: String, ch: char): cint {.importcpp: "#.lastIndexOf((char)#)".}
proc lastIndexOf*(s: String, ch: char, fromIndex: cuint): cint
  {.importcpp: "#.lastIndexOf((char)#, #)".}
proc lastIndexOf*(s: String, str: String): cint {.importcpp.}
proc lastIndexOf*(s: String, str: String, fromIndex: cuint): cint {.importcpp.}

proc substring*(s: String, beginIndex: cuint): String {.importcpp.}
proc substring*(s: String, beginIndex: cuint, endIndex: cuint): String {.importcpp.}

{.pop.}

# ==========================================================================
# Modification (mutating)
# ==========================================================================

{.push header: "WString.h".}

proc replace*(s: var String, find: char, replaceWith: char)
  {.importcpp: "#.replace((char)#, (char)#)".}
proc replace*(s: var String, find: String, replaceWith: String) {.importcpp.}
proc remove*(s: var String, index: cuint) {.importcpp.}
proc remove*(s: var String, index: cuint, count: cuint) {.importcpp.}
proc toLowerCase*(s: var String) {.importcpp.}
proc toUpperCase*(s: var String) {.importcpp.}
proc trim*(s: var String) {.importcpp.}

{.pop.}

# ==========================================================================
# Parsing / conversion
# ==========================================================================

{.push header: "WString.h".}

proc toInt*(s: String): int32 {.importcpp.}
  ## Parses the String as a decimal integer.  Returns 0 on failure.
proc toFloat*(s: String): cfloat {.importcpp.}
  ## Parses the String as a floating-point number.  Returns 0.0 on failure.
proc toDouble*(s: String): cdouble {.importcpp.}
  ## Parses the String as a double.  Returns 0.0 on failure.

{.pop.}
