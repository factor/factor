! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs hashtables errors kernel sequences generic words
arrays ;
IN: structure

! Some generic words for treating all objects as uniform
! key->value mappings. Don't rely on these, they will change
! a lot as the structure editor is fleshed out, and they're
! only for use by tools anyway.

GENERIC: field ( key obj -- value )

GENERIC: set-field ( value key obj -- )

GENERIC: rename-field ( newkey key obj -- )

GENERIC: delete-field ( key obj -- )

GENERIC: delete-field ( key obj -- )

GENERIC: fields ( obj -- seq )

M: hashtable field at* [ "No such key" throw ] unless ;

M: sequence field nth ;

M: object field
    tuck class slot-of-reader slot-spec-reader execute ;

M: hashtable set-field set-at ;

M: sequence set-field set-nth ;

M: object set-field
    tuck class slot-of-reader slot-spec-writer
    [ execute ] [ "Immutable slot" throw ] if* ;

M: hashtable rename-field
    [ delete-at* swap ] keep set-at ;

M: object rename-field
    [ field swap ] 2keep [ delete-field ] keep set-field ;

M: hashtable delete-field delete-at ;

M: sequence delete-field delete-nth ;

M: object delete-field f -rot set-field ;

M: hashtable fields >alist [ first ] map ;

M: sequence fields length ;

: object-fields
    class "slots" word-prop [ slot-spec-reader ] map ;

M: object fields object-fields ;

M: tuple fields
    dup object-fields swap delegate [ 1 tail-slice ] unless ;

TUPLE: key-path seq ;

GENERIC: field-path ( path -- obj )

M: array field-path unclip [ swap field ] reduce ;

M: key-path field-path key-path-seq peek ;

: (set-field-path) [ 1 head* field-path ] keep peek swap ;

GENERIC: set-field-path ( value path -- )

M: array set-field-path
    (set-field-path) set-field ;

M: key-path set-field-path
    key-path-seq (set-field-path) rename-field ;

GENERIC: delete-field-path ( path -- )

M: array delete-field-path (set-field-path) delete-field ;

M: key-path delete-field-path key-path-seq delete-field-path ;
