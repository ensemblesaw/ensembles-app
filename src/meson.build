conf_data = configuration_data()
conf_data.set_quoted('PKGDATADIR', join_paths(get_option('prefix'), get_option('datadir'), meson.project_name()))
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
    'Shell/Common/ToggleSwitch.vala',
    'Shell/Common/Dial.vala',
    'Shell/Common/Knob.vala',
    'Shell/Common/SuperKnob.vala',
    'Shell/Common/Key.vala',
    'Shell/Common/OctaveKeyboard.vala',
    'Shell/Common/EqualizerBar.vala',
    'Shell/Views/AppMenuView.vala',
    'Shell/Views/StyleControllerView.vala',
    'Shell/Views/BeatCounterView.vala',
    'Shell/Views/ControlPanel.vala',
    'Shell/Views/SliderBoardView.vala',
    'Shell/Views/MixerBoardView.vala',
    'Shell/Views/VoiceCategoryView.vala',
    'Shell/Views/RegistryView.vala',
    'Shell/Views/MultipadView.vala',
    'Shell/Views/SongControllerView.vala',
    'Shell/Views/KeyboardView.vala',
    'Shell/Views/JoyStick.vala',
    'Shell/Display/WheelScrollableWidget.vala',
    'Shell/Display/HomeScreen.vala',
    'Shell/Display/MainDisplayCasing.vala',
    'Shell/Display/StyleMenu.vala',
    'Shell/Display/VoiceMenu.vala',
    'Shell/Display/ChannelModulatorScreen.vala',
    'Core/Synthesizer.vala',
    'Core/Controller.vala',
    'Core/StyleDiscovery.vala',
    'Core/CentralBus.vala',
    'Core/RealTimePlay.vala',
    'Core/StylePlayer.vala',
    'Core/StyleAnalyser.vala',
    'Core/Voice.vala',
    'Core/VoiceAnalyser.vala'
)

ensembles_sources_c = files (
    'Core/synthesizer.c',
    'Core/controller.c',
    'Core/central_bus.h',
    'Core/realtime_play.c',
    'Core/style_player.c',
    'Core/style_analyser.c',
    'Core/chord_finder.c',
    'Core/voice_analyser.c'
)

ensembles_sources = [
    ensembles_sources_c,
    ensembles_sources_vala
]