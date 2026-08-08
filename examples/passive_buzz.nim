## Passive Buzzer
## Uses a npn transistor from Arduino kit to drive a passive buzzer
## I make it a little more complex by playing an instrumental that
## I really like. https://www.youtube.com/watch?v=VuMRTxwEpLM
## NOTE: Part of this was assisted by AI. I didn't understand
## some of the notes and how to do things like slides, hammer-ons, etc.

# import std/[]
import ../narduino/src/narduino

const
    Note_B0: cuint = 31
    Note_C1: cuint =   33
    Note_CS1: cuint = 35
    Note_D1: cuint =   37
    Note_DS1: cuint =  39
    Note_E1: cuint =   41
    Note_F1: cuint =   44
    Note_FS1: cuint =  46
    Note_G1: cuint =   49
    Note_GS1: cuint =  52
    Note_A1: cuint =   55
    Note_AS1: cuint =  58
    Note_B1: cuint =   62
    Note_C2: cuint =   65
    Note_CS2: cuint =  69
    Note_D2: cuint =   73
    Note_DS2: cuint =  78
    Note_E2: cuint =   82
    Note_F2: cuint =   87
    Note_FS2: cuint =  93
    Note_G2: cuint =   98
    Note_GS2: cuint =  104
    Note_A2: cuint =   110
    Note_AS2: cuint =  117
    Note_B2: cuint =   123
    Note_C3: cuint =   131
    Note_CS3: cuint =  139
    Note_D3: cuint =   147
    Note_DS3: cuint =  156
    Note_E3: cuint =   165
    Note_F3: cuint =   175
    Note_FS3: cuint =  185
    Note_G3: cuint =   196
    Note_GS3: cuint =  208
    Note_A3: cuint =   220
    Note_AS3: cuint =  233
    Note_B3: cuint =   247
    Note_C4: cuint =   262
    Note_CS4: cuint =  277
    Note_D4: cuint =   294
    Note_DS4: cuint =  311
    Note_E4: cuint =   330
    Note_F4: cuint =   349
    Note_FS4: cuint =  370
    Note_G4: cuint =   392
    Note_GS4: cuint =  415
    Note_A4: cuint =   440
    Note_AS4: cuint =  466
    Note_B4: cuint =   494
    Note_C5: cuint =   523
    Note_CS5: cuint =  554
    Note_D5: cuint =   587
    Note_DS5: cuint =  622
    Note_E5: cuint =   659
    Note_F5: cuint =   698
    Note_FS5: cuint =  740
    Note_G5: cuint =   784
    Note_GS5: cuint =  831
    Note_A5: cuint =   880
    Note_AS5: cuint =  932
    Note_B5: cuint =   988
    Note_C6: cuint =   1047
    Note_CS6: cuint =  1109
    Note_D6: cuint =   1175
    Note_DS6: cuint =  1245
    Note_E6: cuint =   1319
    Note_F6: cuint =   1397
    Note_FS6: cuint =  1480
    Note_G6: cuint =   1568
    Note_GS6: cuint =  1661
    Note_A6: cuint =   1760
    Note_AS6: cuint =  1865
    Note_B6: cuint =   1976
    Note_C7: cuint =   2093
    Note_CS7: cuint =  2217
    Note_D7: cuint =   2349
    Note_DS7: cuint =  2489
    Note_E7: cuint =   2637
    Note_F7: cuint =   2794
    Note_FS7: cuint =  2960
    Note_G7: cuint =   3136
    Note_GS7: cuint =  3322
    Note_A7: cuint =   3520
    Note_AS7: cuint =  3729
    Note_B7: cuint =   3951
    Note_C8: cuint =   4186
    Note_CS8: cuint =  4435
    Note_D8: cuint =   4699
    Note_DS8: cuint =  4978

const
    pin = 8.uint8
    # dials
    nd: culong = 280#200
    sd: culong = 180#150#130
    gp: culong = 50#20
    sgp: culong = 5
    rd: culong = 200
    slDur: culong = 250#150
    slSteps = 7#6#15
    mtDur: culong = 60

proc playNote(freq: cuint, dur: culong = nd) =
    tone(pin, freq, dur)
    delay(dur + gp)

proc legato(freq: cuint, dur: culong = sd) =
    tone(pin, freq, dur)
    delay(dur + sgp)

proc slide(fromF, toF: cuint, dur: culong = slDur) =
    tone(pin, fromF, 40)
    delay(45)
    playNote(toF, dur)

proc rest(dur: culong = rd) =
    noTone(pin)
    delay(dur)

proc mute() =
    noTone(pin)
    delay(mtDur)

# B string: fret 5=E4, 7=F#4, 10=A4, 12=B4, 14=C#5
# G string: fret 4=B3, 7=D4, 11=F#4, 13=G#4
# D string: fret 12=D4 | A string: fret 14=B3

proc intro() =
    playNote(Note_B4)
    playNote(Note_B4)
    rest()
    playNote(Note_B4)
    playNote(Note_A4)
    rest()
    playNote(Note_B4)
    playNote(Note_FS4)
    rest()
    playNote(Note_FS4)

proc mainRiffL1() =
    playNote(Note_B4)                   # 12
    playNote(Note_A4)                   # 10
    slide(Note_A4, Note_B4)             # 10/12
    legato(Note_FS4)                    # ^7
    playNote(Note_FS4)                  # 7
    slide(Note_FS4, Note_A4)            # 7/10
    legato(Note_FS4)                    # 10^7
    slide(Note_FS4, Note_A4)            # /10
    playNote(Note_E4)                   # 5

proc mainRiffL2() =
    playNote(Note_B3)                   # G4
    playNote(Note_D4)                   # G7
    playNote(Note_E4)                   # B5
    playNote(Note_FS4)                  # B7
    legato(Note_A4)                     # ^10
    legato(Note_FS4)                    # ^7
    legato(Note_A4)                     # ^10
    slide(Note_A4, Note_CS5)            # 10/14
    legato(Note_B4)                     # 14^12
    playNote(Note_B4)                   # 12

proc mainRiff() =
    mainRiffL1()
    mainRiffL2()

proc firstChangeL1() =
    playNote(Note_B4)                   # 12
    playNote(Note_A4)                   # 10
    slide(Note_A4, Note_B4)             # 10/12
    legato(Note_FS4)                    # ^7
    playNote(Note_FS4)                  # 7
    slide(Note_FS4, Note_B4)            # 7/12
    playNote(Note_B4)                   # 12
    mute()                              # XXXX
    playNote(Note_B4)                   # 12
    playNote(Note_B4)                   # 12

proc firstChange() =
    firstChangeL1()
    mainRiffL2()

proc playSong() =
    intro()
    delay(100)
    mainRiff()
    delay(200)
    firstChange()

setup:
    pinMode(pin, OUTPUT)
    Serial.begin(9600)
    delay(1000)

loop:
    playSong()
    delay(5000)
