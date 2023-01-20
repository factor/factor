! Copyright (C) 2009 Bruno Deferrari
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel tokyo.alien.tcrdb tokyo.assoc-functor ;
IN: tokyo.remotedb

<< "tcrdb" "remotedb" define-tokyo-assoc-api >>

: <tokyo-remotedb> ( host port -- tokyo-remotedb )
    [ tcrdbnew dup ] 2dip tcrdbopen drop
    tokyo-remotedb new [ handle<< ] keep ;
