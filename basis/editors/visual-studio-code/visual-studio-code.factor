! Copyright (C) 2015 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays editors io.files io.pathnames kernel make
math.parser memoize namespaces sequences system tools.which
vocabs ;
IN: editors.visual-studio-code

SINGLETON: visual-studio-code
visual-studio-code editor-class set-global

HOOK: find-visual-studio-code-invocation os ( -- array )

MEMO: visual-studio-code-invocation ( -- array )
    \ visual-studio-code-invocation get [
        find-visual-studio-code-invocation
        [ { "code" } ] unless*
    ] unless* ;

M: macosx find-visual-studio-code-invocation
    { "open" "-n" "-b" "com.microsoft.VSCode" "--args" } ;

ERROR: can't-find-visual-studio-code ;

M: linux find-visual-studio-code-invocation
    "Code" which [
        home "VSCode-linux-x64/Code" append-path dup exists? [
            can't-find-visual-studio-code
        ] unless
    ] unless* 1array ;

M: visual-studio-code editor-command ( file line -- command )
    [
        visual-studio-code-invocation % "-g" ,
        number>string ":" glue ,
    ] { } make ;

os windows? [ "editors.visual-studio-code.windows" require ] when
