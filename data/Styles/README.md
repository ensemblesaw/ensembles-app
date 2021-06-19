**Ensembles Styles Specification**


_Layout_:          
_______________
- Configuration
- Intro 1
- Intro 2
- Variation A
- Fill-In A
- Variation B
- Fill-In B
- Variation C
- Fill-In C
- Variation D
- Fill-In D
- Ending 1
- End of Style 1 (EOS1)
- Ending 2
- End of Style 2 (EOS2)



_Markers_:
_______________
With the exception of the configuration marker, all markers use the same syntax as below:

```MarkerName:TimeStamp```

The Configuration marker is as follows:

```Config:TimeStamp(usually 0);Tempo```


_Modulators_:
_____________
- 7  - Volume [0, 127]
- 10 - Pan [-100, 100]
- 64 - Sustain [0, 127]
- 71 - Resonance [0, 127]
- 74 - Cut-Off Filter [0, 127]
- 91 - Reverb [0, 127] (Safe range is 0 to 8)
- 93 - Chorus [0, 127] (Safe range is 0 to 8)


_Some Workarounds for missing voices_
___________________________________
- Always keep a bit of gap from the start of the Marker or part
- If there is cymbal or other instrument right after Fill-in or Intro, put it just a before the beginning of the next marker.
- Reduce the number of instruments playing at a point.
- Look for redundant tones

_Rosegarden_
_____________
All the styles made by me were done in Rosegarden Midi Editor.
In the `data/RoseGardenDevices` folder you will find the Ensembles device definition. In the `Styles` folder you will find a template style to get started, though you may need to place the markers manually. In the `data/Soundfonts` folder you can find the *EnsemblesGM.sf2* soundfont archive, if you want to use any other midi editor or DAW.
