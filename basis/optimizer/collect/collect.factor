! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: inference.dataflow inference.backend kernel ;
IN: optimizer

: collect-label-infos ( node -- node )
    dup [
        dup #label? [ collect-label-info ] [ drop ] if
    ] each-node ;

