! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic assocs kernel math namespaces parser
sequences words vectors math.intervals effects classes
accessors combinators stack-checker.state stack-checker.visitor ;
IN: compiler.tree

! High-level tree SSA form.

TUPLE: node < identity-tuple info ;

M: node hashcode* drop node hashcode* ;

TUPLE: #introduce < node value ;

: #introduce ( value -- node )
    \ #introduce new swap >>value ;

TUPLE: #call < node word in-d out-d body method ;

: #call ( inputs outputs word -- node )
    \ #call new
        swap >>word
        swap >>out-d
        swap >>in-d ;

TUPLE: #call-recursive < node label in-d out-d ;

: #call-recursive ( inputs outputs label -- node )
    \ #call-recursive new
        swap >>label
        swap >>out-d
        swap >>in-d ;

TUPLE: #push < node literal out-d ;

: #push ( literal value -- node )
    \ #push new
        swap 1array >>out-d
        swap >>literal ;

TUPLE: #renaming < node ;

TUPLE: #shuffle < #renaming mapping in-d out-d ;

: #shuffle ( inputs outputs mapping -- node )
    \ #shuffle new
        swap >>mapping
        swap >>out-d
        swap >>in-d ;

: #drop ( inputs -- node )
    { } { } #shuffle ;

TUPLE: #>r < #renaming in-d out-r ;

: #>r ( inputs outputs -- node )
    \ #>r new
        swap >>out-r
        swap >>in-d ;

TUPLE: #r> < #renaming in-r out-d ;

: #r> ( inputs outputs -- node )
    \ #r> new
        swap >>out-d
        swap >>in-r ;

TUPLE: #terminate < node in-d ;

: #terminate ( stack -- node )
    \ #terminate new
        swap >>in-d ;

TUPLE: #branch < node in-d children live-branches ;

: new-branch ( value children class -- node )
    new
        swap >>children
        swap 1array >>in-d ; inline

TUPLE: #if < #branch ;

: #if ( ? true false -- node )
    2array \ #if new-branch ;

TUPLE: #dispatch < #branch ;

: #dispatch ( n branches -- node )
    \ #dispatch new-branch ;

TUPLE: #phi < node phi-in-d phi-info-d phi-in-r phi-info-r out-d out-r terminated ;

: #phi ( d-phi-in d-phi-out r-phi-in r-phi-out terminated -- node )
    \ #phi new
        swap >>terminated
        swap >>out-r
        swap >>phi-in-r
        swap >>out-d
        swap >>phi-in-d ;

TUPLE: #declare < node declaration ;

: #declare ( declaration -- node )
    \ #declare new
        swap >>declaration ;

TUPLE: #return < node in-d ;

: #return ( stack -- node )
    \ #return new
        swap >>in-d ;

TUPLE: #recursive < node in-d word label loop? returns calls child ;

: #recursive ( word label inputs child -- node )
    \ #recursive new
        swap >>child
        swap >>in-d
        swap >>label
        swap >>word ;

TUPLE: #enter-recursive < node in-d out-d label ;

: #enter-recursive ( label inputs outputs -- node )
    \ #enter-recursive new
        swap >>out-d
        swap >>in-d
        swap >>label ;

TUPLE: #return-recursive < #renaming in-d out-d label ;

: #return-recursive ( label inputs outputs -- node )
    \ #return-recursive new
        swap >>out-d
        swap >>in-d
        swap >>label ;

TUPLE: #copy < #renaming in-d out-d ;

: #copy ( inputs outputs -- node )
    \ #copy new
        swap >>out-d
        swap >>in-d ;

: node, ( node -- ) stack-visitor get push ;

GENERIC: inputs/outputs ( #renaming -- inputs outputs )

M: #shuffle inputs/outputs mapping>> unzip swap ;
M: #>r inputs/outputs [ in-d>> ] [ out-r>> ] bi ;
M: #r> inputs/outputs [ in-r>> ] [ out-d>> ] bi ;
M: #copy inputs/outputs [ in-d>> ] [ out-d>> ] bi ;
M: #return-recursive inputs/outputs [ in-d>> ] [ out-d>> ] bi ;

M: vector child-visitor V{ } clone ;
M: vector #introduce, #introduce node, ;
M: vector #call, #call node, ;
M: vector #push, #push node, ;
M: vector #shuffle, #shuffle node, ;
M: vector #drop, #drop node, ;
M: vector #>r, #>r node, ;
M: vector #r>, #r> node, ;
M: vector #return, #return node, ;
M: vector #enter-recursive, #enter-recursive node, ;
M: vector #return-recursive, #return-recursive node, ;
M: vector #call-recursive, #call-recursive node, ;
M: vector #terminate, #terminate node, ;
M: vector #if, #if node, ;
M: vector #dispatch, #dispatch node, ;
M: vector #phi, #phi node, ;
M: vector #declare, #declare node, ;
M: vector #recursive, #recursive node, ;
M: vector #copy, #copy node, ;
