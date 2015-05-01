! Copyright (C) 2015 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: editors kernel make memoize namespaces system vocabs ;
IN: editors.visual-studio-code

SINGLETON: visual-studio-code
visual-studio-code editor-class set-global

HOOK: find-visual-studio-code-path os ( -- path )

MEMO: visual-studio-code-path ( -- path )
    \ visual-studio-code-path get-global [
        find-visual-studio-code-path
        [ "code" ] unless*
    ] unless* ;

M: visual-studio-code editor-command ( file line -- command )
    [
        visual-studio-code-path ,
        swap , drop
    ] { } make ;

os windows? [ "editors.visual-studio-code.windows" require ] when
