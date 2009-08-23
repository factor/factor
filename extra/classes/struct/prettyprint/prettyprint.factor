! (c)Joe Groff bsd license
USING: accessors assocs classes classes.struct kernel math
prettyprint.backend prettyprint.custom prettyprint.sections
see.private sequences words ;
IN: classes.struct.prettyprint

<PRIVATE

: struct-definer-word ( class -- word )
    struct-slots dup length 2 >=
    [ second offset>> 0 = \ UNION-STRUCT: \ STRUCT: ? ]
    [ drop \ STRUCT: ] if ;

: struct>assoc ( struct -- assoc )
    [ class struct-slots ] [ struct-slot-values ] bi zip filter-tuple-assoc ;

PRIVATE>

M: struct-class see-class*
    <colon dup struct-definer-word pprint-word dup pprint-word
    <block struct-slots [ pprint-slot ] each
    block> pprint-; block> ;

M: struct pprint-delims
    drop \ S{ \ } ;

M: struct >pprint-sequence
    [ class ] [ struct-slot-values ] bi class-slot-sequence ;

M: struct pprint*
    [ [ \ S{ ] dip [ class ] [ struct>assoc ] bi \ } (pprint-tuple) ] ?pprint-tuple ;
