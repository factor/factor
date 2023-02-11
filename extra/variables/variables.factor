! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators definitions kernel
locals.types namespaces parser quotations see sequences slots
words ;
FROM: kernel.private => declare ;
FROM: help.markup.private => link-effect? ;
IN: variables

PREDICATE: variable < word
    "variable-setter" word-prop >boolean ;

GENERIC: variable-setter ( word -- word' )

M: variable variable-setter "variable-setter" word-prop ;
M: local-reader variable-setter "local-writer" word-prop ;

SYNTAX: set:
    scan-object variable-setter suffix! ;

: [variable-getter] ( variable -- quot )
    '[ _ get ] ;
: [variable-setter] ( variable -- quot )
    '[ _ set ] ;

: (define-variable) ( word getter setter -- )
    [ ( -- value ) define-inline ]
    [
        [
            [ name>> "set: " prepend <uninterned-word> ]
            [ over "variable-setter" set-word-prop ] bi
        ] dip ( value -- ) define-inline
    ] bi-curry* bi ;

: define-variable ( word -- )
    dup [ [variable-getter] ] [ [variable-setter] ] bi (define-variable) ;

SYNTAX: VAR:
    scan-new-word define-variable ;

M: variable definer drop \ VAR: f ;
M: variable definition drop f ;
M: variable link-effect? drop f ;
M: variable print-stack-effect? drop f ;

PREDICATE: typed-variable < variable
    "variable-type" word-prop >boolean ;

: [typed-getter] ( quot type -- quot )
    1array '[ @ _ declare ] ;
: [typed-setter] ( quot type -- quot )
    instance-check-quot prepose ;

: define-typed-variable ( word type -- )
    dupd {
        [ [ [variable-getter] ] dip [typed-getter] ]
        [ [ [variable-setter] ] dip [typed-setter] ]
        [ "variable-type" set-word-prop ]
        [ initial-value drop swap set-global ]
    } 2cleave (define-variable) ;

SYNTAX: TYPED-VAR:
    scan-new-word scan-object define-typed-variable ;

M: typed-variable definer drop \ TYPED-VAR: f ;
M: typed-variable definition "variable-type" word-prop 1quotation ;

TUPLE: global-box value ;

PREDICATE: global-variable < variable
    def>> first global-box? ;

: [global-getter] ( box -- quot )
    '[ _ value>> ] ;
: [global-setter] ( box -- quot )
    '[ _ value<< ] ;

: define-global ( word -- )
    global-box new [ [global-getter] ] [ [global-setter] ] bi (define-variable) ;

SYNTAX: GLOBAL:
    scan-new-word define-global ;

M: global-variable definer drop \ GLOBAL: f ;

INTERSECTION: typed-global-variable
    global-variable typed-variable ;

: define-typed-global ( word type -- )
    2dup "variable-type" set-word-prop
    dup initial-value drop global-box boa swap
    [ [ [global-getter] ] dip [typed-getter] ]
    [ [ [global-setter] ] dip [typed-setter] ] 2bi (define-variable) ;

SYNTAX: TYPED-GLOBAL:
    scan-new-word scan-object define-typed-global ;

M: typed-global-variable definer drop \ TYPED-GLOBAL: f ;
