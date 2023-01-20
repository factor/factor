! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors concurrency.mailboxes continuations destructors
fry io.backend io.timeouts kernel namespaces sequences system
vocabs ;
IN: io.monitors

HOOK: init-monitors io-backend ( -- )

M: object init-monitors ;

HOOK: dispose-monitors io-backend ( -- )

M: object dispose-monitors ;

: with-monitors ( quot -- )
    [
        init-monitors
        [ dispose-monitors ] finally
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
        check-disposed
        [ file-change boa ] keep
        queue>> mailbox-put
    ] [ 3drop ] if ;

HOOK: (monitor) io-backend ( path recursive? mailbox -- monitor )

: <monitor> ( path recursive? -- monitor )
    <mailbox> (monitor) ;

: next-change ( monitor -- change )
    check-disposed
    [ ] [ queue>> ] [ timeout ] tri mailbox-get-timeout
    dup monitor-disposed eq? [ drop already-disposed ] [ nip ] if ;

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

"io.monitors." os name>> append require
