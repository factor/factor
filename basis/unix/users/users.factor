! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.strings assocs
byte-arrays classes.struct combinators combinators.short-circuit
continuations fry grouping io.encodings.utf8 kernel math
math.parser namespaces sequences splitting strings system unix
unix.ffi vocabs ;
QUALIFIED: unix.ffi
IN: unix.users

TUPLE: passwd user-name password uid gid gecos dir shell ;

HOOK: new-passwd os ( -- passwd )
HOOK: passwd>new-passwd os ( passwd -- new-passwd )

<PRIVATE

M: unix new-passwd ( -- passwd )
    passwd new ;

M: unix passwd>new-passwd ( passwd -- seq )
    [ new-passwd ] dip
    {
        [ pw_name>> >>user-name ]
        [ pw_passwd>> >>password ]
        [ pw_uid>> >>uid ]
        [ pw_gid>> >>gid ]
        [ pw_gecos>> >>gecos ]
        [ pw_dir>> >>dir ]
        [ pw_shell>> >>shell ]
    } cleave ;

: with-pwent ( quot -- )
    setpwent
    [ unix.ffi:endpwent ] [ ] cleanup ; inline

PRIVATE>

: all-users ( -- seq )
    [
        [ unix.ffi:getpwent dup ] [ passwd>new-passwd ] produce nip
    ] with-pwent ;

: all-user-names ( -- seq )
    all-users [ user-name>> ] map ;

SYMBOL: user-cache

: <user-cache> ( -- assoc )
    all-users [ [ uid>> ] keep ] H{ } map>assoc ;

: with-user-cache ( quot -- )
    [ <user-cache> user-cache ] dip with-variable ; inline

GENERIC: user-passwd ( obj -- passwd/f )

M: integer user-passwd ( id -- passwd/f )
    user-cache get
    [ at ] [ unix.ffi:getpwuid [ passwd>new-passwd ] [ f ] if* ] if* ;

M: string user-passwd ( string -- passwd/f )
    unix.ffi:getpwnam dup [ passwd>new-passwd ] when ;

: user-name ( id -- string )
    dup user-passwd
    [ nip user-name>> ] [ number>string ] if* ;

: user-id ( string -- id/f )
    user-passwd dup [ uid>> ] when ;

ERROR: no-user string ;

: ?user-id ( string -- id/f )
    dup user-passwd [ nip uid>> ] [ no-user ] if* ;

: real-user-id ( -- id )
    unix.ffi:getuid ; inline

: real-user-name ( -- string )
    real-user-id user-name ; inline

: effective-user-id ( -- id )
    unix.ffi:geteuid ; inline

: effective-user-name ( -- string )
    effective-user-id user-name ; inline

: user-exists? ( name/id -- ? ) user-id >boolean ;

GENERIC: set-real-user ( string/id -- )

GENERIC: set-effective-user ( string/id -- )

: (with-real-user) ( string/id quot -- )
    '[ _ set-real-user @ ]
    real-user-id '[ _ set-real-user ]
    [ ] cleanup ; inline

: with-real-user ( string/id/f quot -- )
    over [ (with-real-user) ] [ nip call ] if ; inline

: (with-effective-user) ( string/id quot -- )
    '[ _ set-effective-user @ ]
    effective-user-id '[ _ set-effective-user ]
    [ ] cleanup ; inline

: with-effective-user ( string/id/f quot -- )
    over [ (with-effective-user) ] [ nip call ] if ; inline

<PRIVATE

: (set-real-user) ( id -- )
    [ unix.ffi:setuid ] unix-system-call drop ; inline

: (set-effective-user) ( id -- )
    [ unix.ffi:seteuid ] unix-system-call drop ; inline

PRIVATE>

M: integer set-real-user ( id -- )
    (set-real-user) ;

M: string set-real-user ( string -- )
    ?user-id (set-real-user) ;

M: integer set-effective-user ( id -- )
    (set-effective-user) ;

M: string set-effective-user ( string -- )
    ?user-id (set-effective-user) ;

ERROR: no-such-user obj ;

: user-home ( name/uid -- path )
    dup user-passwd [ nip dir>> ] [ no-such-user ] if* ;

os macosx? [ "unix.users.macosx" require ] when
