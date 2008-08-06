! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel assocs ;
IN: persistent.assocs

GENERIC: new-at ( value key phash -- phash' )

M: assoc new-at clone [ set-at ] keep ;

GENERIC: pluck-at ( key phash -- phash' )

M: assoc pluck-at clone [ delete-at ] keep ;
