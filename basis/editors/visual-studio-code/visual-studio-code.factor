! Copyright (C) 2015 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays ascii editors io.directories.search
io.files.temp.windows io.pathnames kernel make math.parser
memoize namespaces sequences ;
IN: editors.visual-studio-code

SINGLETON: visual-studio-code
visual-studio-code editor-class set-global

MEMO: visual-studio-code-path ( -- path )
    \ visual-studio-code-path get-global [
        get-appdata-directory 1array f
        [ file-name >lower "code.exe" = ] find-in-directories
        [ "code" ] unless*
    ] unless* ;

M: visual-studio-code editor-command ( file line -- command )
    [
        visual-studio-code-path ,
        swap , drop
    ] { } make ;
