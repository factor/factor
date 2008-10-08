! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.strings io.encodings.utf8
io.unix.backend kernel math sequences splitting unix strings
combinators.short-circuit grouping byte-arrays combinators
accessors math.parser fry assocs namespaces continuations
vocabs.loader system ;
IN: unix.users

TUPLE: passwd username password uid gid gecos dir shell ;

HOOK: new-passwd os ( -- passwd )
HOOK: passwd>new-passwd os ( passwd -- new-passwd )

<PRIVATE

M: unix new-passwd ( -- passwd )
    passwd new ;

M: unix passwd>new-passwd ( passwd -- seq )
    [ new-passwd ] dip
    {
        [ passwd-pw_name >>username ]
        [ passwd-pw_passwd >>password ]
        [ passwd-pw_uid >>uid ]
        [ passwd-pw_gid >>gid ]
        [ passwd-pw_gecos >>gecos ]
        [ passwd-pw_dir >>dir ]
        [ passwd-pw_shell >>shell ]
    } cleave ;

: with-pwent ( quot -- )
    [ endpwent ] [ ] cleanup ; inline

PRIVATE>

: all-users ( -- seq )
    [
        [ getpwent dup ] [ passwd>new-passwd ] [ drop ] produce
    ] with-pwent ;

SYMBOL: passwd-cache

: with-passwd-cache ( quot -- )
    all-users [ [ uid>> ] keep ] H{ } map>assoc
    passwd-cache swap with-variable ; inline

GENERIC: user-passwd ( obj -- passwd )

M: integer user-passwd ( id -- passwd/f )
    passwd-cache get
    [ at ] [ getpwuid passwd>new-passwd ] if* ;

M: string user-passwd ( string -- passwd/f )
    getpwnam dup [ passwd>new-passwd ] when ;

: username ( id -- string )
    user-passwd username>> ;

: username-id ( string -- id )
    user-passwd username>> ;

: real-username-id ( -- string )
    getuid ; inline

: real-username ( -- string )
    real-username-id username ; inline

: effective-username-id ( -- string )
    geteuid username ; inline

: effective-username ( -- string )
    effective-username-id username ; inline

GENERIC: set-real-username ( string/id -- )

GENERIC: set-effective-username ( string/id -- )

: with-real-username ( string/id quot -- )
    '[ _ set-real-username @ ]
    real-username-id '[ _ set-real-username ]
    [ ] cleanup ; inline

: with-effective-username ( string/id quot -- )
    '[ _ set-effective-username @ ]
    effective-username-id '[ _ set-effective-username ]
    [ ] cleanup ; inline

<PRIVATE

: (set-real-username) ( id -- )
    setuid io-error ; inline

: (set-effective-username) ( id -- )
    seteuid io-error ; inline

PRIVATE>

M: string set-real-username ( string -- )
    username-id (set-real-username) ;

M: integer set-real-username ( id -- )
    (set-real-username) ;

M: integer set-effective-username ( id -- )
    (set-effective-username) ; 

M: string set-effective-username ( string -- )
    username-id (set-effective-username) ;

os {
    { [ dup bsd? ] [ drop "unix.users.bsd" require ] }
    { [ dup linux? ] [ drop ] }
} cond
