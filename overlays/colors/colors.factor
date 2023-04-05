! File: colors
! Version: 0.1
! DRI: Dave Carlton
! Description: Extend colors vocab
! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel math math.parser math.order prettyprint sequences
sorting sorting.human ui.tools.operations arrays ;
IN: colors

: nearest-color ( hex -- color value )
    dup first CHAR: # = [ unclip drop ] when
    hex>
    named-colors
    [ dup named-color color>hex ] map>alist
    [ dup second unclip drop hex> [ first ] dip  2array ] map
    [ second [ second ] dip <=> ] sort-with
    [ second over >= ] map-find
    2nip  [ first ] keep second 
;
    
: nc ( hex -- ) nearest-color .h com-copy-object ; 
