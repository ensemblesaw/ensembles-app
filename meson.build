# Project name, programming language and version
project (
    'com.github.subhadeepjasu.ensembles',
    'c',
    version: '0.0.1',
)

# GNOME module
gnome = import ('gnome')

# Translation module
i18n = import ('i18n')

# Project arguments
add_project_arguments (
    '-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name ()),
    language: 'c'
)

# Compiling resources
# asresources = gnome.compile_resources (
#     'as-resources',
#     'data/' + meson.project_name () + '.gresource.xml',
#     source_dir: 'data',
#     c_name: 'as'
# )

# Listing dependencies
dependencies = [
    dependency ('granite'),
    dependency ('gtk+-3.0'),
    dependency ('glib-2.0'),
    dependency ('gsl'),
    dependency ('gobject-2.0'),
    dependency ('libsoup-2.4'),
    dependency ('json-glib-1.0'),
    dependency ('fluidsynth'),
    meson.get_compiler ('c').find_library ('m', required : false),
]

subdir ('src')
inc = include_directories ('src/Core')

# Define executable
executable (
    meson.project_name (),
    #asresources,
    ensembles_sources,
    include_directories: inc,
    dependencies: dependencies,
    install : true
)

# subdir ('data')
# subdir ('po')

# meson.add_install_script ('meson/post_install.py')
