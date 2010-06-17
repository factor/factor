! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.strings io.encodings.utf8
io.backend.unix kernel math sequences splitting strings
combinators.short-circuit byte-arrays combinators
accessors math.parser fry assocs namespaces continuations
unix.users unix.utilities classes.struct unix ;
IN: unix.groups

QUALIFIED: unix.ffi

QUALIFIED: grouping

TUPLE: group id name passwd members ;

SYMBOL: group-cache

GENERIC: group-struct ( obj -- group/f )

<PRIVATE

: group-members ( group-struct -- seq )
    gr_mem>> utf8 alien>strings ;

: (group-struct) ( id -- group-struct id group-struct byte-array length void* )
    [ \ unix.ffi:group <struct> ] dip over 4096
    [ <byte-array> ] keep f <void*> ;

: check-group-struct ( group-struct ptr -- group-struct/f )
    *void* [ drop f ] unless ;

M: integer group-struct ( id -- group/f )
    (group-struct)
    [ [ unix.ffi:getgrgid_r ] unix-system-call drop ] keep
    check-group-struct ;

M: string group-struct ( string -- group/f )
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
    dup group-cache get [
        ?at [ name>> ] [ number>string ] if
    ] [
        group-struct [ gr_name>> ] [ f ] if*
    ] if*
    [ nip ] [ number>string ] if* ;

: group-id ( string -- id/f )
    group-struct dup [ gr_gid>> ] when ;

ERROR: no-group string ;

: ?group-id ( string -- id )
    dup group-struct [ nip gr_gid>> ] [ no-group ] if* ;

<PRIVATE

: >groups ( byte-array n -- groups )
    [ 4 grouping:group ] dip head-slice [ *uint group-name ] map ;

: (user-groups) ( string -- seq )
    #! first group is -1337, legacy unix code
    -1337 unix.ffi:NGROUPS_MAX [ 4 * <byte-array> ] keep
    <int> [ [ unix.ffi:getgrouplist ] unix-system-call drop ] 2keep
    [ 4 tail-slice ] [ *int 1 - ] bi* >groups ;

PRIVATE>
    
GENERIC: user-groups ( string/id -- seq )

M: string user-groups ( string -- seq )
    (user-groups) ; 

M: integer user-groups ( id -- seq )
    user-name (user-groups) ;
    
: all-groups ( -- seq )
    [ unix.ffi:getgrent dup ] [ group-struct>group ] produce nip ;

: <group-cache> ( -- assoc )
    all-groups [ [ id>> ] keep ] H{ } map>assoc ;

: with-group-cache ( quot -- )
    [ <group-cache> group-cache ] dip with-variable ; inline

: real-group-id ( -- id ) unix.ffi:getgid ; inline

: real-group-name ( -- string ) real-group-id group-name ; inline

: effective-group-id ( -- string ) unix.ffi:getegid ; inline

: effective-group-name ( -- string )
    effective-group-id group-name ; inline

GENERIC: set-real-group ( obj -- )

GENERIC: set-effective-group ( obj -- )

: with-real-group ( string/id quot -- )
    '[ _ set-real-group @ ]
    real-group-id '[ _ set-real-group ] [ ] cleanup ; inline

: with-effective-group ( string/id quot -- )
    '[ _ set-effective-group @ ]
    effective-group-id '[ _ set-effective-group ] [ ] cleanup ; inline

<PRIVATE

: (set-real-group) ( id -- )
    [ unix.ffi:setgid ] unix-system-call drop ; inline

: (set-effective-group) ( id -- )
    [ unix.ffi:setegid ] unix-system-call drop ; inline

PRIVATE>
    
M: integer set-real-group ( id -- )
    (set-real-group) ;

M: string set-real-group ( string -- )
    ?group-id (set-real-group) ;

M: integer set-effective-group ( id -- )    
    (set-effective-group) ;

M: string set-effective-group ( string -- )
    ?group-id (set-effective-group) ;
