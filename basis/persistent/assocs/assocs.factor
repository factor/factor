! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel assocs ;
IN: persistent.assocs

GENERIC: new-at ( value key assoc -- assoc' )

M: assoc new-at clone [ set-at ] keep ;

GENERIC: pluck-at ( key assoc -- assoc' )

M: assoc pluck-at clone [ delete-at ] keep ;

: changed-at ( key assoc quot -- assoc' )
    [ [ at ] dip call ] [ drop new-at ] 3bi ; inline

: conjoined ( key assoc -- assoc' )
    dupd new-at ;
