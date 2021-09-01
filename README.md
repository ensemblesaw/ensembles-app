<div align="center">
  <div align="center">
    <img src="data/Images/Logo.svg" height="128">
  </div>
  <hr>
  <div align="center">
    <b>Musical Performance Arranger Workstation</b>
    <br>
    <img src="screenshots/Screenshot.png" width="500">
  </div>
  <br>
</div>
Ensembles is a realtime musical performance arranger app. Its built using Vala and Gtk, powered by Fluidsynth. Ensembles is different from other DAW (Digital Audio Workstations) in the fact that the focus here is on live performance.

![elementary flatpak build status](https://github.com/SubhadeepJasu/Ensembles/actions/workflows/ci.yml/badge.svg)

<br>

## The main features:

* Play any instrument from a selection of more than 200 in-built voices
* 60-Key on-screen keyboard with mouse and touch support
* Split Keyboard or Layer two voices for multiple voice playback
* DSP (Digital Signal Processing) effects like filters, reverb and chorus
* Assign knobs and sliders to multiple DSP effects along with a Master Knob which can be used to control multiple knobs and sliders
* Touch based on-screen assignable joystick
* Play a one-person band along with a Auto Accompaniment Style from over 100 [WIP] built-in styles based on various genres of music
* Automate your band with Registration Memory
* Record and play audio files using 12 assignable Sampling Pads
* Play MIDI files using the inbuilt synthesizer
* Connect to external MIDI keyboard/controller with General MIDI Standard compatibility

⚠️ **Ensembles is in early development and not ready for production just yet** ⚠️

However, feel free to test it early
## Get it on elementary OS Appcenter
TBD
<!-- [![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/) -->

## Install from source
You can install Ensembles by compiling it from source, here's a list of required dependencies:
 - `io.elementary.Platform>=6` (flatpak)
 - `io.elementary.Sdk>=6` (flatpak)
 - `elementary-sdk`
 - `gtk+-3.0>=3.18`
 - `granite>=5.3.0`
 - `glib-2.0`
 - `gobject-2.0`
 - `meson`
 - `libhandy-1`
 - `fluidsynth>=2.2.1`
 - `portmidi`

Clone repository and change directory
```
git clone https://github.com/SubhadeepJasu/ensembles.git
cd ensembles
```
Compile, install using flatpak and start Ensembles on your system *(Recommended)*
```
flatpak-builder build  com.github.subhadeepjasu.ensembles.yml --user --install --force-clean
flatpak run com.github.subhadeepjasu.ensembles

```
_OR_ using meson *(Requires GIT-LFS)*
```
meson _build --prefix=/usr
cd _build
sudo ninja install
com.github.subhadeepjasu.ensembles
```

## Realtime Audio Performance
The software does require quiet a lot of CPU power. If you notice bad delay or stuttering audio, launch the app from terminal; check to see if there is any error messages stating that fluidsynth was unable to set realtime priority. In that case, edit the file- `/etc/security/limits.conf` and add the following lines:
```
@audio   -  rtprio      90
@audio   -  memlock     unlimited
```

The problem currently usually happens with the flatpak version.

## Discussions
If you want to ask any questions or provide feedback, you can make issues in this repository or use the discussions section of this repository.

## Contributing
Feel free to send pull requests to this repository with your code, or other types of assets like soundfont voices, style files, etc. Soundfont in this repo is no longer updated and its available in a different repository https://gitlab.com/SubhadeepJasu/ensemblesgmsoundfont due to LFS concerns.

## Plug-In Development
Ensembles will have support for sampled voice, voice synthesis and DSP plug-ins. Plug-ins may support their own UI which can be accessed from within Ensembles. You can create plug-ins and distribute them over Flathub or elementary OS AppCenter.

## External Files
Ensembles supports creation and distribution of external soundfonts (SF2), style files and MIDI recordings. External content can be placed in special folders in user's document folder. Style files from other formats like *STY*,  *AC7*, etc. are not compatible with Ensembles. Ensembles has its own style format *ENSTL*, check out styles Readme file in your documents folder for style specifications (Check: https://github.com/SubhadeepJasu/Ensembles/blob/master/data/Styles/README.md). External MIDI recordings may have reserved copyrights.

<br>
<sup><b>License</b>: GNU GPLv3</sup>
<br>
<sup>Certain components like soundfonts and styles have their own Licensing</sup>
<br>
<sup>SoundFont(R) is a registered trademark of E-mu Systems, Inc.</sup>
<br>
<sup>Ensembles © Copyright 2021-2022 Subhadeep Jasu</sup>
