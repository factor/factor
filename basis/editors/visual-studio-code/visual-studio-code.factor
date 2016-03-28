! Copyright (C) 2015 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays editors io.files io.pathnames io.standard-paths
kernel make math.parser memoize namespaces sequences system
tools.which ;
IN: editors.visual-studio-code

! Command line arguments
! https://code.visualstudio.com/docs/editor/codebasics#_additional-command-line-arguments

SINGLETON: visual-studio-code
visual-studio-code editor-class set-global

HOOK: find-visual-studio-code-invocation os ( -- array )

MEMO: visual-studio-code-invocation ( -- array )
    \ visual-studio-code-invocation get [
        find-visual-studio-code-invocation
        [ { "code" } ] unless*
    ] unless* ;

M: macosx find-visual-studio-code-invocation
    "com.microsoft.VSCode" find-native-bundle [
        "Contents/MacOS/Electron" append-path
    ] [
        f
    ] if* ;

ERROR: can't-find-visual-studio-code ;

M: linux find-visual-studio-code-invocation
    "Code" which [
        home "VSCode-linux-x64/Code" append-path
        dup exists? [ drop f ] unless
    ] unless* ;

M: windows find-visual-studio-code-invocation
    { "Microsoft VS Code" } "code.exe" find-in-applications
    [ f ] unless* ;

M: visual-studio-code editor-command ( file line -- command )
    [
        visual-studio-code-invocation
        [ , ] [ can't-find-visual-studio-code ] if*
        "-g" , "-r" ,
        number>string ":" glue ,
    ] { } make ;
