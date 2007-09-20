#! An interpreter for lambda expressions, by Matthew Willis
USING: io strings hashtables sequences namespaces kernel ;
IN: lambda

: lambda-print ( name/expr -- )
    dup string? 
    [   dup lambda-names get hash expr>string " " swap 
        append append "DEF " swap append 
    ] [ expr>string "=> " swap append 
    ] if print flush ;

: lambda-define ( parse-result -- name/expr )
    #! Make sure not to evaluate definitions.
    first2 over [ over lambda-names get set-hash ] [ nip ] if ;

: lambda-eval ( name/expr -- name/expr )
    dup string? [ normalize ] unless ;

: lambda-boot ( -- )
    #! load the core lambda library
    H{ } clone lambda-names set lambda-core
    [ lambda-parse lambda-define lambda-eval lambda-print ] each ;
 
: lambda ( -- )
    lambda-names get [ lambda-boot ] unless
    readln dup "." = [ drop ] [
        lambda-parse lambda-define lambda-eval lambda-print lambda
    ] if ;