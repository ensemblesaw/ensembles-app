conf_data = configuration_data()
conf_data.set_quoted('PKGDATADIR', join_paths(get_option('prefix'), get_option('datadir'), meson.project_name()))
conf_data.set_quoted('SF2DATADIR', join_paths(get_option('prefix'), get_option('datadir'), 'sounds', 'sf2'))
config_header = configure_file(
    input: 'Config.vala.in',
    output: 'Config.vala',
    configuration: conf_data
)




# Listing files to compile
ensembles_sources_vala = files (
    'Main.vala',
    'Shell/Application.vala',
    'Shell/MainWindow.vala',
    'Shell/Common/DeviceItem.vala',
    'Shell/Common/VoiceItem.vala',
    'Shell/Common/StyleItem.vala',
    'Shell/Common/ToggleSwitch.vala',
    'Shell/Common/Dial.vala',
    'Shell/Common/Knob.vala',
    'Shell/Common/MasterKnob.vala',
    'Shell/Common/Key.vala',
    'Shell/Common/OctaveKeyboard.vala',
    'Shell/Common/EqualizerBar.vala',
    'Shell/Common/KeyboardConstants.vala',
    'Shell/Common/PcKeyboardHandler.vala',
    'Shell/Views/AppMenuView.vala',
    'Shell/Views/StyleControllerView.vala',
    'Shell/Views/BeatCounterView.vala',
    'Shell/Views/ControlPanel.vala',
    'Shell/Views/SliderBoardView.vala',
    'Shell/Views/MixerBoardView.vala',
    'Shell/Views/VoiceCategoryView.vala',
    'Shell/Views/RegistryView.vala',
    'Shell/Views/SamplerPadView.vala',
    'Shell/Views/SongControllerView.vala',
    'Shell/Views/KeyboardView.vala',
    'Shell/Views/JoyStick.vala',
    'Shell/Display/WheelScrollableWidget.vala',
    'Shell/Display/HomeScreen.vala',
    'Shell/Display/MainDisplayCasing.vala',
    'Shell/Display/StyleMenu.vala',
    'Shell/Display/VoiceMenu.vala',
    'Shell/Display/ChannelModulatorScreen.vala',
    'Shell/Display/LFOEditScreen.vala',
    'Shell/Display/TempoScreen.vala',
    'Shell/Dialogs/ErrorDialog.vala',
    'Shell/Dialogs/Preferences/Item.vala',
    'Shell/Dialogs/Preferences/ItemSelect.vala',
    'Shell/Dialogs/Preferences/ItemScale.vala',
    'Shell/Dialogs/Preferences/TopBox.vala',
    'Shell/Dialogs/Preferences/Preferences.vala',
    'Core/DriverSettingsProvider.vala',
    'Core/Arpeggiator.vala',
    'Core/Harmonizer.vala',
    'Core/Synthesizer.vala',
    'Core/Controller.vala',
    'Core/StyleDiscovery.vala',
    'Core/CentralBus.vala',
    'Core/StylePlayer.vala',
    'Core/MetronomeLFOPlayer.vala',
    'Core/StyleAnalyser.vala',
    'Core/Voice.vala',
    'Core/Style.vala',
    'Core/Registry.vala',
    'Core/VoiceAnalyser.vala',
    'Core/SamplePlayer.vala',
    'Core/SampleRecorder.vala',
    'Core/SongPlayer.vala',
    'Core/EffectRack.vala',
    'Interfaces/MediaKeyListener.vala',
    'Interfaces/SoundIndicator.vala',
    # Plugins ############################################################
    'PlugIns/PlugIn.vala',
    'PlugIns/PlugInManager.vala',
    # LADSPA VERSION 2
    'PlugIns/LV2/LV2Manager.vala'
)

ensembles_sources_c = files (
    'Core/central_bus.c',
    'Core/synthesizer_settings.c',
    'Core/driver_settings_provider.c',
    'Core/synthesizer.c',
    'Core/controller.c',
    'Core/style_player.c',
    'Core/metronome_lfo_player.c',
    'Core/style_analyser.c',
    'Core/chord_finder.c',
    'Core/voice_analyser.c',
    'Core/music_player.c'
)

ensembles_sources = [
    ensembles_sources_c,
    ensembles_sources_vala
]
