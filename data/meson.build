# Install icons
icon_sizes = ['16', '24', '32', '48', '64', '128']

foreach i : icon_sizes
    install_data (
        join_paths ('icons', i, meson.project_name () + '.svg'),
        install_dir: join_paths (get_option ('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps')
    )
    install_data (
        join_paths ('icons', i, meson.project_name() + '.svg'),
        install_dir: join_paths (get_option ('datadir'), 'icons', 'hicolor', i + 'x' + i + '@2', 'apps')
    )
endforeach

# Translate and install our .desktop file so the Applications Menu will see it
i18n.merge_file (
    input: meson.project_name () + '.desktop.in',
    output: meson.project_name () + '.desktop',
    po_dir: join_paths (meson.source_root (), 'po', 'extra'),
    type: 'desktop',
    install: true,
    install_dir: join_paths (get_option ('datadir'), 'applications')
)

# install_data(
#     join_paths('SoundFonts/', 'EnsemblesGM.sf2'),
#     install_dir: join_paths(get_option('datadir'), meson.project_name(), 'SoundFonts')
# )

# install_data(
#     join_paths('SoundFonts/', 'EnsemblesGMSchema.csv'),
#     install_dir: join_paths(get_option('datadir'), meson.project_name(), 'SoundFonts')
# )

install_subdir(
    join_paths('Styles'),
    install_dir: join_paths(get_option('datadir'), meson.project_name())
)

install_subdir(
    join_paths('Images/', 'Instruments'),
    install_dir: join_paths(get_option('datadir'), meson.project_name())
)
