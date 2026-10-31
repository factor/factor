USING: accessors alien.c-types alien.data arrays assocs classes.struct
combinators concurrency.mailboxes continuations destructors
io.backend io.backend.unix io.directories io.files io.files.info
io.files.info.unix io.files.links io.files.types io.monitors io.monitors.recursive
hashtables io.pathnames kernel libc literals locals make math math.bitwise namespaces sequences
sequences.generalizations
specialized-arrays system threads unix unix.ffi unix.kqueue unix.time ;
SPECIALIZED-ARRAY: kevent
IN: io.monitors.freebsd

SYMBOL: freebsd-monitors

TUPLE: vnode-watch < disposable handle info ;
TUPLE: freebsd-monitor < monitor handle root watches events owner ;

: watch-signature ( info -- signature )
    { [ dev>> ] [ ino>> ] [ type>> ] [ size>> ]
      [ modified>> ] [ created>> ] [ permissions>> ] } cleave 7 narray ;

: register-vnode ( queue event -- )
    1 f 0 f [ kevent-func ] unix-system-call-allow-eintr drop ;

: <vnode-queue> ( -- handle )
    [
        kqueue dup io-error <fd> |dispose
        dup fd>> F_SETFD FD_CLOEXEC [ fcntl ] unix-system-call drop
    ] with-destructors ;

:: watch-vnode ( path info monitor -- watch )
    [
        vnode-watch new-disposable |dispose info >>info :> watch
        ! Non-regular entries are tracked by the parent directory snapshot.
        info type>> { +regular-file+ +directory+ } member? [
            path flags{ O_RDONLY O_NONBLOCK O_NOFOLLOW } 0 open-file
            <fd> init-fd |dispose :> handle
            \ kevent new
                handle handle-fd >>ident
                EVFILT_VNODE >>filter
                flags{ EV_ADD EV_CLEAR } >>flags
                flags{ NOTE_WRITE NOTE_EXTEND NOTE_ATTRIB NOTE_LINK
                       NOTE_RENAME NOTE_DELETE NOTE_REVOKE } >>fflags :> event
            monitor handle>> handle-fd event register-vnode
            watch handle >>handle drop
        ] when
        watch
    ] with-destructors ;

M: vnode-watch dispose* handle>> [ dispose ] when* ;

: vanished-entry? ( error -- ? )
    dup [ unix-system-call-error? ] [ libc-error? ] bi or
    [ errno>> { ENOENT ENOTDIR ELOOP } member? ] [ drop f ] if ;

:: directory-snapshot ( monitor -- entries )
    monitor path>> :> path
    path directory-files [| name |
        [ name path prepend-path link-info name swap 2array ]
        [ dup vanished-entry? [ drop f ] [ rethrow ] if ] recover
    ] map sift >hashtable ;

:: notify-entry ( name change monitor -- )
    name change 1array monitor queue-change ;

:: remove-watch ( name monitor -- )
    name monitor watches>> delete-at* drop dispose ;

:: install-watch ( name info monitor -- )
    [
        name monitor path>> prepend-path info monitor watch-vnode
        name monitor watches>> set-at
    ] [ dup vanished-entry? [ drop ] [ rethrow ] if ] recover ;

:: rescan-directory ( monitor notify? -- )
    monitor directory-snapshot :> entries
    monitor watches>> keys [| name |
        name entries key? [ ] [
            name monitor remove-watch
            notify? [ name +remove-file+ monitor notify-entry ] when
        ] if
    ] each
    entries [| name info |
        name monitor watches>> at :> old
        old [
            old info>> :> previous
            previous ino>> info ino>> = previous dev>> info dev>> = and [
                previous watch-signature info watch-signature = [ ] [
                    old info >>info drop
                    notify? [ name +modify-file+ monitor notify-entry ] when
                ] if
            ] [
                name monitor remove-watch
                name info monitor install-watch
                notify? [
                    name +remove-file+ monitor notify-entry
                    name +add-file+ monitor notify-entry
                ] when
            ] if
        ] [
            name info monitor install-watch
            notify? [ name +add-file+ monitor notify-entry ] when
        ] if
    ] assoc-each ;

:: drain-vnodes ( monitor -- n )
    monitor handle>> handle-fd f 0
    monitor events>> dup length 0 make-timespec
    kevent-func multiplexer-error ;

:: handle-root-event ( event monitor -- )
    event ident>> monitor root>> handle>> handle-fd = [
        event fflags>> flags{ NOTE_DELETE NOTE_REVOKE NOTE_RENAME }
        bitand zero? [ ] [ monitor dispose ] if
    ] when ;

:: process-vnodes ( n monitor -- )
    monitor events>> n head-slice [| event |
        monitor disposed>> [ ] [ event monitor handle-root-event ] if
    ] each
    monitor disposed>> [ ] [
        [ monitor t rescan-directory ] [
            dup vanished-entry? [ drop monitor dispose ] [ rethrow ] if
        ] recover
    ] if ;

:: vnode-loop ( monitor -- )
    monitor disposed>> [ ] [
        monitor drain-vnodes dup zero? [
            drop
            monitor handle>> +input+ wait-for-fd
        ] [
            monitor process-vnodes
        ] if
        monitor vnode-loop
    ] if ;

:: vnode-thread ( monitor -- )
    [ monitor vnode-loop ] [
        monitor disposed>> [ drop ] [ monitor dispose rethrow ] if
    ] recover ;

:: dispose-vnodes ( monitor -- )
    monitor owner>> [ monitor swap remove! drop ] when*
    [
        monitor handle>> ,
        monitor root>> ,
        monitor watches>> [ values % ] when*
    ] { } make sift dispose-each ;

M: freebsd-monitor dispose*
    dup [ dispose-vnodes ] [ call-next-method ] finally ;

:: <vnode-monitor> ( path mailbox -- monitor )
    freebsd-monitors get [ ] [ "Calling <monitor> outside with-monitors" throw ] if
    [
        path absolute-path mailbox freebsd-monitor new-monitor |dispose
            H{ } clone >>watches
            freebsd-monitors get >>owner
            64 \ kevent <c-array> >>events :> monitor
        <vnode-queue> monitor swap >>handle drop
        monitor path>> dup link-info monitor watch-vnode monitor swap >>root drop
        monitor f rescan-directory
        monitor freebsd-monitors get push
        [ monitor vnode-thread ] "FreeBSD vnode monitor" spawn drop
        monitor
    ] with-destructors ;

: freebsd-monitor-constructor ( path recursive? mailbox -- monitor )
    [ absolute-path resolve-symlinks ] 2dip
    swap [ <recursive-monitor> ] [ <vnode-monitor> ] if ;

M: freebsd (monitor) freebsd-monitor-constructor ;

: init-freebsd-monitors ( -- )
    V{ } clone freebsd-monitors set ;

: dispose-freebsd-monitors ( -- )
    freebsd-monitors get clone dispose-each ;

M: freebsd init-monitors init-freebsd-monitors ;
M: freebsd dispose-monitors dispose-freebsd-monitors ;

freebsd set-io-backend
