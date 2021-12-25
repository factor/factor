USING: combinators.short-circuit editors io.standard-paths
kernel make math.parser namespaces sequences system ;
IN: editors.emacs

SINGLETON: emacs
emacs editor-class set-global

SYMBOL: emacsclient-path
SYMBOL: emacsclient-args

HOOK: find-emacsclient os ( -- path )

M: object find-emacsclient
    "emacsclient" ?find-in-path ;

M: windows find-emacsclient
    {
        [ { "Emacs" } "emacsclientw.exe" find-in-applications ]
        [ { "Emacs" } "emacsclient.exe" find-in-applications ]
        [ "emacsclient.exe" ]
    } 0|| ;

M: emacs editor-command
    [
        emacsclient-path get [ find-emacsclient ] unless* ,
        emacsclient-args get [ { "-a=emacs" "--no-wait" } ] unless* %
        number>string "+" prepend ,
        ,
    ] { } make ;
