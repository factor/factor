! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.strings io.encodings.utf8
io.backend.unix kernel math sequences splitting unix strings
combinators.short-circuit byte-arrays combinators
accessors math.parser fry assocs namespaces continuations
unix.users unix.utilities ;
IN: unix.groups

QUALIFIED: grouping

TUPLE: group id name passwd members ;

SYMBOL: group-cache

GENERIC: group-struct ( obj -- group/f )

<PRIVATE

: group-members ( group-struct -- seq )
    group-gr_mem utf8 alien>strings ;

: (group-struct) ( id -- group-struct id group-struct byte-array length void* )
    "group" <c-object> tuck 4096
    [ <byte-array> ] keep f <void*> ;

: check-group-struct ( group-struct ptr -- group-struct/f )
    *void* [ drop f ] unless ;

M: integer group-struct ( id -- group/f )
    (group-struct) [ getgrgid_r io-error ] keep check-group-struct ;

M: string group-struct ( string -- group/f )
    (group-struct) [ getgrnam_r io-error ] keep check-group-struct ;

: group-struct>group ( group-struct -- group )
    [ \ group new ] dip
    {
        [ group-gr_name >>name ]
        [ group-gr_passwd >>passwd ]
        [ group-gr_gid >>id ]
        [ group-members >>members ]
    } cleave ;

PRIVATE>

: group-name ( id -- string )
    dup group-cache get [
        ?at [ name>> ] [ number>string ] if
    ] [
        group-struct [ group-gr_name ] [ f ] if*
    ] if*
    [ nip ] [ number>string ] if* ;

: group-id ( string -- id/f )
    group-struct [ group-gr_gid ] [ f ] if* ;

<PRIVATE

: >groups ( byte-array n -- groups )
    [ 4 grouping:group ] dip head-slice [ *uint group-name ] map ;

: (user-groups) ( string -- seq )
    #! first group is -1337, legacy unix code
    -1337 NGROUPS_MAX [ 4 * <byte-array> ] keep
    <int> [ getgrouplist io-error ] 2keep
    [ 4 tail-slice ] [ *int 1- ] bi* >groups ;

PRIVATE>
    
GENERIC: user-groups ( string/id -- seq )

M: string user-groups ( string -- seq )
    (user-groups) ; 

M: integer user-groups ( id -- seq )
    user-name (user-groups) ;
    
: all-groups ( -- seq )
    [ getgrent dup ] [ group-struct>group ] produce nip ;

: <group-cache> ( -- assoc )
    all-groups [ [ id>> ] keep ] H{ } map>assoc ;

: with-group-cache ( quot -- )
    [ <group-cache> group-cache ] dip with-variable ; inline

: real-group-id ( -- id )
    getgid ; inline

: real-group-name ( -- string )
    real-group-id group-name ; inline

: effective-group-id ( -- string )
    getegid ; inline

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
    setgid io-error ; inline

: (set-effective-group) ( id -- )
    setegid io-error ; inline

PRIVATE>
    
M: string set-real-group ( string -- )
    group-id (set-real-group) ;

M: integer set-real-group ( id -- )
    (set-real-group) ;

M: integer set-effective-group ( id -- )    
    (set-effective-group) ;

M: string set-effective-group ( string -- )
    group-id (set-effective-group) ;
