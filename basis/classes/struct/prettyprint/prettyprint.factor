! (c)Joe Groff bsd license
USING: accessors alien assocs classes classes.struct
combinators kernel math prettyprint.backend prettyprint.custom
prettyprint.sections see.private sequences strings words ;
IN: classes.struct.prettyprint

<PRIVATE

: struct-definer-word ( class -- word )
    struct-slots dup length 2 >=
    [ second offset>> 0 = \ UNION-STRUCT: \ STRUCT: ? ]
    [ drop \ STRUCT: ] if ;

: struct>assoc ( struct -- assoc )
    [ class struct-slots ] [ struct-slot-values ] bi zip ;

: pprint-struct-slot ( slot -- )
    <flow \ { pprint-word
    {
        [ name>> text ]
        [ c-type>> dup string? [ text ] [ pprint* ] if ]
        [ read-only>> [ \ read-only pprint-word ] when ]
        [ initial>> [ \ initial: pprint-word pprint* ] when* ]
    } cleave
    \ } pprint-word block> ;

: pprint-struct ( struct -- )
    [ [ \ S{ ] dip [ class ] [ struct>assoc ] bi \ } (pprint-tuple) ] ?pprint-tuple ;

: pprint-struct-pointer ( struct -- )
    <block
    \ S@ pprint-word
    [ class pprint-word ]
    [ >c-ptr pprint* ] bi
    block> ;

PRIVATE>

M: struct-class see-class*
    <colon dup struct-definer-word pprint-word dup pprint-word
    <block struct-slots [ pprint-struct-slot ] each
    block> pprint-; block> ;

M: struct pprint-delims
    drop \ S{ \ } ;

M: struct >pprint-sequence
    [ class ] [ struct-slot-values ] bi class-slot-sequence ;

M: struct pprint*
    [ pprint-struct ]
    [ pprint-struct-pointer ] pprint-c-object ;
