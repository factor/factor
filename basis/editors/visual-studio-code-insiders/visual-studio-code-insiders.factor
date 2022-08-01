! Copyright (C) 2020 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators editors editors.visual-studio-code
io.pathnames io.standard-paths kernel namespaces system
tools.which ;
IN: editors.visual-studio-code-insiders

TUPLE: visual-studio-code-insiders < visual-studio-code ;

editor-class [ T{ visual-studio-code-insiders } ] initialize

M: visual-studio-code-insiders find-visual-studio-code-path
    os {
        { linux [ "code-insiders" which ] }
        { macosx [
            "com.microsoft.VSCodeInsiders" find-native-bundle
            [ "Contents/MacOS/Electron" append-path ] [ f ] if* ] }
        { windows [
            { "Microsoft VS Code Insiders" } "code-insiders.cmd" find-in-applications ] }
    } case ;
