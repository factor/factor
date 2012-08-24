! Copyright (C) 2007, 2009 Slava Pestov, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators effects.parser
generic.parser kernel lexer locals.errors fry
locals.rewrite.closures locals.types make namespaces parser
quotations sequences splitting words vocabs.parser ;
IN: locals.parser

SYMBOL: in-lambda?

: ?rewrite-closures ( form -- form' )
    in-lambda? get [ 1array ] [ rewrite-closures ] if ;

: make-local ( name -- word )
    "!" ?tail [
        <local-reader>
        dup <local-writer> dup name>> ,,
    ] [ <local> ] if
    dup dup name>> ,, ;

: make-locals ( seq -- words assoc )
    [ [ make-local ] map ] H{ } make ;

: parse-local-defs ( -- words assoc )
    [ "|" [ make-local ] map-tokens ] H{ } make ;

SINGLETON: lambda-parser

SYMBOL: locals

: ((parse-lambda)) ( assoc quot -- quot' )
    '[
        in-lambda? on
        lambda-parser quotation-parser set
        [ locals set ]
        [ use-words @ ]
        [ unuse-words ] tri
    ] with-scope ; inline

: (parse-lambda) ( assoc -- quot )
    [ \ ] parse-until >quotation ] ((parse-lambda)) ;

: parse-lambda ( -- lambda )
    parse-local-defs
    (parse-lambda) <lambda>
    ?rewrite-closures ;

: parse-multi-def ( locals -- multi-def )
    [ [ ")" [ make-local ] map-tokens ] H{ } make ] dip
    swap assoc-union! drop <multi-def> ;

: parse-def ( name/paren locals -- def )
    over "(" =
    [ nip parse-multi-def ]
    [ [ [ make-local ] H{ } make ] dip swap assoc-union! drop <def> ]
    if ;

M: lambda-parser parse-quotation ( -- quotation )
    H{ } clone (parse-lambda) ;

: parse-binding ( end -- pair/f )
    scan-token {
        { [ 2dup = ] [ 2drop f ] }
        [ nip scan-object 2array ]
    } cond ;

: parse-let ( -- form )
    H{ } clone (parse-lambda) <let> ?rewrite-closures ;

: parse-locals ( -- effect vars assoc )
    scan-effect
    dup
    in>> [ dup pair? [ first ] when ] map make-locals ;

: (parse-locals-definition) ( effect vars assoc reader -- word quot effect )
    ((parse-lambda)) <lambda>
    [ nip "lambda" set-word-prop ]
    [ nip rewrite-closures dup length 1 = [ first ] [ bad-rewrite ] if ]
    [ drop nip ] 3tri ; inline

: parse-locals-definition ( word reader -- word quot effect )
    [ parse-locals ] dip (parse-locals-definition) ; inline

: parse-locals-method-definition ( word reader -- word quot effect )
    [ parse-locals pick check-method-effect ] dip
    (parse-locals-definition) ; inline

: (::) ( -- word def effect )
    [
        scan-new-word
        [ parse-definition ]
        parse-locals-definition
    ] in-word-definition ;

: (M::) ( -- word def )
    [
        scan-new-method
        [
            [ parse-definition ]
            parse-locals-method-definition drop
        ] with-method-definition
    ] in-word-definition ;
