# Set constants
conf_data = configuration_data ()
conf_data.set_quoted('VERSIONSTRING', meson.project_version())
conf_data.set_quoted('DISPLAYVER', display_version)
conf_data.set_quoted('PKGDATADIR', join_paths (get_option ('prefix'), get_option ('datadir'), meson.project_name()))
conf_data.set_quoted('SF2DATADIR', join_paths (get_option ('prefix'), get_option ('datadir'), 'sounds', 'sf2'))
conf_data.set_quoted('APP_ID', application_id)
conf_data.set_quoted('PROFILE', profile)

config_header = configure_file (
    input: 'Config.vala.in',
    output: 'Config.vala',
    configuration: conf_data
)

sources = files (
    'Main.vala',
    'Application.vala',

    # Shell
    'Shell/MainWindow.vala',

    'Shell/Layouts/DesktopLayout.vala',
    'Shell/Layouts/MobileLayout.vala',
    'Shell/Layouts/KioskLayout.vala',
    'Shell/Layouts/InfoDisplay.vala',
    'Shell/Layouts/Keyboard.vala',
    'Shell/Layouts/MixerBoard.vala',
    'Shell/Layouts/AssignablesBoard.vala',
    'Shell/Layouts/RegistryPanel.vala',
    'Shell/Layouts/SamplerPadsPanel.vala',
    'Shell/Layouts/StyleControlPanel.vala',
    'Shell/Layouts/SynthControlPanel.vala',
    'Shell/Layouts/VoiceNavPanel.vala',

    'Shell/Layouts/Display/HomeScreen.vala',
    'Shell/Layouts/Display/StyleScreen.vala',
    'Shell/Layouts/Display/DSPScreen.vala',
    'Shell/Layouts/Display/AudioPluginPicker.vala',

    'Shell/Widgets/BeatVisualization.vala',

    'Shell/Widgets/Display/WheelScrollableWidget.vala',
    'Shell/Widgets/Display/DisplayWindow.vala',
    'Shell/Widgets/Display/StyleMenuItem.vala',
    'Shell/Widgets/Display/DSPMenuItem.vala',

    'Shell/Dialogs/PowerDialog.vala',

    # Core
    'Core/ArrangerWorkstation.vala',

    'Core/Synthesizer/Synthesizer.vala',
    'Core/Synthesizer/SynthProvider.vala',
    'Core/Synthesizer/SynthSettingsPresets.vala',

    'Core/Analysers/ChordAnalyser.vala',
    'Core/Analysers/StyleAnalyser.vala',

    'Core/MIDIPlayers/StyleEngine.vala',

    'Core/FileLoaders/StyleFileLoader.vala',

    'Core/Racks/Rack.vala',
    'Core/Racks/DSPRack.vala',
    'Core/Racks/VoiceRack.vala',

    # Services
    'Services/EventBus.vala',
    'Services/Settings.vala',
    'Services/Theme.vala',

    # Utilities
    'Utils/Console.vala',
    'Utils/ErrorDomains.vala',
    'Utils/AccentColors.vala',
    'Utils/StyleMIDIModifiers.vala',
    'Utils/MIDI.vala',
    'Utils/DisplayTheme.vala',

    # Models
    'Models/Chord.vala',
    'Models/Registry.vala',
    'Models/Voice.vala',
    'Models/Style.vala',
    'Models/StylePart.vala',

    # Plugins
    'Core/Plugins/Plugin.vala',
    'Core/Plugins/PluginManager.vala',

    # Audio Plugins
    'Core/Plugins/AudioPlugins/AudioPlugin.vala',
    'Core/Plugins/AudioPlugins/Port.vala',

    # LV2 Plugins
    'Core/Plugins/AudioPlugins/LV2/LV2Manager.vala',
    'Core/Plugins/AudioPlugins/LV2/LV2Plugin.vala',
    'Core/Plugins/AudioPlugins/LV2/LV2URID.vala',
    'Core/Plugins/AudioPlugins/LV2/LV2SyMap.vala',
    'Core/Plugins/AudioPlugins/LV2/Ports/LV2Port.vala',
    'Core/Plugins/AudioPlugins/LV2/Ports/LV2ControlPort.vala'
)
