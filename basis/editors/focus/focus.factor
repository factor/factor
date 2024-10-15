USING: arrays combinators.short-circuit editors io.pathnames
io.standard-paths kernel namespaces system vocabs ;
IN: editors.focus

SINGLETON: focus

HOOK: focus-path os ( -- path )

M: windows focus-path
    {
        [ \ focus-path get ]
        [ "focus.exe" ]
    } 0|| ;

M: linux focus-path
    {
        [ \ focus-path get ]
        [ "focus-linux" find-in-path ]
        [ "~/.local/bin/focus-linux" absolute-path ]
    } 0|| ;

HOOK: focus-command os ( file line -- command )

M: object focus-command focus-path nip swap 2array ;

M: focus editor-command focus-command ;

os macos? [ "editors.focus.macos" require ] when
