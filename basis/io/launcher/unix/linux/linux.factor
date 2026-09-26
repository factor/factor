! Copyright (C) 2026 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.libraries alien.syntax assocs combinators continuations
destructors io.backend.unix io.backend.unix.multiplexers
io.backend.unix.multiplexers.epoll io.launcher io.launcher.private
io.launcher.unix kernel libc locals math math.bitwise namespaces system
unix unix.linux.epoll unix.types ;
IN: io.launcher.unix.linux

LIBRARY: libc
FUNCTION: int pidfd_open ( pid_t pid, uint flags )

TUPLE: process-pidfd < disposable fd mx ;

M: process-pidfd dispose*
    [ fd>> ] [ mx>> ] bi
    [ callbacks>> delete-at ]
    [ EPOLLIN do-epoll-del ]
    [ drop close-file ] 2tri ;

M:: linux (monitor-process) ( process -- monitor/f )
    mx get-global :> multiplexer
    multiplexer epoll-mx? [
        process handle>> 0 pidfd_open dup io-error :> fd
        ! Registration must succeed before polling can be disabled.
        [
            fd multiplexer EPOLL_CTL_ADD EPOLLIN EPOLLONESHOT bitor do-epoll-ctl
        ] [ fd close-file rethrow ] recover
        [ wake-process-waiter ] fd multiplexer callbacks>> set-at
        process-pidfd new-disposable fd >>fd multiplexer >>mx
    ] [ f ] if ;

M: linux (process-notifications?)
    "pidfd_open" "libc" dlsym?
    [ process-monitors? ] [ f ] if ;
