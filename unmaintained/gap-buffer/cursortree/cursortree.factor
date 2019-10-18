! Copyright (C) 2007 Alex Chapman All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel gap-buffer generic trees trees.avl-tree math sequences quotations ;
IN: gap-buffer.cursortree

TUPLE: cursortree cursors ;

: <cursortree> ( seq -- cursortree )
    <gb> cursortree construct-empty tuck set-delegate <avl-tree>
    over set-cursortree-cursors ;

GENERIC: cursortree-gb ( cursortree -- gb )
M: cursortree cursortree-gb ( cursortree -- gb ) delegate ;
GENERIC: set-cursortree-gb ( gb cursortree -- )
M: cursortree set-cursortree-gb ( gb cursortree -- ) set-delegate ;

TUPLE: cursor i tree ;
TUPLE: left-cursor ;
TUPLE: right-cursor ;

: cursor-index ( cursor -- i ) cursor-i ; inline

: add-cursor ( cursortree cursor -- ) dup cursor-index rot tree-insert ; 

: remove-cursor ( cursortree cursor -- )
    dup [ eq? ] curry swap cursor-index rot cursortree-cursors tree-delete-if ;

: set-cursor-index ( index cursor -- )
    dup cursor-tree over remove-cursor tuck set-cursor-i
    dup cursor-tree cursortree-cursors swap add-cursor ;

GENERIC: cursor-pos ( cursor -- n )
GENERIC: set-cursor-pos ( n cursor -- )
M: left-cursor cursor-pos ( cursor -- n ) [ cursor-i 1+ ] keep cursor-tree index>position ;
M: right-cursor cursor-pos ( cursor -- n ) [ cursor-i ] keep cursor-tree index>position ;
M: left-cursor set-cursor-pos ( n cursor -- ) >r 1- r> [ cursor-tree position>index ] keep set-cursor-index ;
M: right-cursor set-cursor-pos ( n cursor -- ) [ cursor-tree position>index ] keep set-cursor-index ;

: <cursor> ( cursortree -- cursor )
    cursor construct-empty tuck set-cursor-tree ;

: make-cursor ( cursortree pos cursor -- cursor )
    >r swap <cursor> r> tuck set-delegate tuck set-cursor-pos ;

: <left-cursor> ( cursortree pos -- left-cursor )
    left-cursor construct-empty make-cursor ;

: <right-cursor> ( cursortree pos -- right-cursor )
    right-cursor construct-empty make-cursor ;

: cursor-positions ( cursortree -- seq )
    cursortree-cursors tree-values [ cursor-pos ] map ;

M: cursortree move-gap ( n cursortree -- )
    #! Get the position of each cursor before the move, then re-set the
    #! position afterwards. This will update any changed cursor indices.
    dup cursor-positions >r tuck cursortree-gb move-gap
    cursortree-cursors tree-values r> swap [ set-cursor-pos ] 2each ;

: element@< ( cursor -- pos cursortree ) [ cursor-pos 1- ] keep cursor-tree ;
: element@> ( cursor -- pos cursortree ) [ cursor-pos ] keep cursor-tree ;

: at-beginning? ( cursor -- ? ) cursor-pos 0 = ;
: at-end? ( cursor -- ? ) element@> length = ;

: insert ( obj cursor -- ) element@> insert* ;

: element< ( cursor -- elem ) element@< nth ;
: element> ( cursor -- elem ) element@> nth ;

: set-element< ( elem cursor -- ) element@< set-nth ;
: set-element> ( elem cursor -- ) element@> set-nth ;

GENERIC: fix-cursor ( cursortree cursor -- )

M: left-cursor fix-cursor ( cursortree cursor -- )
    >r gb-gap-start 1- r> set-cursor-index ;

M: right-cursor fix-cursor ( cursortree cursor -- )
    >r gb-gap-end r> set-cursor-index ;

: fix-cursors ( old-gap-end cursortree -- )
    tuck cursortree-cursors tree-get-all [ fix-cursor ] curry* each ; 

M: cursortree delete* ( pos cursortree -- )
    tuck move-gap dup gb-gap-end swap dup (delete*) fix-cursors ;

: delete< ( cursor -- ) element@< delete* ;
: delete> ( cursor -- ) element@> delete* ;

