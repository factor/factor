! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors alien.c-types alien.data alien.utilities assocs
byte-arrays classes.struct combinators continuations grouping
io.encodings.utf8 kernel math math.parser namespaces sequences
strings unix unix.ffi unix.users ;

IN: unix.groups

TUPLE: group id name passwd members ;

SYMBOL: group-cache

GENERIC: group-struct ( obj -- group/f )

<PRIVATE

: group-members ( group-struct -- seq )
    gr_mem>> utf8 alien>strings ;

: (group-struct) ( id -- group-struct id group-struct byte-array length void* )
    [ unix.ffi:group new ] dip over 4096
    [ <byte-array> ] keep f void* <ref> ;

: check-group-struct ( group-struct ptr -- group-struct/f )
    void* deref [ drop f ] unless ;

M: integer group-struct
    (group-struct)
    [ [ unix.ffi:getgrgid_r ] unix-system-call drop ] keep
    check-group-struct ;

M: string group-struct
    (group-struct)
    [ [ unix.ffi:getgrnam_r ] unix-system-call drop ] keep
    check-group-struct ;

: group-struct>group ( group-struct -- group )
    [ \ group new ] dip
    {
        [ gr_name>> >>name ]
        [ gr_passwd>> >>passwd ]
        [ gr_gid>> >>id ]
        [ group-members >>members ]
    } cleave ;

PRIVATE>

: group-name ( id -- string )
    [
        group-cache get [
            ?at [ name>> ] [ number>string ] if
        ] [
            group-struct [ gr_name>> ] [ f ] if*
        ] if*
    ] [ number>string ] ?unless ;

: group-id ( string -- id/f )
    group-struct dup [ gr_gid>> ] when ;

ERROR: no-group string ;

: ?group-id ( string -- id )
    dup group-struct [ nip gr_gid>> ] [ no-group ] if* ;

<PRIVATE

: >groups ( byte-array n -- groups )
    [ 4 grouping:group ] dip head-slice [ uint deref group-name ] map ;

: (user-groups) ( string -- seq )
    dup user-passwd [
        gid>> 64 [ 4 * <byte-array> ] keep
        int <ref> [ [ unix.ffi:getgrouplist ] unix-system-call drop ] 2keep
        int deref >groups
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
    [ unix.ffi:getgrent dup ] [ group-struct>group ] produce nip
    endgrent ;

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
