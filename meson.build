# Project name, programming language and version
project (
    'com.github.subhadeepjasu.ensembles',
    'c', 'vala',
    version: '0.1.0',
    meson_version: '>=0.57.0',
    default_options: [
        'buildtype=debugoptimized',
        'wrap_mode=nofallback'
    ]
)

# Common Display Version
display_version = 'AW-300'

message ('Unit Version: ' + display_version)

# GNOME module
gnome = import ('gnome')

# Translation module
i18n = import ('i18n')

# Project arguments
add_project_arguments (
    '-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name ()),
    '-DG_LOG_DOMAIN="Ensembles"',
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
    dependency ('fluidsynth'),
    dependency ('gstreamer-1.0'),
    dependency ('lv2'),
    dependency ('lilv-0'),
    dependency ('suil-0'),
    dependency ('zix-0', fallback: ['zix', 'zix_dep'], default_options: [
    'tests=disabled', 'default_library=static',
    'docs=disabled', 'tests_cpp=disabled',
    ]),
    dependency ('libpipewire-0.3'),
    meson.get_compiler ('vala').find_library ('posix'),
    meson.get_compiler ('c').find_library ('m', required : true),
    meson.get_compiler ('c').find_library ('X11', required : true),
]

# Set up the profile
profile = get_option('profile')
if profile == 'development'
    application_id = meson.project_name() + 'Devel'
    schema_path = '/com/github/subhadeepjasu/ensemblesDevel/'
else
    application_id = meson.project_name()
    schema_path = '/com/github/subhadeepjasu/ensembles/'
endif
gettext_package = application_id

subdir ('src')

# Define executable
executable (
    meson.project_name (),
    asresources,
    sources,
    config_header,
    dependencies: dependencies,
    install: true
)

datadir = get_option ('datadir')
subdir ('data')
subdir ('po')

meson.add_install_script ('meson/post_install.py')
