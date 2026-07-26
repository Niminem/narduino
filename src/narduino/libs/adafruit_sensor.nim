## Bindings for the Adafruit Unified Sensor Driver (Adafruit_Sensor.h).
##
## Provides a common interface and shared types for all Adafruit sensor
## libraries (DHT, BMP280, LSM303, BME680, etc.).
## Reference: https://github.com/adafruit/Adafruit_Sensor
## Install via `narduino libinstall --lib:"Adafruit Unified Sensor"`

const header = "Adafruit_Sensor.h"

# ==========================================================================
# Physical constants
# ==========================================================================

const
  SENSORS_GRAVITY_EARTH*: cfloat = 9.80665
  SENSORS_GRAVITY_MOON*: cfloat = 1.6
  SENSORS_GRAVITY_SUN*: cfloat = 275.0
  SENSORS_GRAVITY_STANDARD*: cfloat = SENSORS_GRAVITY_EARTH
  SENSORS_MAGFIELD_EARTH_MAX*: cfloat = 60.0
  SENSORS_MAGFIELD_EARTH_MIN*: cfloat = 30.0
  SENSORS_PRESSURE_SEALEVELHPA*: cfloat = 1013.25
  SENSORS_DPS_TO_RADS*: cfloat = 0.017453293
  SENSORS_RADS_TO_DPS*: cfloat = 57.29577793
  SENSORS_GAUSS_TO_MICROTESLA*: cint = 100

# ==========================================================================
# Sensor type enum
# ==========================================================================

type
  SensorsTypeT* {.importcpp: "sensors_type_t", header: header, size: sizeof(cint).} = enum
    SENSOR_TYPE_ACCELEROMETER = 1
    SENSOR_TYPE_MAGNETIC_FIELD = 2
    SENSOR_TYPE_ORIENTATION = 3
    SENSOR_TYPE_GYROSCOPE = 4
    SENSOR_TYPE_LIGHT = 5
    SENSOR_TYPE_PRESSURE = 6
    SENSOR_TYPE_PROXIMITY = 8
    SENSOR_TYPE_GRAVITY = 9
    SENSOR_TYPE_LINEAR_ACCELERATION = 10
    SENSOR_TYPE_ROTATION_VECTOR = 11
    SENSOR_TYPE_RELATIVE_HUMIDITY = 12
    SENSOR_TYPE_AMBIENT_TEMPERATURE = 13
    SENSOR_TYPE_OBJECT_TEMPERATURE = 14
    SENSOR_TYPE_VOLTAGE = 15
    SENSOR_TYPE_CURRENT = 16
    SENSOR_TYPE_COLOR = 17
    SENSOR_TYPE_TVOC = 18
    SENSOR_TYPE_VOC_INDEX = 19
    SENSOR_TYPE_NOX_INDEX = 20
    SENSOR_TYPE_CO2 = 21
    SENSOR_TYPE_ECO2 = 22
    SENSOR_TYPE_PM10_STD = 23
    SENSOR_TYPE_PM25_STD = 24
    SENSOR_TYPE_PM100_STD = 25
    SENSOR_TYPE_PM10_ENV = 26
    SENSOR_TYPE_PM25_ENV = 27
    SENSOR_TYPE_PM100_ENV = 28
    SENSOR_TYPE_GAS_RESISTANCE = 29
    SENSOR_TYPE_UNITLESS_PERCENT = 30
    SENSOR_TYPE_ALTITUDE = 31

# ==========================================================================
# Helper structs
# ==========================================================================

{.push header: header.}

type
  SensorsVecT* {.importcpp: "sensors_vec_t".} = object
    ## 3D vector used for acceleration, magnetic, orientation, and gyro data.
    x*: cfloat
    y*: cfloat
    z*: cfloat
    status*: int8
    reserved*: array[3, uint8]

template roll*(v: SensorsVecT): cfloat = v.x
  ## Rotation around the longitudinal axis (alias for x).
template pitch*(v: SensorsVecT): cfloat = v.y
  ## Rotation around the lateral axis (alias for y).
template heading*(v: SensorsVecT): cfloat = v.z
  ## Angle between longitudinal axis and magnetic north (alias for z).

type
  SensorsColorT* {.importcpp: "sensors_color_t".} = object
    ## Color data in RGB floating-point plus a packed 32-bit RGBA value.
    r*: cfloat
    g*: cfloat
    b*: cfloat
    rgba*: uint32

# ==========================================================================
# sensors_event_t
# ==========================================================================

type
  SensorsEventT* {.importcpp: "sensors_event_t".} = object
    ## Unified sensor event (36 bytes). Contains a union of all possible
    ## sensor data types. Access the appropriate field for your sensor type.
    version*: int32
    sensor_id*: int32
    `type`*: int32
    reserved0*: int32
    timestamp*: int32

# Field accessors — the C struct uses a union so we access via importcpp
# to read the correct union member without replicating the full union in Nim.

proc acceleration*(e: SensorsEventT): SensorsVecT
  {.importcpp: "#.acceleration".}
  ## Acceleration in m/s^2.

proc magnetic*(e: SensorsEventT): SensorsVecT
  {.importcpp: "#.magnetic".}
  ## Magnetic vector in micro-Tesla (uT).

proc orientation*(e: SensorsEventT): SensorsVecT
  {.importcpp: "#.orientation".}
  ## Orientation in degrees.

proc gyro*(e: SensorsEventT): SensorsVecT
  {.importcpp: "#.gyro".}
  ## Gyroscope in rad/s.

proc temperature*(e: SensorsEventT): cfloat
  {.importcpp: "#.temperature".}
  ## Temperature in degrees Celsius.

proc distance*(e: SensorsEventT): cfloat
  {.importcpp: "#.distance".}
  ## Distance in centimeters.

proc light*(e: SensorsEventT): cfloat
  {.importcpp: "#.light".}
  ## Light in SI lux units.

proc pressure*(e: SensorsEventT): cfloat
  {.importcpp: "#.pressure".}
  ## Pressure in hectopascal (hPa).

proc relative_humidity*(e: SensorsEventT): cfloat
  {.importcpp: "#.relative_humidity".}
  ## Relative humidity in percent.

proc current*(e: SensorsEventT): cfloat
  {.importcpp: "#.current".}
  ## Current in milliamps (mA).

proc voltage*(e: SensorsEventT): cfloat
  {.importcpp: "#.voltage".}
  ## Voltage in volts (V).

proc tvoc*(e: SensorsEventT): cfloat
  {.importcpp: "#.tvoc".}
  ## Total Volatile Organic Compounds in ppb.

proc voc_index*(e: SensorsEventT): cfloat
  {.importcpp: "#.voc_index".}
  ## VOC index (100 = normal, unitless).

proc nox_index*(e: SensorsEventT): cfloat
  {.importcpp: "#.nox_index".}
  ## NOx index (1 = normal, unitless).

proc CO2*(e: SensorsEventT): cfloat
  {.importcpp: "#.CO2".}
  ## Measured CO2 in ppm.

proc eCO2*(e: SensorsEventT): cfloat
  {.importcpp: "#.eCO2".}
  ## Estimated CO2 in ppm.

proc pm10_std*(e: SensorsEventT): cfloat
  {.importcpp: "#.pm10_std".}
  ## Standard Particulate Matter <=1.0 in ppm.

proc pm25_std*(e: SensorsEventT): cfloat
  {.importcpp: "#.pm25_std".}
  ## Standard Particulate Matter <=2.5 in ppm.

proc pm100_std*(e: SensorsEventT): cfloat
  {.importcpp: "#.pm100_std".}
  ## Standard Particulate Matter <=10.0 in ppm.

proc pm10_env*(e: SensorsEventT): cfloat
  {.importcpp: "#.pm10_env".}
  ## Environmental Particulate Matter <=1.0 in ppm.

proc pm25_env*(e: SensorsEventT): cfloat
  {.importcpp: "#.pm25_env".}
  ## Environmental Particulate Matter <=2.5 in ppm.

proc pm100_env*(e: SensorsEventT): cfloat
  {.importcpp: "#.pm100_env".}
  ## Environmental Particulate Matter <=10.0 in ppm.

proc gas_resistance*(e: SensorsEventT): cfloat
  {.importcpp: "#.gas_resistance".}
  ## Proportional to VOC particles in air (Ohms).

proc unitless_percent*(e: SensorsEventT): cfloat
  {.importcpp: "#.unitless_percent".}
  ## Percentage, unitless (%).

proc color*(e: SensorsEventT): SensorsColorT
  {.importcpp: "#.color".}
  ## Color in RGB component values.

proc altitude*(e: SensorsEventT): cfloat
  {.importcpp: "#.altitude".}
  ## Altitude in meters.

proc data*(e: SensorsEventT): ptr cfloat
  {.importcpp: "(float*)(#.data)".}
  ## Raw data array (4 floats).

# ==========================================================================
# sensor_t
# ==========================================================================

type
  SensorT* {.importcpp: "sensor_t".} = object
    ## Sensor descriptor with metadata about a specific sensor.
    name*: array[12, char]
    version*: int32
    sensor_id*: int32
    `type`*: int32
    max_value*: cfloat   ## Maximum value in SI units
    min_value*: cfloat   ## Minimum value in SI units
    resolution*: cfloat  ## Smallest difference between two reported values
    min_delay*: int32    ## Minimum delay between events in microseconds

# ==========================================================================
# Adafruit_Sensor base class
# ==========================================================================

type
  AdafruitSensor* {.importcpp: "Adafruit_Sensor", inheritable, byref.} = object
    ## Abstract base class for all Adafruit unified sensors.
    ## Subclasses must implement getEvent() and getSensor().

proc getEvent*(s: var AdafruitSensor, event: var SensorsEventT): bool
  {.importcpp: "#.getEvent(&(#))".}
  ## Get the latest sensor event. Returns true on success.

proc getSensor*(s: var AdafruitSensor, sensor: var SensorT)
  {.importcpp: "#.getSensor(&(#))".}
  ## Populate the sensor descriptor with metadata.

proc enableAutoRange*(s: var AdafruitSensor, enabled: bool)
  {.importcpp.}
  ## Enable/disable automatic range adjustment (if supported).

proc printSensorDetails*(s: var AdafruitSensor)
  {.importcpp.}
  ## Print sensor details to Serial.

{.pop.}
