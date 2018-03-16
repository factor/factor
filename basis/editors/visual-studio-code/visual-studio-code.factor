! Copyright (C) 2015 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.extras combinators.short-circuit editors
generalizations io.files io.pathnames io.standard-paths kernel
make math.parser memoize namespaces sequences system tools.which ;
IN: editors.visual-studio-code

! Command line arguments
! https://code.visualstudio.com/docs/editor/command-line

SINGLETON: visual-studio-code
visual-studio-code editor-class set-global

HOOK: find-visual-studio-code-invocation os ( -- array )

MEMO: visual-studio-code-invocation ( -- array )
    {
        [ \ visual-studio-code-invocation get ]
        [ find-visual-studio-code-invocation ]
        [ "code" ]
    } 0|| ;

M: macosx find-visual-studio-code-invocation
    "com.microsoft.VSCode" find-native-bundle [
        "Contents/MacOS/Electron" append-path
    ] [
        f
    ] if* ;

ERROR: can't-find-visual-studio-code ;

M: linux find-visual-studio-code-invocation
    {
        [ "code" which ]
        [ "Code" which ]
        [ home "VSCode-linux-x64/Code" append-path ]
        [ "/usr/share/code/code" ]
    } [ [ exists? ] ?1arg ] map-compose 0|| ;

M: windows find-visual-studio-code-invocation
    {
        [ { "Microsoft VS Code" } "code.exe" find-in-applications ]
    } 0|| ;

M: visual-studio-code editor-command ( file line -- command )
    [
        visual-studio-code-invocation
        [ , ] [ can't-find-visual-studio-code ] if*
        "-g" , "-r" ,
        number>string ":" glue ,
    ] { } make ;
