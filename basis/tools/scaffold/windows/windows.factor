! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: io.pathnames system tools.scaffold windows.shell32 ;
IN: tools.scaffold.windows

M: windows scaffold-emacs ( -- )
    application-data ".emacs" append-path scaffold-file ;
