! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.backend kernel continuations destructors namespaces
sequences assocs hashtables sorting arrays threads boxes
io.timeouts accessors concurrency.mailboxes fry
system vocabs.loader combinators ;
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

TUPLE: file-change path changed monitor ;

: queue-change ( path changes monitor -- )
    3dup and and
    [ [ file-change boa ] keep queue>> mailbox-put ] [ 3drop ] if ;

HOOK: (monitor) io-backend ( path recursive? mailbox -- monitor )

: <monitor> ( path recursive? -- monitor )
    <mailbox> (monitor) ;

: next-change ( monitor -- change )
    [ queue>> ] [ timeout ] bi mailbox-get-timeout ;

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

: spawn-monitor ( path recursive? quot -- )
    [ '[ _ _ _ run-monitor ] ] [ 2drop "Monitoring " prepend ] 3bi
    spawn drop ;
{
    { [ os macosx? ] [ "io.monitors.macosx" require ] }
    { [ os linux? ] [ "io.monitors.linux" require ] }
    { [ os winnt? ] [ "io.monitors.windows.nt" require ] }
    { [ os bsd? ] [ ] }
} cond
