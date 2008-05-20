! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.backend kernel continuations destructors namespaces
sequences assocs hashtables sorting arrays threads boxes
io.timeouts accessors concurrency.mailboxes ;
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

TUPLE: monitor < identity-tuple path queue timeout ;

M: monitor hashcode* path>> hashcode* ;

M: monitor timeout timeout>> ;

M: monitor set-timeout (>>timeout) ;

: new-monitor ( path mailbox class -- monitor )
    new
        swap >>queue
        swap >>path ; inline

: queue-change ( path changes monitor -- )
    3dup and and
    [ [ 3array ] keep queue>> mailbox-put ] [ 3drop ] if ;

HOOK: (monitor) io-backend ( path recursive? mailbox -- monitor )

: <monitor> ( path recursive? -- monitor )
    <mailbox> (monitor) ;

: next-change ( monitor -- path changed )
    [ queue>> ] [ timeout ] bi mailbox-get-timeout first2 ;

SYMBOL: +add-file+
SYMBOL: +remove-file+
SYMBOL: +modify-file+
SYMBOL: +rename-file-old+
SYMBOL: +rename-file-new+
SYMBOL: +rename-file+

: with-monitor ( path recursive? quot -- )
    >r <monitor> r> with-disposal ; inline
