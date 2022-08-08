! Copyright (C) 2020 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators editors editors.visual-studio-code
io.pathnames io.standard-paths kernel namespaces system
tools.which ;
IN: editors.visual-studio-codium

SINGLETON: visual-studio-codium

INSTANCE: visual-studio-codium visual-studio-code-base

editor-class get-global dup [ visual-studio-code? not ] when
[ visual-studio-codium editor-class set-global ] unless

M: visual-studio-codium find-visual-studio-code-path
    os {
        { linux [ "codium" which ] }
        { macosx [
            "com.visualstudio.code.oss" find-native-bundle
            [ "Contents/MacOS/Electron" append-path ] [ f ] if* ] }
        { windows [
            { "Microsoft VS Codium" } "codium.cmd" find-in-applications ] }
    } case ;
