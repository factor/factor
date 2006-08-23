#! A lambda expression manipulator, by Matthew Willis
USING: lazy-lists strings arrays hashtables 
sequences namespaces words parser kernel ;

IN: lambda

: dip swap slip ; inline

TUPLE: lambda-node expr original canonical ;
TUPLE: apply-node func arg ;
TUPLE: variable-node var ;
TUPLE: alien-node word ;

DEFER: substitute
C: lambda-node ( var expr implicit-empty-lambda-node -- lambda-node )
    #! store the expr, replacing every occurence of var with
    #! a pointer to this lambda-node
    [ <variable-node> -rot substitute ] 3keep nip swapd
    [ set-lambda-node-expr ] keep 
    [ set-lambda-node-original ] keep ;

GENERIC: (traverse)
: (pre) ( data-array pre-post node -- data-array pre-post new-node )
    [ swap first execute ] 3keep drop rot ;

: (post) ( data-array pre-post node -- new-node )
    swap second execute ;
    
#! Traverses the tree while executing pre and post order words
M: lambda-node (traverse) ( data-array words lambda-node -- node )
    (pre)
    [ [ lambda-node-expr (traverse) ] keep set-lambda-node-expr ] 3keep 
    (post) ; 

M: apply-node (traverse) ( data-array words apply-node -- node )
    (pre)
    [ [ apply-node-func (traverse) ] keep set-apply-node-func ] 3keep
    [ [ apply-node-arg (traverse) ] keep set-apply-node-arg ] 3keep
    (post) ;

M: variable-node (traverse) ( data-array words variable-node -- node )
    (pre) (post) ;

M: alien-node (traverse) ( data-array word alien-node -- node ) nip nip ;

: traverse ( node data-array {pre,post} -- node )
    rot (traverse) ;

: pre-order ( node data-array word -- node )
    { nip } curry traverse ;
    
: post-order ( node data-array word -- node )
    { nip } swap add traverse ;

GENERIC: (clone-pre)
M: lambda-node (clone-pre) ( data lambda-node -- node )
    #! leave a copy of the original lambda node on the stack
    #! for later substitution
    nip dup clone ; 

M: apply-node (clone-pre) ( data apply-node -- node ) nip clone ;

M: variable-node (clone-pre) ( data variable-node -- node ) nip clone ;

GENERIC: (clone-post)
M: lambda-node (clone-post) ( data lambda-node -- node )
    nip [ dup <variable-node> -rot lambda-node-expr substitute  ] keep 
    [ set-lambda-node-expr ] keep ;
    
M: apply-node (clone-post) ( data apply-node -- node ) nip ;

M: variable-node (clone-post) ( data variable-node -- node ) nip ;

: clone-node ( node -- clone )
    f { (clone-pre) (clone-post) } traverse ;

GENERIC: variable-eq?
M: string variable-eq? ( var string -- bool ) = ;

M: lambda-node variable-eq? ( var lambda-node-pointer -- bool ) eq? ;

GENERIC: (substitute)
M: lambda-node (substitute) ( data-array lambda-node -- node ) nip ;

M: apply-node (substitute) ( data-array apply-node -- node ) nip ;
    
M: variable-node (substitute) ( data-array variable-node -- node )
    #! ( variable-node == var ) ? expr | variable-node
    #! this could use multiple dispatch!
    [ first2 ] dip ( expr var variable-node -- )
    [ variable-node-var variable-eq? ] keep swap ( expr variable-node cond )
    [ swap ] unless drop ;  

: substitute ( expr var node -- node )
    -rot 2array \ (substitute) post-order ;

: beta-reduce ( apply-node -- expr )
    #! "pass" expr to the lambda-node, returning a reduced expression
    dup apply-node-arg swap apply-node-func 
    clone-node dup lambda-node-expr substitute ;

: eta-reduce ( lambda-node -- expr ) 
    lambda-node-expr apply-node-func ;

DEFER: evaluate
: alien-reduce ( apply-node -- expr )
    #! execute the factor word in the alien-node
    dup apply-node-arg evaluate 
    swap apply-node-func alien-node-word "lambda" lookup execute ;

GENERIC: evaluate
M: lambda-node evaluate ( lambda-node -- node ) 
    #! eta-reduction
    dup lambda-node-expr apply-node? [ 
        dup lambda-node-expr apply-node-arg 
        variable-node? [
            dup dup lambda-node-expr apply-node-arg variable-node-var 
            eq? [ 
                eta-reduce evaluate 
            ] when
        ] when
    ] when ;

M: apply-node evaluate ( apply-node -- node )
    #! beta-reduction
    #! TODO: fix the weird recursion here
    dup apply-node-func alien-node?
    [ alien-reduce evaluate ]
    [
        dup apply-node-func lambda-node?
        [ beta-reduce evaluate ] 
        [
            dup apply-node-func evaluate swap [ set-apply-node-func ] keep
            dup apply-node-func lambda-node? [ evaluate ] when
        ] if
    ] if ;

M: variable-node evaluate ( variable-node -- node ) ;

M: alien-node evaluate ( alien-node -- node ) ;

GENERIC: (replace-names)
DEFER: replace-names 
M: lambda-node (replace-names) ( names-hash l-node -- node ) nip ;

M: apply-node (replace-names) ( names-hash a-node -- node ) nip ;

M: variable-node (replace-names) ( names-hash v-node -- node )
    [ variable-node-var swap hash ] 2keep pick not 
    [ 2nip ] [ drop swap clone-node replace-names ] if ;

: replace-names ( names-hash node -- node )
    swap \ (replace-names) post-order ;

: set-temp-label ( available-vars lambda-node -- available-vars label lambda-node )
    over nil? 
    [ [ lambda-node-original ] keep [ set-lambda-node-canonical ] 2keep ]
    [ [ uncons swap ] dip [ set-lambda-node-canonical ] 2keep ] if ;

GENERIC: expr>string
M: lambda-node expr>string ( available-vars lambda-node -- string )
    set-temp-label swapd lambda-node-expr expr>string swap 
    [ "(" , , ". " , , ")" , ] { } make concat ;

M: apply-node expr>string ( available-vars apply-node -- string ) 
    [ apply-node-arg expr>string ] 2keep apply-node-func expr>string
    [ "(" , , " " , , ")" , ] { } make concat ;

M: variable-node expr>string ( available-vars variable-node -- string ) 
    nip variable-node-var dup string? [ lambda-node-canonical ] unless ;

M: alien-node expr>string ( available-vars alien-node -- string )
    nip [ "[" , alien-node-word , "]" , ] { } make concat ;