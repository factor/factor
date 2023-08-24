! Copyright (C) 2004, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs kernel namespaces sequences
stack-checker.visitor vectors ;
IN: compiler.tree

TUPLE: node < identity-tuple ;

TUPLE: #introduce < node out-d ;

: <#introduce> ( out-d -- node )
    #introduce new swap >>out-d ;

TUPLE: #call < node word in-d out-d body method class info ;

: <#call> ( inputs outputs word -- node )
    #call new
        swap >>word
        swap >>out-d
        swap >>in-d ;

TUPLE: #call-recursive < node label in-d out-d info ;

: <#call-recursive> ( inputs outputs label -- node )
    #call-recursive new
        swap >>label
        swap >>out-d
        swap >>in-d ;

TUPLE: #push < node literal out-d ;

: <#push> ( literal value -- node )
    #push new
        swap 1array >>out-d
        swap >>literal ;

TUPLE: #renaming < node ;

TUPLE: #shuffle < #renaming mapping in-d out-d in-r out-r ;

: <#shuffle> ( in-d out-d in-r out-r mapping -- node )
    #shuffle new
        swap >>mapping
        swap >>out-r
        swap >>in-r
        swap >>out-d
        swap >>in-d ;

: <#data-shuffle> ( in-d out-d mapping -- node )
    [ f f ] dip <#shuffle> ; inline

: <#drop> ( inputs -- node )
    { } { } <#data-shuffle> ;

TUPLE: #terminate < node in-d in-r ;

TUPLE: #branch < node in-d children live-branches ;

: new-branch ( value children class -- node )
    new
        swap >>children
        swap 1array >>in-d ; inline

TUPLE: #if < #branch ;

: <#if> ( ? true false -- node )
    2array #if new-branch ;

TUPLE: #dispatch < #branch ;

: <#dispatch> ( n branches -- node )
    #dispatch new-branch ;

TUPLE: #phi < node phi-in-d phi-info-d out-d terminated ;

: <#phi> ( d-phi-in d-phi-out terminated -- node )
    #phi new
        swap >>terminated
        swap >>out-d
        swap >>phi-in-d ;

TUPLE: #declare < node declaration ;

: <#declare> ( declaration -- node )
    #declare new
        swap >>declaration ;

TUPLE: #return < node in-d info ;

: <#return> ( stack -- node )
    #return new
        swap >>in-d ;

TUPLE: #recursive < node in-d word label loop? child ;

: <#recursive> ( label inputs child -- node )
    #recursive new
        swap >>child
        swap >>in-d
        swap >>label ;

TUPLE: #enter-recursive < node in-d out-d label info ;

: <#enter-recursive> ( label inputs outputs -- node )
    #enter-recursive new
        swap >>out-d
        swap >>in-d
        swap >>label ;

TUPLE: #return-recursive < #renaming in-d out-d label info ;

: <#return-recursive> ( label inputs outputs -- node )
    #return-recursive new
        swap >>out-d
        swap >>in-d
        swap >>label ;

TUPLE: #copy < #renaming in-d out-d ;

: <#copy> ( inputs outputs -- node )
    #copy new
        swap >>out-d
        swap >>in-d ;

TUPLE: #alien-node < node params in-d out-d ;

TUPLE: #alien-invoke < #alien-node ;

TUPLE: #alien-indirect < #alien-node ;

TUPLE: #alien-assembly < #alien-node ;

TUPLE: #alien-callback < node params child ;

: node, ( node -- ) stack-visitor get push ;

GENERIC: inputs/outputs ( #renaming -- inputs outputs )

M: #shuffle inputs/outputs mapping>> unzip swap ;
M: #copy inputs/outputs [ in-d>> ] [ out-d>> ] bi ;
M: #return-recursive inputs/outputs [ in-d>> ] [ out-d>> ] bi ;

: ends-with-terminate? ( nodes -- ? )
    [ f ] [ last #terminate? ] if-empty ;

M: vector child-visitor V{ } clone ;
M: vector #introduce, <#introduce> node, ;
M: vector #call, <#call> node, ;
M: vector #push, <#push> node, ;
M: vector #shuffle, <#shuffle> node, ;
M: vector #drop, <#drop> node, ;
M: vector #>r, [ [ f f ] dip ] [ swap zip ] 2bi #shuffle, ;
M: vector #r>, [ swap [ f swap ] dip f ] [ swap zip ] 2bi #shuffle, ;
M: vector #return, <#return> node, ;
M: vector #enter-recursive, <#enter-recursive> node, ;
M: vector #return-recursive, <#return-recursive> node, ;
M: vector #call-recursive, <#call-recursive> node, ;
M: vector #terminate, #terminate boa node, ;
M: vector #if, <#if> node, ;
M: vector #dispatch, <#dispatch> node, ;
M: vector #phi, <#phi> node, ;
M: vector #declare, <#declare> node, ;
M: vector #recursive, <#recursive> node, ;
M: vector #copy, <#copy> node, ;
M: vector #alien-invoke, #alien-invoke boa node, ;
M: vector #alien-indirect, #alien-indirect boa node, ;
M: vector #alien-assembly, #alien-assembly boa node, ;
M: vector #alien-callback, #alien-callback boa node, ;
