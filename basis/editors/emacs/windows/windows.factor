! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: editors.emacs io.directories.search.windows kernel sequences
system ;
IN: editors.emacs.windows

M: windows default-emacsclient
    "Emacs" t [ "emacsclient.exe" tail? ] find-in-program-files
    "emacsclient.exe" or ;
