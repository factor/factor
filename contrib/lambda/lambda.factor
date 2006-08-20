#! An interpreter for lambda expressions, by Matthew Willis
REQUIRES: lazy-lists ;
USING: lazy-lists io strings hashtables sequences namespaces kernel ;
IN: lambda

: bound-vars ( -- lazy-list ) 65 lfrom [ ch>string ] lmap ;

: canonical-string ( expr -- string )
    #! pretty print in canonical form, for use with reverse lookups
    bound-vars swap expr>string ;

: original-string ( expr -- string )
    #! pretty print with vars named as inputed
    nil swap expr>string ;

: lambda-print ( names expr/name -- names )
    dup string? [ over dupd hash original-string " " swap 
        append append "DEF " swap append 
    ] [ original-string "=> " swap append 
    ] if print flush ;

: lambda-eval ( names parse-result -- names name/expr )
    #! Make sure not to evaluate definitions.
    first2 over [ 
        swap rot [ set-hash ] 2keep swap
    ] [
        pick swap replace-names swap drop evaluate
    ] if ;

: lambda-boot ( -- names )
    #! load the core lambda library
    H{ } clone ;

: (lambda) ( names -- names )
    readln dup "." = [ drop ] [
        lambda-parse lambda-eval lambda-print (lambda)
    ] if ;

: lambda ( -- names )
    lambda-boot (lambda) ;