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
    'Services.vala'
)
