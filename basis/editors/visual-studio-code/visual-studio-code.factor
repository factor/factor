! Copyright (C) 2015 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators combinators.short-circuit editors
generalizations io.files io.pathnames io.standard-paths kernel
make math.parser namespaces sequences system tools.which ;
IN: editors.visual-studio-code

! Command line arguments
! https://code.visualstudio.com/docs/editor/command-line

MIXIN: visual-studio-code-base

SINGLETON: visual-studio-code

INSTANCE: visual-studio-code visual-studio-code-base

HOOK: find-visual-studio-code-path editor-class ( -- path )

M: visual-studio-code-base find-visual-studio-code-path
    os {
        { linux [
            {
                [ "code" which ]
                [ "Code" which ]
                [ "~/VSCode-linux-x64/Code" ]
                [ "/usr/share/code/code" ]
            } [ dup file-exists? and* ] map-compose 0|| ] }
        { macosx [
            "com.microsoft.VSCode" find-native-bundle
            [ "Contents/MacOS/Electron" append-path ] [ f ] if* ] }
        { windows [ "code.cmd" ] }
    } case ;

: visual-studio-code-invocation ( -- path )
    {
        [ \ visual-studio-code-invocation get ]
        [ find-visual-studio-code-path ]
        [ "code" ]
    } 0|| ;

ERROR: can't-find-visual-studio-code ;

: visual-studio-code-editor-command ( file line -- seq )
    [
        visual-studio-code-invocation
        [ , ] [ can't-find-visual-studio-code ] if*
        "-g" , "-r" ,
        number>string ":" glue ,
    ] { } make ;

M: visual-studio-code-base editor-command
    visual-studio-code-editor-command ;
