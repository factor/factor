! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sets namespaces make sequences parser
lexer combinators words classes.parser classes.tuple arrays
slots math assocs parser.notes classes.algebra ;
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
    [ scan , \ } parse-until % ] { } make ;

: parse-slot-name-delim ( end-delim string/f -- ? )
    #! This isn't meant to enforce any kind of policy, just
    #! to check for mistakes of this form:
    #!
    #! TUPLE: blahblah foo bing
    #!
    #! : ...
    {
        { [ dup not ] [ unexpected-eof ] }
        { [ dup { ":" "(" "<" "\"" "!" } member? ] [ invalid-slot-name ] }
        { [ 2dup = ] [ drop f ] }
        [ dup "{" = [ drop parse-long-slot-name ] when , t ]
    } cond nip ;

: parse-tuple-slots-delim ( end-delim -- )
    dup scan parse-slot-name-delim [ parse-tuple-slots-delim ] [ drop ] if ;

: parse-slot-name ( string/f -- ? )
    ";" swap parse-slot-name-delim ;

: parse-tuple-slots ( -- )
    ";" parse-tuple-slots-delim ;

ERROR: bad-inheritance class superclass ;

: check-inheritance ( class1 class2 -- class1 class2 )
    2dup swap class<= [ bad-inheritance ] when ;

: parse-tuple-definition ( -- class superclass slots )
    CREATE-CLASS
    scan 2dup = [ ] when {
        { ";" [ tuple f ] }
        { "<" [
            scan-word check-inheritance [ parse-tuple-slots ] { } make
        ] }
        [ tuple swap [ parse-slot-name [ parse-tuple-slots ] when ] { } make ]
    } case
    dup check-duplicate-slots
    3dup check-slot-shadowing ;

ERROR: bad-literal-tuple ;

: parse-slot-value ( -- )
    scan scan-object 2array , scan {
        { f [ \ } unexpected-eof ] }
        { "}" [ ] }
        [ bad-literal-tuple ]
    } case ;

: (parse-slot-values) ( -- )
    parse-slot-value
    scan {
        { f [ \ } unexpected-eof ] }
        { "{" [ (parse-slot-values) ] }
        { "}" [ ] }
        [ bad-literal-tuple ]
    } case ;

: parse-slot-values ( -- values )
    [ (parse-slot-values) ] { } make ;

GENERIC# boa>object 1 ( class slots -- tuple )

M: tuple-class boa>object
    swap prefix >tuple ;

ERROR: bad-slot-name class slot ;

: check-slot-exists ( class initials slot-spec/f index/f name -- class initials slot-spec index )
    over [ drop ] [ nip nip nip bad-slot-name ] if ;

: slot-named-checked ( class initials name slots -- class initials slot-spec )
    over [ slot-named* ] dip check-slot-exists drop ;

: assoc>object ( class slots values -- tuple )
    [ [ [ initial>> ] map ] keep ] dip
    swap [ [ slot-named-checked ] curry dip ] curry assoc-map
    [ dup <enum> ] dip update boa>object ;

: parse-tuple-literal-slots ( class slots -- tuple )
    scan {
        { f [ unexpected-eof ] }
        { "f" [ drop \ } parse-until boa>object ] }
        { "{" [ parse-slot-values assoc>object ] }
        { "}" [ drop new ] }
        [ bad-literal-tuple ]
    } case ;

: parse-tuple-literal ( -- tuple )
    scan-word dup all-slots parse-tuple-literal-slots ;
