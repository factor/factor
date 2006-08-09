#! A lambda expression manipulator, by Matthew Willis
REQUIRES: lazy-lists ;
USING: lazy-lists strings arrays hashtables 
sequences namespaces words kernel ;

IN: kernel
: dip swap slip ; inline

IN: lambda

TUPLE: lambda-node expr temp-label ;
TUPLE: apply-node func arg ;
TUPLE: variable-node var ;

DEFER: substitute
C: lambda-node ( var expr implicit-empty-lambda-node -- lambda-node )
    #! store the expr, replacing every occurence of var with
    #! a pointer to this lambda-node
    [ <variable-node> -rot substitute ] keep 
    [ set-lambda-node-expr ] keep ;

GENERIC: (post-order)
#! Traverses the tree while executing a word in post-order
M: lambda-node (post-order) ( data-array word lambda-node -- node )
    [ [ lambda-node-expr (post-order) ] keep set-lambda-node-expr ] 3keep 
    swap execute ; 

M: apply-node (post-order) ( data-array word apply-node -- node )
    [ [ apply-node-func (post-order) ] keep set-apply-node-func ] 3keep
    [ [ apply-node-arg (post-order) ] keep set-apply-node-arg ] 3keep
    swap execute ;

M: variable-node (post-order) ( data-array word variable-node -- node )
    swap execute ;

: post-order ( node data-array word -- node )
    #! the public face of post-order.
    rot (post-order) ;

GENERIC: (clone-node)
#! (clone-node) uses both pre and post orders.
#! We could factor out (pre-post-order) and have both clone
#! and the existing post-order invoke that
M: lambda-node (clone-node) ( lambda-node -- node )
    dup clone
    [ lambda-node-expr (clone-node) ] keep [ set-lambda-node-expr ] keep
    [ dup <variable-node> -rot lambda-node-expr substitute  ] keep 
    [ set-lambda-node-expr ] keep ;

M: apply-node (clone-node) ( apply-node -- node )
    clone
    [ apply-node-func (clone-node) ] keep [ set-apply-node-func ] keep
    [ apply-node-arg (clone-node) ] keep [ set-apply-node-arg ] keep ;

M: variable-node (clone-node) ( variable-node -- node )
    clone ;

GENERIC: variable-eq?
M: string variable-eq? ( var string -- bool ) = ;

M: lambda-node variable-eq? ( var lambda-node-pointer -- bool ) eq? ;

GENERIC: (substitute)
M: lambda-node (substitute) ( data-array lambda-node -- ) nip ;

M: apply-node (substitute) ( data-array apply-node -- ) nip ;
    
M: variable-node (substitute) ( data-array variable-node -- )
    #! ( variable-node == var ) ? expr | variable-node
    #! this could use multiple dispatch!
    [ [ first ] keep second ] dip ( expr var variable-node -- )
    [ variable-node-var variable-eq? ] keep swap ( expr variable-node cond )
    [ swap ] unless drop ;  

: substitute ( expr var node -- node )
    -rot 2array \ (substitute) post-order ;

: beta-reduce ( expr lambda-node -- expr )
    #! "pass" expr to the lambda-node, returning a reduced expression
    (clone-node) dup lambda-node-expr substitute ;

GENERIC: (evaluate)
DEFER: evaluate
#! TODO: eta reduction
M: lambda-node (evaluate) ( data-array lambda-node -- node ) nip ;

M: apply-node (evaluate) ( data-array apply-node -- node )
    #! beta-reduction
    nip [ apply-node-func dup lambda-node? ] keep swap
    [ apply-node-arg swap beta-reduce evaluate ] [ nip ] if ;

M: variable-node (evaluate) ( data-array variable-node -- node ) nip ;

: evaluate ( node -- node )
    { } \ (evaluate) post-order ;

GENERIC: (replace-names)   
M: lambda-node (replace-names) ( names-hash l-node -- node ) nip ;

M: apply-node (replace-names) ( names-hash l-node -- node ) nip ;

M: variable-node (replace-names) ( names-hash variable-node -- node )
    [ variable-node-var swap hash ] keep over not 
    [ nip ] [ drop (clone-node) ] if ;

: replace-names ( names-hash node -- node )
    swap \ (replace-names) post-order ;

GENERIC: expr>string
M: lambda-node expr>string ( available-vars lambda-node -- string )
    [ uncons swap ] dip [ set-lambda-node-temp-label ] 2keep
    [ swap ] dip lambda-node-expr expr>string swap 
    [ "(" , , ". " , , ")" , ] { } make concat ;

M: apply-node expr>string ( available-vars apply-node -- string ) 
    [ apply-node-arg expr>string ] 2keep apply-node-func expr>string
    [ "(" , , " " , , ")" , ] { } make concat ;

M: variable-node expr>string ( available-vars variable-node -- string ) 
    nip variable-node-var dup string? [ lambda-node-temp-label ] unless ;