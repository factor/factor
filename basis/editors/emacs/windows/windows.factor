! Copyright (C) 2022 nomennescio
! See https://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit continuations editors editors.emacs
io.pathnames io.standard-paths kernel make math.parser
namespaces sequences system windows.advapi32 windows.registry ;
IN: editors.emacs.windows

CONSTANT: registry-path-to-emacs "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\App Paths\\emacs.exe"

M: windows find-emacsclient
    {
        [ [ HKEY_LOCAL_MACHINE registry-path-to-emacs "" query-registry
            parent-directory "emacsclientw.exe" append-path ] [ drop f ] recover ]
        [ { "Emacs" } "emacsclientw.exe" find-in-applications ]
        [ { "Emacs" } "emacsclient.exe" find-in-applications ]
        [ "emacsclient.exe" ]
    } 0|| ;