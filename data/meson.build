# Install icons
icon_sizes = ['16', '24', '32', '48', '64', '128']

foreach i : icon_sizes
    install_data (
        join_paths ('Icons', i, meson.project_name () + '.svg'),
        install_dir: join_paths (get_option ('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps')
    )
    install_data (
        join_paths ('Icons', i, meson.project_name() + '.svg'),
        install_dir: join_paths (get_option ('datadir'), 'icons', 'hicolor', i + 'x' + i + '@2', 'apps')
    )
endforeach

install_data (
    join_paths ('Icons', 'symbolic', meson.project_name() + '-symbolic.svg'),
    install_dir: join_paths (get_option ('datadir'), 'icons', 'hicolor', 'symbolic', 'apps')
)

# Install fonts

install_data (
    join_paths ('Fonts', 'Exo2', 'Exo2-VariableFont_wght.ttf'),
    install_dir: join_paths (get_option ('datadir'), 'fonts', 'truetype', 'Exo2')
)

install_data (
    join_paths ('Fonts', 'Exo2', 'Exo2-Italic-VariableFont_wght.ttf'),
    install_dir: join_paths (get_option ('datadir'), 'fonts', 'truetype', 'Exo2')
)

install_data (
    join_paths ('Fonts', 'Michroma', 'Michroma-Regular.ttf'),
    install_dir: join_paths (get_option ('datadir'), 'fonts', 'truetype', 'Michroma')
)

# Translate and install our .desktop file so the Applications Menu will see it
i18n.merge_file (
    input: meson.project_name () + '.desktop.in',
    output: meson.project_name () + '.desktop',
    po_dir: join_paths (meson.project_source_root (), 'po', 'extra'),
    type: 'desktop',
    install: true,
    install_dir: join_paths (get_option ('datadir'), 'applications')
)

# Install our kiosk mode desktop file in xsessions
install_data (
    meson.project_name () + '.kiosk.desktop',
    install_dir: join_paths (get_option ('datadir'), 'xsessions')
)

# Translate and install our .appdata.xml file so AppCenter will see it
i18n.merge_file (
    input: meson.project_name () + '.appdata.xml.in',
    output: meson.project_name () + '.appdata.xml',
    po_dir: join_paths (meson.project_source_root (), 'po', 'extra'),
    install: true,
    install_dir: join_paths (get_option ('datadir'), 'metainfo')
)

# Install documents
install_subdir (
    'Docs',
    install_dir: join_paths (get_option ('datadir'), meson.project_name ())
)
