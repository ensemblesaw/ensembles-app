# Project name, programming language and version
project (
    'com.github.subhadeepjasu.ensembles',
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
    ['--vapidir', join_paths (meson.current_source_dir (), 'subprojects', 'ens-aw-core',  'vapi')],
    language: 'vala'
)

# Compiling resources
asresources = gnome.compile_resources (
    'as-resources',
    'data/' + meson.project_name () + '.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

build_dir = meson.current_build_dir()
message(build_dir.split('/')[-1])

# Listing dependencies
dependencies = [
    dependency ('glib-2.0'),
    dependency ('gee-0.8'),
    dependency ('libvinject-0.0.0', fallback: ['libvinject', 'vinject_dep']),
    dependency ('ens-enstl-0', fallback: ['enstl', 'enstl_dep']),
    dependency ('ens-shell-cli-0', fallback: ['ens-shell-cli', 'ens_shell_cli_dep']),
    dependency ('ens-shell-gtk-0', fallback: ['ens-shell-gtk', 'ens_shell_gtk_dep']),
    dependency ('ens-aw-core-0', fallback: ['ens-aw-core', 'ens_aw_core_dep'])
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
