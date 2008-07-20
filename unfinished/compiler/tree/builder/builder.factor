! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors namespaces kernel sequences compiler.tree
stack-checker.visitor ;
IN: compiler.tree.builder

TUPLE: tree-builder first last ;

: node, ( node -- )
    dataflow-visitor get swap
    over last>>
    [ [ [ last>> ] dip >>successor drop ] [ >>last drop ] 2bi ]
    [ [ >>first ] [ >>last ] bi drop ]
    if ;

M: tree-builder child-visitor tree-builder new ;
M: tree-builder #introduce, #introduce node, ;
M: tree-builder #call, #call node, ;
M: tree-builder #call-recursive, #call-recursive node, ;
M: tree-builder #push, #push node, ;
M: tree-builder #shuffle, #shuffle node, ;
M: tree-builder #drop, #drop node, ;
M: tree-builder #>r, #>r node, ;
M: tree-builder #r>, #r> node, ;
M: tree-builder #return, #return node, ;
M: tree-builder #terminate, #terminate node, ;
M: tree-builder #if, [ first>> ] bi@ #if node, ;
M: tree-builder #dispatch, [ first>> ] map #dispatch node, ;
M: tree-builder #phi, #phi node, ;
M: tree-builder #declare, #declare node, ;
M: tree-builder #recursive, first>> #recursive node, ;
M: tree-builder #copy, #copy node, ;
