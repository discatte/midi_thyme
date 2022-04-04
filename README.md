# midi thyme
calculate absolute seconds for midi notes using midilib in ruby

## output

```
--------------------
SEQ PPQN:192 TRACKS:2
TRACK[00] EVENTS:5
\TEMPO tempo 500000 msecs per qnote (120.0 bpm)
\TEMPO tempo 1000000 msecs per qnote (60.0 bpm)
\TEMPO tempo 2000000 msecs per qnote (30.0 bpm)
TRACK[01] EVENTS:13
\CHAN[00] NOTES:6
--------------------
LAST EVENT:2302
TEMPO BPM:120  START:    0/ 0.0000  END:  764/ 1.9896  DURATION: 1.9896
TEMPO BPM: 60  START:  764/ 1.9896  END: 1535/ 6.0052  DURATION: 4.0156
TEMPO BPM: 30  START: 1535/ 6.0052  END: 2302/13.9948  DURATION: 7.9896
NOTE  C5 ( 72) CH:00 TIME:     0/ 0.0000
NOTE A#4 ( 70) CH:00 TIME:   384/ 1.0000
NOTE  C5 ( 72) CH:00 TIME:   768/ 2.0104
NOTE A#4 ( 70) CH:00 TIME:  1152/ 4.0104
NOTE  C5 ( 72) CH:00 TIME:  1536/ 6.0156
NOTE A#4 ( 70) CH:00 TIME:  1920/10.0156
```
