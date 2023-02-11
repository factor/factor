! Copyright (C) 2015 Björn Lindqvist
! See https://factorcode.org/license.txt for BSD license
!
! Tools to follow references in the loaded image.
USING: accessors arrays byte-arrays fry kernel layouts math
math.bitwise sequences slots.syntax tools.image-analyzer.relocations
tools.image-analyzer.utils ;
IN: tools.image-analyzer.references
QUALIFIED-WITH: tools.image-analyzer.vm vm

! Edges in the heap
GENERIC: pointers ( heap heap-node struct -- seq )

: find-heap-node* ( heap untagged-ptr -- node )
    '[ address>> _ = ] find nip ;

: find-heap-node ( heap ptr -- node )
    untag find-heap-node* ;

: load-relocations ( heap code-block -- seq )
    relocation>> find-heap-node payload>> >byte-array byte-array>relocations
    [ interesting-relocation? ] filter ;

: relocation>pointer ( heap-node relocation -- ptr )
    [ [ address>> ] [ payload>> ] bi ] dip decode-relocation ;

: relocation-pointers ( heap heap-node code-block -- seq )
    swapd load-relocations [ relocation>pointer ] with map ;

: filter-data-pointers ( seq -- seq' )
    [ 15 mask 1 <= ] reject ;

M: vm:array pointers ( heap heap-node struct -- seq )
    drop nip payload>> filter-data-pointers ;

M: vm:code-block pointers ( heap heap-node struct -- seq )
    [ relocation-pointers ] [ slots{ owner parameters relocation } ] bi
    append ;

M: vm:quotation pointers ( heap heap-node struct -- seq )
    2nip [ array>> ] [ entry_point>> 4 cell * - ] bi 2array ;

M: vm:word pointers ( heap heap-node struct -- seq )
    2nip [
        slots{ def name pic_def pic_tail_def props subprimitive vocabulary }
        filter-data-pointers
    ] [ entry_point>> 4 cell * - ] bi suffix ;

M: object pointers ( heap heap-node struct -- seq )
    3drop { } ;

: collect-pointers ( heap heap-node -- seq )
    dup object>> pointers [ 1 <= ] reject [ untag ] map ;
