! Copyright (C) 2007, 2009 Slava Pestov, Eduardo Cavazos.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs effects.parser generic.parser
kernel lexer locals.errors locals.rewrite locals.types
make namespaces parser quotations sequences splitting
vocabs.parser words ;
IN: locals.parser

SYMBOL: in-lambda?

: ?rewrite-closures ( form -- form' )
    in-lambda? get [ 1array ] [ rewrite-closures ] if ;

ERROR: invalid-local-name name ;

: check-local-name ( name -- name )
    dup { "]" "]!" } member? [ invalid-local-name ] when ;

: make-local ( name -- word )
    check-local-name "!" ?tail [
        <local-reader>
        dup <local-writer> dup name>> ,,
    ] [ <local> ] if
    dup dup name>> ,, ;

: make-locals ( seq -- words assoc )
    [ [ make-local ] map ] H{ } make ;

: parse-local-defs ( -- words assoc )
    "|" parse-tokens make-locals ;

SINGLETON: lambda-parser

: with-lambda-scope ( assoc reader-quot: ( -- quot ) -- quot )
    H{
        { in-lambda? t }
        { quotation-parser lambda-parser }
    } -rot '[ _ _ with-words ] with-variables ; inline

: (parse-lambda) ( assoc -- quot )
    [ \ ] parse-until >quotation ] with-lambda-scope ;

: parse-lambda ( -- lambda )
    parse-local-defs
    (parse-lambda) <lambda>
    ?rewrite-closures ;

: parse-multi-def ( -- multi-def assoc )
    ")" parse-tokens make-locals [ <multi-def> ] dip ;

: parse-single-def ( name -- def assoc )
    [ make-local <def> ] H{ } make ;

: update-locals ( assoc -- )
    qualified-vocabs last words>> swap assoc-union! drop ;

: parse-def ( name/paren -- def )
    dup "(" = [ drop parse-multi-def ] [ parse-single-def ] if update-locals ;

M: lambda-parser parse-quotation
    H{ } clone (parse-lambda) ;

: parse-let ( -- form )
    H{ } clone (parse-lambda) <let> ?rewrite-closures ;

: parse-locals ( -- effect vars assoc )
    scan-effect
    dup
    in>> [ dup pair? [ first ] when ] map make-locals ;

: (parse-locals-definition) ( effect vars assoc reader-quot -- word quot effect )
    with-lambda-scope <lambda>
    [ nip "lambda" set-word-prop ]
    [ nip rewrite-closures dup length 1 = [ first ] [ bad-rewrite ] if ]
    [ drop nip ] 3tri ; inline

: parse-locals-definition ( word reader-quot -- word quot effect )
    [ parse-locals ] dip (parse-locals-definition) ; inline

: parse-locals-method-definition ( word reader -- word quot effect )
    [ parse-locals pick check-method-effect ] dip
    (parse-locals-definition) ; inline

: (::) ( -- word def effect )
    [
        scan-new-word
        [ parse-definition ]
        parse-locals-definition
    ] with-definition ;

: (M::) ( -- word def )
    [
        scan-new-method
        [
            [ parse-definition ]
            parse-locals-method-definition drop
        ] with-method-definition
    ] with-definition ;
