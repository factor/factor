! Copyright (C) 2015 Dimage Sapelkin.
! See http://factorcode.org/license.txt for BSD license.
USING: editors io.pathnames io.standard-paths kernel make
namespaces system vocabs ;
IN: editors.brackets

SINGLETON: brackets-editor
brackets-editor editor-class set-global

HOOK: brackets-path os ( -- path )

M: macosx brackets-path
    "io.brackets.appshell" find-native-bundle [
        "Contents/MacOS/Brackets" append-path
    ] [
        f
    ] if* ;

M: brackets-editor editor-command ( file line -- command )
    [ brackets-path "brackets" or , drop , ] { } make ;

os windows? [ "editors.brackets.windows" require ] when
