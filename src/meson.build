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
    'Core/EffectRack.vala',
    'Core/RealTimePlay.vala'
)

ensembles_sources_c = files (
    'Core/effect_rack.c',
    'Core/realtime_play.c'
)

ensembles_sources = [
    ensembles_sources_c,
    ensembles_sources_vala
]