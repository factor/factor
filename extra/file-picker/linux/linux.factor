! Copyright (C) 2014, 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces ui.backend vocabs ;
IN: file-picker.linux

! Load only the toolkit used by this image; GTK3 and GTK4 cannot coexist.
ui-backend get name>> "gtk4-ui-backend" =
[ "file-picker.linux.gtk4" ] [ "file-picker.linux.gtk" ] if require
