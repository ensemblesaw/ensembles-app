# Project name, programming language and version
project (
    'com.github.subhadeepjasu.ensembles',
    'c', 'vala',
    version: '0.0.17',
)

# Common Display Version
display_version = 'AW-200'

message ('Unit Version: ' + display_version)

# GNOME module
gnome = import ('gnome')

# Translation module
i18n = import ('i18n')

# Project arguments
add_project_arguments (
    '-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name ()),
    '-DHANDY_USE_UNSTABLE_API',
    '-DPIPEWIRE_CORE_DRIVER',  # Uncomment to enable pipewire core support provided fluidsynth supports it
    language: 'c'
)

add_project_arguments (
    ['--vapidir', join_paths (meson.current_source_dir (), 'vapi')],
    # Set Driver Compatibilities
    '-D', 'ALSA_DRIVER',
    '-D', 'PULSEAUDIO_DRIVER',
    '-D', 'JACK_DRIVER',
    # '-D', 'PIPEWIRE_CORE_DRIVER',  # Uncomment to enable pipewire core support provided fluidsynth supports it
    language: 'vala'
)

# Compiling resources
asresources = gnome.compile_resources (
    'as-resources',
    'data/' + meson.project_name () + '.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

# Listing dependencies
dependencies = [
    dependency ('x11'),
    dependency ('granite-7'),
    dependency ('libadwaita-1'),
    dependency ('gtk4'),
    dependency ('glib-2.0'),
    dependency ('gobject-2.0'),
    dependency ('libsoup-3.0'),
    dependency ('json-glib-1.0'),
    dependency ('gstreamer-1.0'),
    dependency ('lv2'),
    dependency ('lilv-0'),
    dependency ('suil-0'),
    dependency ('libpipewire-0.3'), # Uncomment to enable pipewire core support provided fluidsynth supports it
    meson.get_compiler ('vala').find_library ('posix'),
    meson.get_compiler ('c').find_library ('m', required : true),
    meson.get_compiler ('c').find_library ('fluidsynth', required : true),
    meson.get_compiler ('c').find_library ('portmidi', required : true),
    meson.get_compiler ('c').find_library ('X11', required : true),
]

config_h_dir = include_directories('.')

subdir ('src')

# Define executable
executable (
    meson.project_name (),
    asresources,
    ensembles_sources,
    config_header,
    include_directories: config_h_dir,
    dependencies: dependencies,
    install : true
)

subdir ('data')
subdir ('po')

meson.add_install_script ('meson/post_install.py')
