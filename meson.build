# Project name, programming language and version
project (
    'com.github.ensemblesaw.ensembles',
    'c', 'vala',
    version: '0.1.0',
    meson_version: '>=0.57.0',
    default_options: [
        'buildtype=debugoptimized'
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
    ['--vapidir', join_paths (meson.current_build_dir(), 'subprojects', 'ens-shell-gtk')],
    language: 'vala'
)

build_dir = meson.current_build_dir()
message(build_dir.split('/')[-1])

# Set up the profile
profile = get_option('profile')
if profile == 'development'
    application_id = meson.project_name() + 'Devel'
    schema_path = '/com/github/ensemblesaw/ensemblesDevel/'
else
    application_id = meson.project_name()
    schema_path = '/com/github/ensemblesaw/ensembles/'
endif
gettext_package = application_id

# Listing dependencies
dependencies = [
    dependency ('glib-2.0'),
    dependency ('gee-0.8'),
    # Core deps
    dependency ('fluidsynth', required: false),
    dependency ('lv2', required: false),
    dependency ('lilv-0', required: false),
    dependency ('suil-0', required: false),
    dependency ('zix-0', fallback: ['zix', 'zix_dep'], default_options: [
    'tests=disabled', 'default_library=static',
    'docs=disabled', 'tests_cpp=disabled',
    ], required: false),
    dependency ('portmidi', required: false),
    dependency ('libpipewire-0.3', required: false),
    dependency ('x11', required: false),
    dependency ('granite-7', required: false),
    dependency ('libadwaita-1', required: false),
    dependency ('gtk4', required: false),
    dependency ('gobject-2.0'),
    dependency ('libsoup-3.0', required: false),
    dependency ('json-glib-1.0', required: false),
    dependency ('Vinject-0.0.0', fallback: ['libvinject', 'vinject_dep']),
    dependency ('enstl-0', fallback: ['enstl', 'enstl_dep']),
    dependency ('ens-shell-cli-0', fallback: ['ens-shell-cli', 'ens_shell_cli_dep']),
    dependency ('ens-shell-gtk-0', fallback: ['ens-shell-gtk', 'ens_shell_gtk_dep'],
    default_options: ['profile=' + profile]),
    dependency ('ens-aw-core-0', fallback: ['ens-aw-core', 'ens_aw_core_dep'])
]

datadir = get_option ('datadir')
subdir ('data')
subdir ('po')
subdir ('src')

# Define executable
executable (
    meson.project_name (),
    sources,
    config_header,
    dependencies: dependencies,
    install: true
)

meson.add_install_script ('meson/post_install.py')
