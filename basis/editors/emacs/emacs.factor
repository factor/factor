USING: combinators.short-circuit editors io.standard-paths
kernel make math.parser namespaces sequences system vocabs ;
IN: editors.emacs

SINGLETON: emacs

SYMBOL: emacsclient-path
SYMBOL: emacsclient-args

HOOK: find-emacsclient os ( -- path )

M: object find-emacsclient
    "emacsclient" ?find-in-path ;

M: emacs editor-command
    [
        emacsclient-path get [ find-emacsclient ] unless* ,
        emacsclient-args get [ { "-a=emacs" "--no-wait" } ] unless* %
        number>string "+" prepend ,
        ,
    ] { } make ;

os windows? [ "editors.emacs.windows" require ] when