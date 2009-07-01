! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences assocs fry ;
IN: histogram

<PRIVATE

: (sequence>assoc) ( seq quot assoc -- assoc )
    [ swap curry each ] keep ; inline

PRIVATE>

: sequence>assoc* ( assoc seq quot: ( obj assoc -- ) -- assoc )
    rot (sequence>assoc) ; inline

: sequence>assoc ( seq quot: ( obj assoc -- ) exemplar -- assoc )
    clone (sequence>assoc) ; inline

: sequence>hashtable ( seq quot: ( obj hashtable -- ) -- hashtable )
    H{ } sequence>assoc ; inline

: histogram* ( hashtable seq -- hashtable )
    [ inc-at ] sequence>assoc* ;

: histogram ( seq -- hashtable )
    [ inc-at ] sequence>hashtable ;

: collect-values ( seq quot: ( obj hashtable -- ) -- hash )
    '[ [ dup @ ] dip push-at ] sequence>hashtable ; inline
