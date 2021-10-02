# Project name, programming language and version
project (
    'com.github.subhadeepjasu.ensembles',
    'c', 'vala',
    version: '0.0.14',
)

# GNOME module
gnome = import ('gnome')

# Translation module
i18n = import ('i18n')

# Project arguments
add_project_arguments (
    '-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name ()),
    '-DHANDY_USE_UNSTABLE_API',
    language: 'c'
)

# Set Driver Compatibilities
add_project_arguments (
    '-D', 'ALSA_DRIVER',
    '-D', 'PULSEAUDIO_DRIVER',
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
    dependency ('granite'),
    dependency ('gtk+-3.0'),
    dependency ('glib-2.0'),
    dependency ('gobject-2.0'),
    dependency ('libsoup-2.4'),
    dependency ('json-glib-1.0'),
    dependency ('libhandy-1', version: '>=0.83.0'),
    dependency ('gstreamer-1.0'),
    meson.get_compiler ('vala').find_library ('posix'),
    meson.get_compiler ('c').find_library ('m', required : false),
    meson.get_compiler ('c').find_library ('fluidsynth', required : true),
    meson.get_compiler ('c').find_library ('portmidi', required : true),
    meson.get_compiler ('c').find_library ('X11', required : false),
]
config_h_dir = include_directories('.')
subdir ('data')
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

# subdir ('po')

meson.add_install_script ('meson/post_install.py')
