USING: definitions io.launcher kernel parser words sequences math
math.parser namespaces editors make system combinators.short-circuit
fry threads vocabs.loader ;
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
    ] { } make
    os windows? [ run-detached drop ] [ try-process ] if ;

: emacs ( word -- )
    where first2 emacsclient ;

os windows? [ "editors.emacs.windows" require ] when
