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
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-4-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

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
[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.subhadeepjasu.ensembles/)

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
The software does require quite a lot of CPU power. If you notice bad delay or stuttering audio, launch the app from terminal; check to see if there is any error messages stating that fluidsynth was unable to set realtime priority. In that case, edit the file- `/etc/security/limits.conf` and add the following lines:
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

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="http://subhadeepjasu.github.io"><img src="https://avatars.githubusercontent.com/u/20795161?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Subhadeep Jasu</b></sub></a><br /><a href="#design-SubhadeepJasu" title="Design">🎨</a> <a href="https://github.com/SubhadeepJasu/Ensembles/commits?author=SubhadeepJasu" title="Code">💻</a> <a href="https://github.com/SubhadeepJasu/Ensembles/commits?author=SubhadeepJasu" title="Documentation">📖</a></td>
    <td align="center"><a href="https://ryonakano.github.io"><img src="https://avatars.githubusercontent.com/u/26003928?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Ryo Nakano</b></sub></a><br /><a href="https://github.com/SubhadeepJasu/Ensembles/commits?author=ryonakano" title="Code">💻</a></td>
    <td align="center"><a href="https://proseandconst.xyz/"><img src="https://avatars.githubusercontent.com/u/8205055?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Darshak Parikh</b></sub></a><br /><a href="https://github.com/SubhadeepJasu/Ensembles/commits?author=dar5hak" title="Code">💻</a> <a href="https://github.com/SubhadeepJasu/Ensembles/commits?author=dar5hak" title="Documentation">📖</a></td>
    <td align="center"><a href="https://micahilbery.com/"><img src="https://avatars.githubusercontent.com/u/10608836?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Micah Ilbery</b></sub></a><br /><a href="#design-micahilbery" title="Design">🎨</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
