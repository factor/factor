! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs compiler.tree compiler.tree.combinators
fry kernel namespaces sequences ;
IN: compiler.tree.normalization.renaming

SYMBOL: rename-map

: rename-value ( value -- value' )
    [ rename-map get at ] keep or ;

: rename-values ( values -- values' )
    dup empty? [ rename-map get '[ [ _ at ] keep or ] map ] unless ;

: add-renamings ( old new -- )
    [ rename-values ] dip
    rename-map get '[ _ set-at ] 2each ;

GENERIC: rename-node-values* ( node -- node )

M: #introduce rename-node-values* ;

M: #shuffle rename-node-values*
    [ rename-values ] change-in-d
    [ rename-values ] change-in-r
    [ [ rename-value ] assoc-map ] change-mapping ;

M: #push rename-node-values* ;

M: #terminate rename-node-values*
    [ rename-values ] change-in-d
    [ rename-values ] change-in-r ;

M: #phi rename-node-values*
    [ [ rename-values ] map ] change-phi-in-d ;

M: #declare rename-node-values*
    [ [ [ rename-value ] dip ] assoc-map ] change-declaration ;

M: #alien-callback rename-node-values* ;

M: node rename-node-values*
    [ rename-values ] change-in-d ;

: rename-node-values ( nodes -- nodes' )
    dup [ rename-node-values* drop ] each-node ;
