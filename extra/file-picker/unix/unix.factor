! Copyright (C) 2014, 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces ui.backend vocabs ;
IN: file-picker.unix

! Load only the toolkit used by this image; GTK3 and GTK4 cannot coexist.
ui-backend get name>> "gtk4-ui-backend" =
[ "file-picker.unix.gtk4" ] [ "file-picker.unix.gtk" ] if require
