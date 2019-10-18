USING: combinators.short-circuit editors kernel make
math.parser namespaces sequences system vocabs ;
IN: editors.emacs

SINGLETON: emacsclient
emacsclient editor-class set-global

SYMBOL: emacsclient-path

HOOK: default-emacsclient os ( -- path )

M: object default-emacsclient ( -- path ) "emacsclient" ;

M: emacsclient editor-command ( file line -- command )
    [
        {
            [ emacsclient-path get-global ]
            [ default-emacsclient dup emacsclient-path set-global ]
        } 0|| ,
        "--no-wait" ,
        number>string "+" prepend ,
        ,
    ] { } make ;

os windows? [ "editors.emacs.windows" require ] when

