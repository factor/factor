! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes.mixin classes.parser
classes.tuple classes.tuple.parser combinators kernel lexer make
parser sequences sets strings words ;
IN: roles

ERROR: role-slot-overlap class slots ;
ERROR: multiple-inheritance-attempted classes ;

PREDICATE: role < mixin-class
    "role-slots" word-prop >boolean ;

: parse-role-definition ( -- class superroles slots )
    scan-new-class scan-token {
        { ";" [ { } { } ] }
        { "<" [ scan-word 1array [ parse-tuple-slots ] { } make ] }
        { "<{" [ \ } parse-until >array [ parse-tuple-slots ] { } make ] }
        [ { } swap [ parse-slot-name [ parse-tuple-slots ] when ] { } make ]
    } case ;

: slot-name ( name/array -- name )
    dup string? [ first ] unless ;

: slot-names ( array -- names )
    [ slot-name ] map ;

: role-slots ( role -- slots )
    [ "superroles" word-prop [ role-slots ] map concat ]
    [ "role-slots" word-prop ] bi append ;

: role-or-tuple-slot-names ( role-or-tuple -- names )
    dup role?
    [ role-slots slot-names ]
    [ all-slots [ name>> ] map ] if ;

: check-for-slot-overlap ( class roles-and-superclass slots -- )
    [ [ role-or-tuple-slot-names ] map concat ] [ slot-names ] bi* append
    duplicates dup empty? [ 2drop ] [ role-slot-overlap ] if ;

: roles>slots ( roles-and-superclass slots -- superclass slots' )
    [
        [ role? ] partition
        dup length {
            { 0 [ drop tuple ] }
            { 1 [ first ] }
            [ drop multiple-inheritance-attempted ]
        } case
        swap [ role-slots ] map concat
    ] dip append ;

: add-to-roles ( class roles -- )
    [ add-mixin-instance ] with each ;

: (define-role) ( class superroles slots -- )
    [ "superroles" set-word-prop ] [ "role-slots" set-word-prop ] bi-curry*
    [ define-mixin-class ] tri ;

: define-role ( class superroles slots -- )
    [ check-for-slot-overlap ] [ (define-role) ] [ drop add-to-roles ] 3tri ;

: define-tuple-class-with-roles ( class roles-and-superclass slots -- )
    [ check-for-slot-overlap ]
    [ roles>slots define-tuple-class ]
    [ drop [ role? ] filter add-to-roles ] 3tri ;

SYNTAX: ROLE: parse-role-definition define-role ;
SYNTAX: ROLE-TUPLE: parse-role-definition define-tuple-class-with-roles ;
