## Bindings for the Adafruit DHT sensor library (DHT.h / DHT_U.h).
##
## Arduino library for DHT11, DHT22, etc Temperature & Humidity Sensors.
## Reference: https://github.com/adafruit/DHT-sensor-library
## Install via `narduino libinstall --lib:"DHT sensor library"`
##
## The basic DHT class provides direct temperature/humidity readings.
## The DHT_Unified class wraps it behind the Adafruit Unified Sensor
## interface (will be installed automatically when installing DHT sensor library)
## https://github.com/adafruit/adafruit_sensor

# ==========================================================================
# DHT (basic interface — DHT.h)
# ==========================================================================

{.push header: "DHT.h".}

const
  DHT11*: uint8 = 11   ## DHT Type 11
  DHT12*: uint8 = 12   ## DHT Type 12
  DHT21*: uint8 = 21   ## DHT Type 21
  DHT22*: uint8 = 22   ## DHT Type 22
  AM2301*: uint8 = 21  ## AM2301 (same as DHT21)

type
  DHT* {.importcpp: "DHT".} = object
    ## Class for reading temperature and humidity from DHTxx sensors.
    ## Handles the timing-critical one-wire protocol internally.

proc initDHT*(pin: uint8, sensorType: uint8, count: uint8 = 6): DHT
  {.importcpp: "DHT(@)", constructor.}
  ## Create a DHT sensor instance. `pin` is the data pin, `sensorType`
  ## is one of DHT11, DHT12, DHT21, DHT22, or AM2301. `count` is used
  ## to tune timing on faster processors (default 6 is fine for most).

proc begin*(d: var DHT, usec: uint8 = 55) {.importcpp.}
  ## Initialize the sensor. `usec` is the pull-up time in microseconds
  ## before reading (default 55).

proc readTemperature*(d: var DHT, fahrenheit: bool = false,
                      force: bool = false): cfloat {.importcpp.}
  ## Read temperature. Returns Celsius by default; set `fahrenheit` to
  ## true for Fahrenheit. Returns NaN on read failure. Set `force` to
  ## true to bypass the 2-second minimum read interval.

proc readHumidity*(d: var DHT, force: bool = false): cfloat {.importcpp.}
  ## Read relative humidity as a percentage. Returns NaN on read failure.
  ## Set `force` to true to bypass the 2-second minimum read interval.

proc read*(d: var DHT, force: bool = false): bool {.importcpp.}
  ## Perform a low-level sensor read. Returns true on success.
  ## Typically called internally by readTemperature/readHumidity.

proc convertCtoF*(d: var DHT, celsius: cfloat): cfloat {.importcpp.}
  ## Convert a Celsius value to Fahrenheit.

proc convertFtoC*(d: var DHT, fahrenheit: cfloat): cfloat {.importcpp.}
  ## Convert a Fahrenheit value to Celsius.

proc computeHeatIndex*(d: var DHT, isFahrenheit: bool = true): cfloat
  {.importcpp.}
  ## Compute the heat index using the last read temperature and humidity.
  ## Result is in Fahrenheit by default; set `isFahrenheit` to false for
  ## Celsius.

proc computeHeatIndex*(d: var DHT, temperature: cfloat,
                       percentHumidity: cfloat,
                       isFahrenheit: bool = true): cfloat {.importcpp.}
  ## Compute the heat index from explicit temperature and humidity values.
  ## Temperature units must match the `isFahrenheit` flag.

{.pop.}

# ==========================================================================
# DHT_Unified (Adafruit Unified Sensor interface — DHT_U.h)
#
# Requires the Adafruit Unified Sensor Driver library.
# NOTE: This library is installed automatically when installing DHT sensor library.
# ==========================================================================

import adafruit_sensor
export adafruit_sensor

{.push header: "DHT_U.h".}

type
  DHTUnifiedTemperature* {.importcpp: "DHT_Unified::Temperature".} = object
    ## Nested class providing Unified Sensor access to temperature data.

  DHTUnifiedHumidity* {.importcpp: "DHT_Unified::Humidity".} = object
    ## Nested class providing Unified Sensor access to humidity data.

  DHTUnified* {.importcpp: "DHT_Unified".} = object
    ## Unified sensor wrapper around the DHT class. Exposes temperature
    ## and humidity as separate Adafruit_Sensor-compatible objects.

proc initDHTUnified*(pin: uint8, sensorType: uint8, count: uint8 = 6,
                     tempSensorId: int32 = -1,
                     humiditySensorId: int32 = -1): DHTUnified
  {.importcpp: "DHT_Unified(@)", constructor.}
  ## Create a DHT_Unified instance. `pin` and `sensorType` match the
  ## basic DHT constructor. Optional sensor IDs are used for the
  ## unified sensor metadata.

proc begin*(d: var DHTUnified) {.importcpp.}
  ## Initialize the unified sensor.

proc temperature*(d: var DHTUnified): DHTUnifiedTemperature {.importcpp.}
  ## Get the temperature sensor object.

proc humidity*(d: var DHTUnified): DHTUnifiedHumidity {.importcpp.}
  ## Get the humidity sensor object.

proc getEvent*(t: var DHTUnifiedTemperature, event: var SensorsEventT): bool
  {.importcpp: "#.getEvent(&(#))".}
  ## Read the latest temperature event. Returns true on success.
  ## Access the value via event.temperature().

proc getSensor*(t: var DHTUnifiedTemperature, sensor: var SensorT)
  {.importcpp: "#.getSensor(&(#))".}
  ## Populate sensor metadata (name, range, resolution, etc.).

proc getEvent*(h: var DHTUnifiedHumidity, event: var SensorsEventT): bool
  {.importcpp: "#.getEvent(&(#))".}
  ## Read the latest humidity event. Returns true on success.
  ## Access the value via event.relative_humidity().

proc getSensor*(h: var DHTUnifiedHumidity, sensor: var SensorT)
  {.importcpp: "#.getSensor(&(#))".}
  ## Populate sensor metadata (name, range, resolution, etc.).

{.pop.}
