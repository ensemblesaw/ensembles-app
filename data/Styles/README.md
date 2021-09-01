## Ensembles Styles Specification

### Layout
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

All Styles are required to have resolution (ticks per quarter note) in the *MThd* header and time signature embeded in the file.

### Markers
With the exception of the configuration marker, all markers use the same syntax as below:

```<Marker Name>:<Measure Number>```

The Configuration marker is as follows:

```Config:<Measure Number (usually 1)>;<Tempo>;<Chord Type>```

* Measure number is number of measures upto the occurance of that marker. So _Config_ has measure 1, _Intro A_ has 2 and so on.
* Tempo is in BPM (Beats per Minute)
* Chord Type is 0 is original scale of style is in major and 1 if it's minor

### Modulators
- 7  - Volume [0, 127]
- 10 - Pan [-100, 100]
- 64 - Sustain [0, 127]
- 71 - Resonance [0, 127]
- 74 - Cut-Off Filter [0, 127]
- 85 - Explicit Bank Select (in case standard bank select doesn't work, required for accessing XG sounds)
- 91 - Reverb [0, 127] (Safe range is 0 to 8)
- 93 - Chorus [0, 127] (Safe range is 0 to 8)


### Some Workarounds for missing voices
- Always keep a bit of gap from the start of the Marker or part
- If there is cymbal or other instrument right after Fill-in or Intro, put it just a before the beginning of the next marker.
- Reduce the number of instruments playing at a point.
- Look for redundant tones

### Rosegarden
All the styles made by me were made in Rosegarden Midi Editor.
In the `data/RoseGardenDevices` folder you will find the Ensembles device definition. In the `Styles` folder you will find a template style to get started, though you may need to place the markers manually. You can download *EnsemblesGM.sf2* soundfont archive from https://gitlab.com/SubhadeepJasu/ensemblesgmsoundfont, if you want to use any other midi editor or DAW.

### Conclusion

Don't forget to save the exported file with *.enstl* extension. You can put the file in `Ensembles/Styles` directory in your documents folder and share them around. You can also contribute styles to the repo.
