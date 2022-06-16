! Copyright (C) 2020 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators editors editors.visual-studio-code
io.pathnames io.standard-paths kernel namespaces system
tools.which ;
IN: editors.codium

TUPLE: codium < visual-studio-code ;

T{ codium } editor-class set-global

M: codium find-visual-studio-code-path
    os {
        { linux [ "codium" which ] }
        { macosx [
            "com.visualstudio.code.oss" find-native-bundle
            [ "Contents/MacOS/Electron" append-path ] [ f ] if* ] }
        { windows [
            { "Microsoft VS Codium" } "codium.cmd" find-in-applications ] }
    } case ;
