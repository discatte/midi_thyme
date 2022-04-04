# 🎼🌿 midi thyme
calculate absolute seconds for midi notes using midilib in ruby

## output

```
--------------------
File Summary
SEQ PPQN:192 TRACKS:2
TRACK [00] EVENTS:5
 \TEMPO   500000 BPM: 120
 \TEMPO  1000000 BPM:  60
 \TEMPO  2000000 BPM:  30
TRACK [01] EVENTS:13
 \CHAN[00] NOTES:     6 ( 70- 72) [  2]
--------------------
Tempo to seconds map
TEMPO BPM:120  START:    0/ 0.0000  END:  764/ 1.9896  DURATION:  1.9896
TEMPO BPM: 60  START:  764/ 1.9896  END: 1535/ 6.0052  DURATION:  4.0156
TEMPO BPM: 30  START: 1535/ 6.0052  END: 2302/13.9948  DURATION:  7.9896
NOTE  C5 ( 72) CH:00 TIME:     0/ 0.0000
NOTE A#4 ( 70) CH:00 TIME:   384/ 1.0000
NOTE  C5 ( 72) CH:00 TIME:   768/ 2.0104
NOTE A#4 ( 70) CH:00 TIME:  1152/ 4.0104
NOTE  C5 ( 72) CH:00 TIME:  1536/ 6.0156
NOTE A#4 ( 70) CH:00 TIME:  1920/10.0156
```
