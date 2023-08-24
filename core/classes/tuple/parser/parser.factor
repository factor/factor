! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes.parser classes.tuple
combinators kernel lexer make parser parser.notes sequences sets
slots ;
IN: classes.tuple.parser

: slot-names ( slots -- seq )
    [ dup array? [ first ] when ] map ;

: shadowed-slots ( superclass slots -- shadowed )
    [ all-slots [ name>> ] map ] [ slot-names ] bi* intersect ;

: check-slot-shadowing ( class superclass slots -- )
    shadowed-slots [
        [
            "Definition of slot ``" %
            %
            "'' in class ``" %
            name>> %
            "'' shadows a superclass slot" %
        ] "" make note.
    ] with each ;

ERROR: duplicate-slot-names names ;

: check-duplicate-slots ( slots -- )
    slot-names duplicates
    [ duplicate-slot-names ] unless-empty ;

ERROR: invalid-slot-name name ;

: parse-long-slot-name ( -- spec )
    [ scan-token , \ } parse-until % ] { } make ;

: parse-slot-name-delim ( end-delim string/f -- ? )
    ! Check for mistakes of this form:
    !
    ! TUPLE: blahblah foo bing
    !
    ! : ...
    {
        { [ dup { ":" "(" "<" "\"" "!" } member? ] [ invalid-slot-name ] }
        { [ 2dup = ] [ drop f ] }
        [ dup "{" = [ drop parse-long-slot-name ] when , t ]
    } cond nip ;

: parse-tuple-slots-delim ( end-delim -- )
    dup scan-token parse-slot-name-delim [ parse-tuple-slots-delim ] [ drop ] if ;

: parse-slot-name ( string/f -- ? )
    ";" swap parse-slot-name-delim ;

: parse-tuple-slots ( -- )
    ";" parse-tuple-slots-delim ;

: (parse-tuple-definition) ( word -- class superclass slots )
    scan-token {
        { ";" [ tuple f ] }
        { "<" [ scan-word [ parse-tuple-slots ] { } make ] }
        [ tuple swap [ parse-slot-name [ parse-tuple-slots ] when ] { } make ]
    } case
    dup check-duplicate-slots
    3dup check-slot-shadowing ;

: parse-tuple-definition ( -- class superclass slots )
    scan-new-class (parse-tuple-definition) ;


ERROR: bad-literal-tuple ;

ERROR: bad-slot-name class slot ;

: check-slot-name ( class slots name -- name )
    2dup swap slot-named [ 2nip ] [ nip bad-slot-name ] if ;

: parse-slot-value ( class slots -- )
    scan-token check-slot-name scan-object 2array , scan-token {
        { "}" [ ] }
        [ bad-literal-tuple ]
    } case ;

: (parse-slot-values) ( class slots -- )
    2dup parse-slot-value
    scan-token {
        { "{" [ (parse-slot-values) ] }
        { "}" [ 2drop ] }
        [ 2nip bad-literal-tuple ]
    } case ;

: parse-slot-values ( class slots -- values )
    [ (parse-slot-values) ] { } make ;

GENERIC#: boa>object 1 ( class slots -- tuple )

M: tuple-class boa>object
    swap slots>tuple ;

: check-slot-exists ( class initials slot-spec/f index/f name -- class initials slot-spec index )
    over [ drop ] [ 3nip bad-slot-name ] if ;

: slot-named-checked ( class initials name slots -- class initials slot-spec )
    over [ slot-named* ] dip check-slot-exists drop ;

: assoc>object ( class slots values -- tuple )
    [ [ [ initial>> ] map <enumerated> ] keep ] dip
    swap [ [ slot-named-checked ] curry dip ] curry assoc-map
    assoc-union! seq>> boa>object ;

: parse-tuple-literal-slots ( class slots -- tuple )
    scan-token {
        { "f" [ drop \ } parse-until boa>object ] }
        { "{" [ 2dup parse-slot-values assoc>object ] }
        { "}" [ drop new ] }
        [ bad-literal-tuple ]
    } case ;

: parse-tuple-literal ( -- tuple )
    scan-word dup all-slots parse-tuple-literal-slots ;
