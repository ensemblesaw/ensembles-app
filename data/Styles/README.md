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

```Config:<Measure Number (usually 1)>;<Tempo>,<Chord Type>```

* Measure number is number of measures upto the occurance of that marker. So _Config_ has measure 1, _Intro A_ has 2 and so on.
* Tempo is in BPM (Beats per Minute) [Note: Don't use fractional tempo. It needs to be whole number!]
* Chord Type is 0 is original scale of style is in major and 1 if it's minor

### Modulators
- 7&nbsp; - Volume [0, 127]
- 10 - Pan [-100, 100]
- 64 - Sustain [0, 127]
- 71 - Resonance [0, 127]
- 74 - Cut-Off Filter [0, 127]
- 82 - Play Alt Channels [0 - 64] (Check Note)
- 85 - Explicit Bank Select (in case standard bank select doesn't work, required for accessing XG sounds)
- 91 - Reverb [0, 127]
- 93 - Chorus [0, 127]

[Note: If value of CC 82 is equal to 64 then it will play channels marked below as 'alt', and mute the corresponding upper channels, based on the original scale/chord of the song set in the config. If it's off, then all channels are played. The value is only read from channel 12]

### Channels
- 1&nbsp; - Lead
- 2&nbsp; - Lead
- 3&nbsp; - Bass
- 4&nbsp; - Piano/EP Fill
- 5&nbsp; - Guitar Fill
- 6&nbsp; - Electric Guitar
- 7&nbsp; - Strings/Organ Fill
- 8&nbsp; - Strings/Synth Ambience
- 9&nbsp; - Miscellaneous
- 10 - Drums/Percussions
- 11 - SFX
- 12 - Lead (alt for 1)
- 13 - Bass (alt for 3)
- 14 - Piano/EP Fill (alt for 4)
- 15 - Electric Guitar/Guitar Fill (alt for 5)
- 16 - Strings/Pad/Organ (alt for 7 and 8)


### Some Workarounds for missing voices
- Always keep a bit of gap from the start of the Marker or part
- If there is cymbal or other instrument right after Fill-in or Intro, put it just a before the beginning of the next marker.
- Reduce the number of instruments playing at a point.
- Avoid placing notes at the beginning of the Fill-in sections.
- Look for redundant tones

### Rosegarden
All the styles made by me were made in Rosegarden Midi Editor.
In the `data/RoseGardenDevices` folder you will find the Ensembles device definition. In the `Styles` folder you will find a template style to get started, though you may need to place the markers manually. Start Ensembles with a `--raw` option to enable Ensembles to process raw MIDI signals. Enable MIDI Input in Ensembles, notice the list of MIDI devices don't appear, which means it will process raw input from any source what so ever. You can then select Ensembles as the MIDI output devie in Rosegarden. You can download *EnsemblesGM.sf2* soundfont archive from https://gitlab.com/SubhadeepJasu/ensemblesgmsoundfont. You can also use any other midi editor or DAW of your preference.

### Conclusion

Don't forget to save the exported file with *.enstl* extension. You can put the file in `Ensembles/Styles` directory in your documents folder and share them around. You can also contribute styles to the repo.
