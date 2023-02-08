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
    # Ensembles Core ################################################################

    'Core/ChoppingBlock/CentralBus.vala',   # To be removed

    'Core/MidiInput/MidiInputHost.vala',

    'Core/MidiPlayers/MetronomeAndLFO/MetronomeLFOPlayer.vala',
    'Core/MidiPlayers/SongPlayer/SongPlayer.vala',
    'Core/MidiPlayers/StyleEngine/Style.vala',
    'Core/MidiPlayers/StyleEngine/StyleAnalyser.vala',
    'Core/MidiPlayers/StyleEngine/StyleDiscovery.vala',
    'Core/MidiPlayers/StyleEngine/StylePlayer.vala',

    'Core/VoiceManager/Voice.vala',
    'Core/VoiceManager/VoiceAnalyser.vala',

    'Core/MidiRecorder/MidiRecorder.vala',
    'Core/MidiRecorder/MidiEvent.vala',
    'Core/MidiRecorder/PlayBackObject.vala',

    'Core/SamplingPads/SamplePlayer.vala',
    'Core/SamplingPads/SampleRecorder.vala',

    'Core/StateRegistry/Registry.vala',

    'Core/Synthesizer/Synthesizer.vala',

    'Core/Automators/Arpeggiator.vala',
    'Core/Automators/Harmonizer.vala',

    'Core/PluginRacks/EffectRack.vala',
    'Core/PluginRacks/InstrumentRack.vala',

    'Core/Utils/AudioDriverSniffer.vala',

    'Core/ArrangerCore.vala',

    # DE Integration #####################################################

    'Interfaces/MediaKeyListener.vala',
    'Interfaces/SoundIndicator.vala',

    # PlugIns ######################################################################

    'PlugIns/PlugIn.vala',
    'PlugIns/AtomPort.vala',
    'PlugIns/ControlPort.vala',
    'PlugIns/PlugInManager.vala',
    'PlugIns/PlugInAtom.vala',
    'PlugIns/PlugInControl.vala',

    # LADSPA VERSION 2
    'PlugIns/LV2/LV2Plugin.vala',
    'PlugIns/LV2/LV2Manager.vala',
    'PlugIns/LV2/LV2Constants.vala',
    'PlugIns/LV2/SyMap.vala',
    'PlugIns/LV2/LV2URID.vala',

    # Ensembles Shell ##############################################################

    'Shell/Widgets/DeviceItem.vala',
    'Shell/Widgets/Dial.vala',
    'Shell/Widgets/EffectItem.vala',
    'Shell/Widgets/Key.vala',
    'Shell/Widgets/OctaveKeyboard.vala',
    'Shell/Widgets/Knob.vala',
    'Shell/Widgets/MasterKnob.vala',
    'Shell/Widgets/StyleItem.vala',
    'Shell/Widgets/RecorderTrackItem.vala',
    'Shell/Widgets/ToggleSwitch.vala',
    'Shell/Widgets/VoiceItem.vala',
    'Shell/Widgets/EqualizerBar.vala',

    'Shell/Common/KeyboardConstants.vala',
    'Shell/Common/PcKeyboardHandler.vala',

    'Shell/Dialogs/Preferences/Item.vala',
    'Shell/Dialogs/Preferences/ItemInput.vala',
    'Shell/Dialogs/Preferences/ItemScale.vala',
    'Shell/Dialogs/Preferences/ItemSelect.vala',
    'Shell/Dialogs/Preferences/Preferences.vala',
    'Shell/Dialogs/Preferences/TopBox.vala',

    'Shell/Dialogs/MIDIAssignDialog.vala',

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
    'Shell/Layouts/KeyBed.vala',
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
    'Core/ChoppingBlock/central_bus.c',   # To be removed

    'Core/MidiInput/midi_input_host.c',

    'Core/MidiPlayers/MetronomeAndLFO/metronome_lfo_player.c',
    'Core/MidiPlayers/SongPlayer/song_player.c',
    'Core/MidiPlayers/StyleEngine/style_analyser.c',
    'Core/MidiPlayers/StyleEngine/style_player.c',

    'Core/VoiceManager/voice_analyser.c',

    'Core/Synthesizer/providers/synthesizer_instance.c',
    'Core/Synthesizer/providers/synthesizer_settings.c',
    'Core/Synthesizer/synthesizer.c',

    'Core/Utils/chord_finder.c'
)

ensembles_sources = [
    ensembles_sources_c,
    ensembles_sources_vala
]
