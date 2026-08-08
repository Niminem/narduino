## Arduino UNO R4 WiFi internal LED matrix demo.
## NOTE: this project requires the ArduinoGraphics library to be installed
## `narduino libinstall --lib:ArduinoGraphics`

import ../narduino/src/narduino
import ../narduino/src/narduino/libs/arduino_led_matrix

var matrix = initArduinoLEDMatrix()
var frame: array[8, array[12, uint8]]

setup:
    Serial.begin(9600)
    matrix.begin()

loop:
    for i in 0 .. frame.high:
        for j in 0 .. frame[0].high:
            frame[i][j] = 1
    matrix.renderBitmap(frame) # here we just render our frame to the matrix manually
    delay(200)

    # here we use some built-in text drawing functions
    matrix.beginDraw()
    matrix.clear()
    matrix.textScrollSpeed(100)
    matrix.textFont(Font_5x7) # standard font (fits within the internal 8x12 matrix)
    matrix.beginText(0, 1, 255, 0, 0) # x = 0, y = 1 (red)
    matrix.println("I LOVE GABRIELLE")
    matrix.endText(SCROLL_LEFT)
    matrix.endDraw()