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
    { "open" "-b" "com.microsoft.VSCode" "--args" } ;

ERROR: can't-find-visual-studio-code ;

M: linux find-visual-studio-code-invocation
    "Code" which [
        home "VSCode-linux-x64/Code" append-path dup exists? [
            can't-find-visual-studio-code
        ] unless
    ] unless* 1array ;

M: windows find-visual-studio-code-invocation
    { "Microsoft VS Code" } "code.exe" find-in-applications
    [ 1array ] [ can't-find-visual-studio-code ] if* ;

M: visual-studio-code editor-command ( file line -- command )
    [
        visual-studio-code-invocation % "-g" , "-r" ,
        number>string ":" glue ,
    ] { } make ;
