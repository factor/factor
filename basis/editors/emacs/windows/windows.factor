! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: editors.emacs io.directories.search.windows kernel sequences
system combinators.short-circuit ;
IN: editors.emacs.windows

M: windows default-emacsclient
    {
        [ "Emacs" [ "emacsclientw.exe" tail? ] find-in-program-files ]
        [ "Emacs" [ "emacsclient.exe" tail? ] find-in-program-files ]
        [ "emacsclient.exe" ]
    } 0|| ;
