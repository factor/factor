! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors alien.c-types alien.data alien.utilities assocs
byte-arrays classes.struct combinators continuations destructors grouping
io.encodings.utf8 kernel libc locals math math.parser namespaces sequences
strings unix unix.ffi unix.types unix.users ;

IN: unix.groups

TUPLE: group id name passwd members ;

SYMBOL: group-cache

GENERIC: group-struct ( obj -- group/f )

<PRIVATE

: group-members ( group-struct -- seq )
    gr_mem>> utf8 alien>strings ;

: group-struct>group ( group-struct -- group )
    [ \ group new ] dip
    {
        [ gr_name>> >>name ]
        [ gr_passwd>> >>passwd ]
        [ gr_gid>> >>id ]
        [ group-members >>members ]
    } cleave ;

:: lookup-group ( key quot: ( key entry buffer size result -- error ) -- group/f )
    4096 :> size!
    f :> found!
    [
        [
            unix.ffi:group new :> entry
            size malloc &free :> buffer
            f void* <ref> :> result
            key entry buffer size result quot call :> error
            error zero? [
                result void* deref [ entry group-struct>group ] [ f ] if found!
            ] when
            error
        ] with-destructors {
            { 0 [ f ] }
            { EINTR [ t ] }
            { ERANGE [ size 2 * size! t ] }
            [ (throw-errno) ]
        } case
    ] loop found ; inline

M: integer group-struct [ unix.ffi:getgrgid_r ] lookup-group ;

M: string group-struct [ unix.ffi:getgrnam_r ] lookup-group ;

PRIVATE>

: group-name ( id -- string )
    [
        group-cache get [
            ?at [ name>> ] [ number>string ] if
        ] [
            group-struct [ name>> ] [ f ] if*
        ] if*
    ] [ number>string ] ?unless ;

: group-id ( string -- id/f )
    group-struct dup [ id>> ] when ;

ERROR: no-group string ;

: ?group-id ( string -- id )
    dup group-struct [ nip id>> ] [ no-group ] if* ;

<PRIVATE

: >groups ( byte-array n -- groups )
    [ gid_t heap-size grouping:group ] dip head-slice
    [ gid_t deref group-name ] map ;

ERROR: group-list-error name errno ;

:: group-list ( name gid -- groups )
    64 :> capacity!
    f :> groups!
    [
        capacity gid_t heap-size * <byte-array> :> buffer
        capacity int <ref> :> count
        clear-errno
        name gid buffer count unix.ffi:getgrouplist :> status
        errno :> error
        count int deref :> required
        status 0 < [
            required capacity > [ required capacity! t ] [
                error EINTR = [ t ] [ name error group-list-error ] if
            ] if
        ] [
            buffer required >groups groups! f
        ] if
    ] loop groups ;

: (user-groups) ( string -- seq )
    dup user-passwd [
        gid>> group-list
    ] [
        drop { }
    ] if* ;

PRIVATE>

GENERIC: user-groups ( string/id -- seq )

M: string user-groups
    (user-groups) ;

M: integer user-groups
    user-name (user-groups) ;

: all-groups ( -- seq )
    [ [ unix.ffi:getgrent dup ] [ group-struct>group ] produce nip ]
    [ endgrent ] finally ;

: all-group-names ( -- seq )
    all-groups [ name>> ] map ;

: <group-cache> ( -- assoc )
    all-groups [ [ id>> ] keep ] H{ } map>assoc ;

: with-group-cache ( quot -- )
    [ <group-cache> group-cache ] dip with-variable ; inline

: real-group-id ( -- id ) unix.ffi:getgid ; inline

: real-group-name ( -- string ) real-group-id group-name ; inline

: effective-group-id ( -- string ) unix.ffi:getegid ; inline

: effective-group-name ( -- string )
    effective-group-id group-name ; inline

: group-exists? ( name/id -- ? ) group-id >boolean ;

GENERIC: set-real-group ( obj -- )

GENERIC: set-effective-group ( obj -- )

: (with-real-group) ( string/id quot -- )
    '[ _ set-real-group @ ]
    real-group-id '[ _ set-real-group ] finally ; inline

: with-real-group ( string/id/f quot -- )
    over [ (with-real-group) ] [ nip call ] if ; inline

: (with-effective-group) ( string/id quot -- )
    '[ _ set-effective-group @ ]
    effective-group-id '[ _ set-effective-group ] finally ; inline

: with-effective-group ( string/id/f quot -- )
    over [ (with-effective-group) ] [ nip call ] if ; inline

<PRIVATE

: (set-real-group) ( id -- )
    [ unix.ffi:setgid ] unix-system-call drop ; inline

: (set-effective-group) ( id -- )
    [ unix.ffi:setegid ] unix-system-call drop ; inline

PRIVATE>

M: integer set-real-group
    (set-real-group) ;

M: string set-real-group
    ?group-id (set-real-group) ;

M: integer set-effective-group
    (set-effective-group) ;

M: string set-effective-group
    ?group-id (set-effective-group) ;
