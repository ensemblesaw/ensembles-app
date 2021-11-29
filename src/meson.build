conf_data = configuration_data ()
conf_data.set_quoted('VERSIONSTRING', meson.project_version())
conf_data.set_quoted('DISPLAYVER', display_version)
conf_data.set_quoted('PKGDATADIR', join_paths (get_option ('prefix'), get_option ('datadir'), meson.project_name()))
conf_data.set_quoted('SF2DATADIR', join_paths (get_option ('prefix'), get_option ('datadir'), 'sounds', 'sf2'))

config_header = configure_file (
    input: 'Config.vala.in',
    output: 'Config.vala',
    configuration: conf_data
)

# Listing files to compile
ensembles_sources_vala = files (
    'Core/DriverSettingsProvider.vala',
    'Core/Arpeggiator.vala',
    'Core/CentralBus.vala',
    'Core/Controller.vala',
    'Core/DriverSettingsProvider.vala',
    'Core/EffectRack.vala',

    'Core/Harmonizer.vala',
    'Core/InstrumentRack.vala',
    'Core/MetronomeLFOPlayer.vala',
    'Core/Registry.vala',
    'Core/SamplePlayer.vala',
    'Core/SampleRecorder.vala',
    'Core/SongPlayer.vala',
    'Core/EffectRack.vala',
    'Core/InstrumentRack.vala',
    'Core/MidiRecorder.vala',
    'Core/Style.vala',
    'Core/StyleAnalyser.vala',
    'Core/StyleDiscovery.vala',
    'Core/StylePlayer.vala',
    'Core/Synthesizer.vala',
    'Core/Voice.vala',
    'Core/VoiceAnalyser.vala',

    'Core/ArrangerCore.vala',

    'Interfaces/MediaKeyListener.vala',
    'Interfaces/SoundIndicator.vala',

    'Shell/Widgets/DeviceItem.vala',
    'Shell/Widgets/Dial.vala',
    'Shell/Widgets/EffectItem.vala',
    'Shell/Widgets/Key.vala',
    'Shell/Widgets/Knob.vala',
    'Shell/Widgets/MasterKnob.vala',
    'Shell/Widgets/StyleItem.vala',
    'Shell/Widgets/RecorderTrackItem.vala',
    'Shell/Widgets/ToggleSwitch.vala',
    'Shell/Widgets/VoiceItem.vala',
    'Shell/Widgets/EqualizerBar.vala',

    'Shell/Common/KeyboardConstants.vala',
    'Shell/Common/OctaveKeyboard.vala',
    'Shell/Common/PcKeyboardHandler.vala',

    # PlugIns
    'PlugIns/PlugIn.vala',
    'PlugIns/AtomPort.vala',
    'PlugIns/ControlPort.vala',
    'PlugIns/PlugInManager.vala',
    'PlugIns/PlugInAtom.vala',
    'PlugIns/PlugInControl.vala',

    # LADSPA VERSION 2
    'PlugIns/LV2/LV2Manager.vala',
    'PlugIns/LV2/SyMap.vala',

    'Shell/Dialogs/Preferences/Item.vala',
    'Shell/Dialogs/Preferences/ItemInput.vala',
    'Shell/Dialogs/Preferences/ItemScale.vala',
    'Shell/Dialogs/Preferences/ItemSelect.vala',
    'Shell/Dialogs/Preferences/Preferences.vala',
    'Shell/Dialogs/Preferences/TopBox.vala',

    'Shell/Dialogs/ErrorDialog.vala',

    'Shell/Display/ChannelModulatorScreen.vala',
    'Shell/Display/EffectRackScreen.vala',
    'Shell/Display/HomeScreen.vala',
    'Shell/Display/LFOEditScreen.vala',
    'Shell/Display/CentralDisplay.vala',
    'Shell/Display/StyleMenu.vala',
    'Shell/Display/TempoScreen.vala',
    'Shell/Display/RecorderScreen.vala',
    'Shell/Display/VoiceMenu.vala',
    'Shell/Display/WheelScrollableWidget.vala',

    'Shell/Layouts/AppMenuView.vala',
    'Shell/Layouts/BeatCounterView.vala',
    'Shell/Layouts/ControlPanel.vala',
    'Shell/Layouts/JoyStick.vala',
    'Shell/Layouts/KeyboardView.vala',
    'Shell/Layouts/MixerBoardView.vala',
    'Shell/Layouts/RegistryView.vala',
    'Shell/Layouts/SamplerPadView.vala',
    'Shell/Layouts/SliderBoardView.vala',
    'Shell/Layouts/SongControllerView.vala',
    'Shell/Layouts/StyleControllerView.vala',
    'Shell/Layouts/VoiceCategoryView.vala',

    'Shell/MainWindow.vala',

    'Application.vala',
    'Utils.vala',

    'Main.vala'
)

ensembles_sources_c = files (
    'Core/central_bus.c',
    'Core/chord_finder.c',
    'Core/controller.c',
    'Core/driver_settings_provider.c',
    'Core/metronome_lfo_player.c',
    'Core/music_player.c',
    'Core/style_analyser.c',
    'Core/style_player.c',
    'Core/synthesizer_settings.c',
    'Core/synthesizer.c',
    'Core/voice_analyser.c'
)

ensembles_sources = [
    ensembles_sources_c,
    ensembles_sources_vala
]
