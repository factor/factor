! Copyright (C) 2005, 2010 Slava Pestov.
! Copyright (C) 2008 Eduardo Cavazos.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.syntax byte-arrays
combinators.short-circuit combinators.smart generalizations kernel
libc math sequences sequences.generalizations strings system
unix.ffi vocabs.loader ;
IN: unix

ERROR: unix-system-call-error args errno message word ;

: unix-call-failed? ( ret -- ? )
    {
        [ { [ integer? ] [ 0 < ] } 1&& ]
        [ not ]
    } 1|| ;

MACRO:: unix-system-call ( quot -- quot )
    quot inputs :> n
    quot first :> word
    0 :> ret!
    f :> failed!
    [
        [
            n ndup quot call ret!
            ret {
                [ unix-call-failed? dup failed! ]
                [ drop errno EINTR = ]
            } 1&&
        ] loop
        failed [
            n narray
            errno dup strerror
            word unix-system-call-error
        ] [
            n ndrop
            ret
        ] if
    ] ;

MACRO:: unix-system-call-allow-eintr ( quot -- quot )
    quot inputs :> n
    quot first :> word
    0 :> ret!
    [
        n ndup quot call ret!
        ret unix-call-failed? [
            ! Bug #908
            ! Allow EINTR for close(2)
            errno EINTR = [
                n narray
                errno dup strerror
                word unix-system-call-error
            ] unless
        ] [
            n ndrop
            ret
        ] if
    ] ;

HOOK: open-file os ( path flags mode -- fd )

: close-file ( fd -- ) [ close ] unix-system-call-allow-eintr drop ;

FUNCTION: int _exit ( int status )

M: unix open-file [ open ] unix-system-call ;

: make-fifo ( path mode -- ) [ mkfifo ] unix-system-call drop ;

: touch ( filename -- ) f [ utime ] unix-system-call drop ;

: change-file-times ( filename access modification -- )
    utimbuf new
        swap >>modtime
        swap >>actime
        [ utime ] unix-system-call drop ;

: (read-symbolic-link) ( path bufsiz -- path' )
    dup <byte-array> 3dup swap [ readlink ] unix-system-call
    pick dupd < [ head >string 2nip ] [
        2nip 2 * (read-symbolic-link)
    ] if ;

: read-symbolic-link ( path -- path )
    4096 (read-symbolic-link) ;

: unlink-file ( path -- ) [ unlink ] unix-system-call drop ;

{ "unix" "debugger" } "unix.debugger" require-when
