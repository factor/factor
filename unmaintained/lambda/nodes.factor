#! A lambda expression manipulator, by Matthew Willis
USING: lazy-lists strings arrays hashtables 
sequences namespaces words parser kernel ;

IN: lambda

SYMBOL: lambda-names
TUPLE: lambda-node self expr name ;
TUPLE: apply-node func arg ;
TUPLE: var-node name ; #! var is either a var, name, or pointer to a lambda-node
TUPLE: beta-node expr lambdas ; #! a namespace node
TUPLE: alien-node word ;

M: lambda-node equal? 2drop f ;

GENERIC: bind-var
M: lambda-node bind-var ( binding lambda -- ) 
    lambda-node-expr bind-var ; 

M: apply-node bind-var ( binding apply -- )
    [ apply-node-func bind-var ] 2keep apply-node-arg bind-var ;

M: var-node bind-var ( binding var-node -- )
    2dup var-node-name swap lambda-node-name = 
    [ set-var-node-name ] [ 2drop ] if ;

M: alien-node bind-var ( binding alien -- ) 2drop ;

C: lambda-node ( expr var lambda -- lambda )
    swapd [ set-lambda-node-name ] keep
    [ set-lambda-node-expr ] 2keep
    dup [ set-lambda-node-self ] keep
    [ swap bind-var ] keep ;

GENERIC: beta-push
#! push the beta further down the syntax tree
#!  this is how lambda achieves lazy beta reduction and efficient cloning.
#!  everything outside of the beta must have been cloned.
M: lambda-node beta-push ( beta lambda -- lambda )
    clone dup lambda-node-expr pick set-beta-node-expr
    [ set-lambda-node-expr ] keep ;

M: apply-node beta-push ( beta apply -- apply )
    #! push the beta into each branch, cloning the beta
    swap dup clone 
    pick apply-node-func swap [ set-beta-node-expr ] keep swap
    rot apply-node-arg swap [ set-beta-node-expr ] keep
    <apply-node> ;

M: var-node beta-push ( beta var -- expr )
    #! substitute the variable with the appropriate entry from the
    #! beta namespace
    tuck var-node-name swap beta-node-lambdas hash dup
    [ nip ] [ drop ] if ;

M: beta-node beta-push ( beta inner-beta -- beta )
    #! combines the namespaces of two betas
    dup beta-node-lambdas rot beta-node-lambdas hash-union
    swap [ set-beta-node-lambdas ] keep ;

M: alien-node beta-push ( beta alien -- alien ) nip ;

: beta-reduce ( apply -- beta )
    #! construct a beta-node which carries the namespace of the lambda
    dup apply-node-arg swap apply-node-func dup lambda-node-expr -rot
    lambda-node-self H{ } clone [ set-hash ] keep <beta-node> ;

DEFER: evaluate
: left-reduce ( apply -- apply/f )
    #! we are at an application node -- evaluate the function
    dup apply-node-func evaluate dup
    [ swap [ set-apply-node-func ] keep ]
    [ nip ] if ;

: alien-reduce ( apply -- node/f )
    #! we have come to an alien application, which requires us to
    #! fully normalize the argument before proceeding
    dup apply-node-arg evaluate dup
    [ swap [ set-apply-node-arg ] keep ]
    [ #! right side is normalized, we are ready to do the alien application
        drop dup apply-node-arg swap apply-node-func
        alien-node-word "lambda" lookup execute
    ] if ;

GENERIC: evaluate
#! There are 
#!   beta-reduction, beta-pushing, and name replacing.
: normalize ( expr -- expr )
    dup evaluate [ nip normalize ] when* ;
    
M: lambda-node evaluate ( lambda -- node/f ) drop f ;

M: apply-node evaluate ( apply -- node )
    dup apply-node-func lambda-node?
    [ beta-reduce ] 
    [ 
        dup apply-node-func alien-node?
        [ alien-reduce ]
        [ left-reduce ] if
    ] if ;

M: var-node evaluate ( var -- node/f ) 
    var-node-name lambda-names get hash ;

M: beta-node evaluate ( beta -- node/f ) 
    dup beta-node-expr beta-push ;

M: alien-node evaluate ( alien -- node/f ) drop f ;

GENERIC: expr>string
M: lambda-node expr>string ( lambda-node -- string )
    [ 
        dup "(" , lambda-node-name , ". " , 
        lambda-node-expr expr>string , ")" , 
    ] { } make concat ;

M: apply-node expr>string ( apply-node -- string ) 
    [ 
        dup "(" , apply-node-func expr>string , " " , 
        apply-node-arg expr>string , ")" , 
    ] { } make concat ;

M: var-node expr>string ( variable-node -- string ) 
    var-node-name dup string? [ lambda-node-name ] unless ;

M: alien-node expr>string ( alien-node -- string )
    [ "[" , alien-node-word , "]" , ] { } make concat ;

M: beta-node expr>string ( beta -- string )
    [ "beta<" , beta-node-expr expr>string , ">" , ] { } make concat ;