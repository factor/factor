USING: accessors arrays assocs classes.tuple generic.standard
kernel lexer locals.types namespaces parser quotations
vocabs.parser words ;
IN: functors.backend

DEFER: functor-words
\ functor-words [ H{ } clone ] initialize

SYNTAX: FUNCTOR-SYNTAX:
    scan-word
    gensym [ parse-definition define-syntax ] keep
    swap name>> \ functor-words get-global set-at ;

: functor-words ( -- assoc )
    \ functor-words get-global ;

: scan-param ( -- obj ) scan-object literalize ;

: >string-param ( string -- string/param )
    dup search dup lexical? [ nip ] [ drop ] if ;

: scan-string-param ( -- name/param )
    scan-token >string-param ;

: scan-c-type-param ( -- c-type/param )
    scan-token dup "{" = [ drop \ } parse-until >array ] [ >string-param ] if ;

: define* ( word def -- ) over set-last-word define ;

: define-declared* ( word def effect -- )
    pick set-last-word define-declared ;

: define-simple-generic* ( word effect -- )
    over set-last-word define-simple-generic ;

: define-tuple-class* ( class superclass slots -- )
    pick set-last-word define-tuple-class ;
