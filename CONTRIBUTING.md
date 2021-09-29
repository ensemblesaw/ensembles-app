# Ensembles Contributing Guide

Thank you for investing your time in contributing to Ensembles :tada:

<br>
Ensembles is Free and Opensource software and we welcome contributions and assistance. You can contribute in many ways, you can submit bug reports, feature requests or write code which goes into Ensembles. You can also contribute sounds for the default soundfont* or expand the roster of built-in Styles**. You can also propose changes to this document.
<br>
<br>

All members of our community are expected to follow our [Code of Conduct](.github/CODE_OF_CONDUCT.md) to keep the community approchable and respectable.

In this guide you will get an overview of the contribution workflow from opening an issue, creating a PR, reviewing, and merging the PR.

## Table of contents

* [New contributor guide](#new-contributor-guide)
* [Getting started](#getting-started)
* [Reporting bugs and issues](#reporting-bugs-and-issues)
* [Feature requests](#feature-requests)
* [Pull requests](#pull-requests)
* [Review process](#review-process)

## New contributor guide

See the [README](README.md) to get an overview of the project. Here are some helpful resources to get you comfortable with open source contribution:

- [Finding ways to contribute to open source on GitHub](https://docs.github.com/en/get-started/exploring-projects-on-github/finding-ways-to-contribute-to-open-source-on-github)
- [Set up Git](https://docs.github.com/en/get-started/quickstart/set-up-git)
- [GitHub flow](https://docs.github.com/en/get-started/quickstart/github-flow)
- [Collaborating with pull requests](https://www.firsttimersonly.com/)

Unsure where to begin contributing to Ensembles? You can start by looking through the `help-wanted` or `good first issue` issues:
 * [Help wanted issues](https://github.com/SubhadeepJasu/ensembles/issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22) - issues which are marked for some help.

 * [Good first issues](https://github.com/SubhadeepJasu/ensembles/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22) -issues which are marked as suitable for first time contributors.

 * [Hacktoberfest issues](https://github.com/SubhadeepJasu/ensembles/issues?q=is%3Aissue+is%3Aopen+label%3A%22hacktoberfest%22) - issues which are marked as participation entry points for [Hacktoberfest](https://hacktoberfest.digitalocean.com)

At this point, you're ready to make your changes! Feel free to ask for help; everyone is a beginner at first :D

> If a maintainer asks you to "rebase" your PR, they're saying that a lot of code has changed, and that you need to update your branch so it's easier to merge. There is usually an easy way to rebase from within the pull request page directly.



## Getting started

* Ensembles is written in [Vala](https://wiki.gnome.org/Projects/Vala) and C languages

* To start learning how to program in Vala, check out the [official tutorial](https://wiki.gnome.org/Projects/Vala/Tutorial)

* To start learning how to program in C, check out the [C programming tutorial](www.cprogramming.com)

* If you want to contribute in the musical content in Ensembles, you are free to use any software or DAW (so long as it fits their terms of use).
    1. The SoundFont is made using samples derived from sounds in the public domain or other soundfonts that are also in public domain. You can use [Polyphone](https://www.polyphone-soundfonts.com) to modify it. To start learning on how to contribute sounds, check out [Polyphone Documentation](https://www.polyphone-soundfonts.com/documentation/en/tutorials/index). You can add your name in the Copyright list in the General tab.

    2. The Style (Auto-accompaniment style) is basically a special kind of [MIDI file](https://www.midi.org/specifications/file-format-specifications/standard-midi-files). You can use [RoseGarden](https://www.rosegardenmusic.com) to create Styles. Be sure to follow the [_Style Specification_](https://github.com/SubhadeepJasu/Ensembles/blob/master/data/Styles/README.md) document, otherwise Ensembles won't recognize your Style file or run into errors and crashes. You can use any other DAW to make the Styles, so long as the Style file is as per specification.

* To follow up on general questions about development in GTK, head over to [Gnome Wiki](https://wiki.gnome.org/Newcomers/)

* Ensembles App is hosted at [Github](https://github.com/SubhadeepJasu/ensembles). The soundfont is hosted at [GitLab](https://gitlab.com/SubhadeepJasu/ensemblesgmsoundfont) via [GitLFS](https://git-lfs.github.com).

* Development happens in the `master` branch, thus all Pull Request should be opened against the `master` branch.

* Installing the app and soundfont

    You can install Ensembles by compiling it from source
    
    1. Install the required dependencies:
    
        - `elementary-sdk`
        - `gtk+-3.0>=3.18`
        - `granite>=5.3.0`
        - `glib-2.0`
        - `gobject-2.0`
        - `meson`
        - `libhandy-1`
        - `fluidsynth>=2.2.1`
        - `portmidi`

    2. Clone the app repository and change directory
        ```
        git clone https://github.com/SubhadeepJasu/ensembles.git
        cd ensembles
        ```

    3. Building:
        ```
        meson _build --prefix=/usr
        sudo ninja -C _build install
        ```
    
    4. Clone the SoundFont repository and change directory
        ```
        cd ..
        git clone https://gitlab.com/SubhadeepJasu/ensemblesgmsoundfont.git
        cd ensemblesgmsoundfont
        ```

    5. Installing SoundFont:
        ```
        meson _build --prefix=/usr
        sudo ninja -C _build install
        ```
> It is important to install the Ensembles GM SoundFont as well otherwise Ensembles won't make a sound (and may internally scream in pain)

## Reporting bugs and issues

### Security vulnerability

**If you find a security vulnerability, do NOT open an issue. Email _subhajasu@gmail.com_ instead.**

* Can I access something that's not mine, or something I shouldn't have access to?
* Can I interfere with other Apps or Devices connected to the PC via Ensembles in ways that I am not supposed to? Can any other App or Device interfere with Ensembles in ways it's not supposed to?
* Can I disable something for other people?
If the answer to any of those three questions is "yes", then you're probably dealing with a security issue. Note that even if you answer "no" to all questions, you may still be dealing with a security issue, so if you're unsure, just email us at _subhajasu@gmail.com_.

### Bugs/Issues

If you have found a bug, first of all, make sure you are using the latest version of Ensembles (latest commit on `master` branch) - your issue may already have been fixed. If not, search our [issues list](https://github.com/SUbhadeepJasu/ensembles/issues) on GitHub in case a similar issue has already been opened.

If you spot a problem with the docs, [search if an issue already exists](https://docs.github.com/en/github/searching-for-information-on-github/searching-on-github/searching-issues-and-pull-requests#search-by-the-title-body-or-comments)

If the issue has not been reported before, simply create [a new issue](https://github.com/SubhadeepJasu/ensembles/issues/new) via the [**Issues** section](https://github.com/SubhadeepJasu/ensembles/issues)

It is very helpful if you can prepare a reproduction of the bug. In other words, provide all the steps as well as a GIF or link to a video demonstrating the bug. It makes it easier to find the problem and to fix it.

Please adhere to the issue template and make sure you have provided as much information as possible. This helps the maintainers in resolving these issues considerably.

> **Please be careful** of publishing sensitive information you don't want other people to see, or images whose copyright does not allow redistribution; the bug tracker is a public resource and attachments are visible to everyone.

## Feature requests

If you find yourself wishing for a feature that doesn't exist in Ensembles, you are probably not alone. There are bound to be others out there with similar needs. Many of the features that Ensembles has today have been added because our users saw the need.

To request a feature, open an issue on our [issues list](https://github.com/SubhadeepJasu/ensembles/issues) on GitHub which describes the feature you would like to see, why you need it, and how it should work.

> Ensembles is maintained mainly by me and other contributors like you.

## Pull requests

For something that is bigger than a one or two line fix:

1. Create your own fork of the code
1. Create a branch
1. Commit your changes in the new branch
1. If you like the change and think the project could use it:
    * Be sure you have followed the code style for the project.
    * Open a pull request with a good description (including issue number)

## Review process

Pull Requests are looked at on a regular basis and they are dealt with on case by case basis and roadmap in mind.
