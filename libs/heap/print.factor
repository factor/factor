! Binary Min Heap
! Copyright 2007 Ryan Murphy
! See http://factorcode.org/license.txt for BSD license.

USING: namespaces kernel math sequences prettyprint io ;
IN: heap

: spaces ( n -- str )
    [ [ " " % ] times ] "" make ;

: prepend-s ( v1 n -- v1' )
    spaces   swap [ append ] map-with ;

: append-s ( v1 v2 -- v1' )
    spaces   swap [ swap append ] map-with ;

: pad-r ( lv rv -- rv' )
    dup first length spaces   pick length pick length -
    [ [ dup , ] times ] V{ } make  
    nip append nip ;

: pad-l ( lv rv -- lv' )
    swap pad-r ;

: (aggregate2) ( lv rv -- v )
    over length over length >= [ dupd pad-r ] [ tuck pad-l swap ] if
    [ append ] 2map ;

: aggregate2 ( lv rv -- v )
    dup empty? [ drop ] [ over empty? [ nip ] [ (aggregate2) ] if ] if ;

: (agg3len) ( v -- len )
    dup empty? [ drop 0 ] [ first length ] if ;

: aggregate3 ( lv rv pv -- v )
    dup (agg3len) -roll
    pick (agg3len) prepend-s
    over (agg3len) append-s
    -roll -rot swap append-s
    swap aggregate2 append ;

: output-node ( elt -- str ) [ [ pprint ] string-out , ] V{ } make ;

: (print-heap) ( i heap -- vector )
    2dup l-oob [ V{ } clone ] [ over  left over (print-heap) ] if -rot
    2dup r-oob [ V{ } clone ] [ over right over (print-heap) ] if -rot
    V{ } clone pick pick nth  output-node append
    -rot 2drop aggregate3 ;

: print-heap ( heap -- )
    dup empty? [ drop ] [ 0 swap (print-heap) [ print ] each ] if ;