! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.backend kernel continuations destructors namespaces
sequences assocs hashtables sorting arrays threads boxes
io.timeouts accessors concurrency.mailboxes fry
system vocabs combinators ;
IN: io.monitors

HOOK: init-monitors io-backend ( -- )

M: object init-monitors ;

HOOK: dispose-monitors io-backend ( -- )

M: object dispose-monitors ;

: with-monitors ( quot -- )
    [
        init-monitors
        [ dispose-monitors ] [ ] cleanup
    ] with-scope ; inline

TUPLE: monitor < disposable path queue timeout ;

M: monitor timeout timeout>> ;

M: monitor set-timeout timeout<< ;

<PRIVATE

SYMBOL: monitor-disposed

PRIVATE>

M: monitor dispose*
    [ monitor-disposed ] dip queue>> mailbox-put ;

: new-monitor ( path mailbox class -- monitor )
    new-disposable
        swap >>queue
        swap >>path ; inline

TUPLE: file-change path changed monitor ;

: queue-change ( path changes monitor -- )
    3dup and and [
        [ check-disposed ] keep
        [ file-change boa ] keep
        queue>> mailbox-put
    ] [ 3drop ] if ;

HOOK: (monitor) io-backend ( path recursive? mailbox -- monitor )

: <monitor> ( path recursive? -- monitor )
    <mailbox> (monitor) ;

: next-change ( monitor -- change )
    [ check-disposed ]
    [
        [ ] [ queue>> ] [ timeout ] tri mailbox-get-timeout
        dup monitor-disposed eq? [ drop already-disposed ] [ nip ] if
    ] bi ;

SYMBOL: +add-file+
SYMBOL: +remove-file+
SYMBOL: +modify-file+
SYMBOL: +rename-file-old+
SYMBOL: +rename-file-new+
SYMBOL: +rename-file+

: with-monitor ( path recursive? quot -- )
    [ <monitor> ] dip with-disposal ; inline

: run-monitor ( path recursive? quot -- )
    '[ [ @ t ] loop ] with-monitor ; inline

{
    { [ os macosx? ] [ "io.monitors.macosx" require ] }
    { [ os linux? ] [ "io.monitors.linux" require ] }
    { [ os windows? ] [ "io.monitors.windows" require ] }
    { [ os bsd? ] [ ] }
} cond
