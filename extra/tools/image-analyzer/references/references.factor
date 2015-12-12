! Tools to follow references in the loaded image.
USING: accessors byte-arrays fry kernel layouts math math.bitwise
sequences slots.syntax tools.image-analyzer.relocations ;
IN: tools.image-analyzer.references
QUALIFIED-WITH: tools.image-analyzer.vm vm

! Edges in the heap
GENERIC: pointers ( heap heap-node struct -- seq )

M: vm:array pointers ( heap heap-node struct -- seq )
    drop nip payload>> ;

: find-heap-node ( heap ptr -- node )
    15 unmask '[ address>> _ = ] find nip ;

: load-relocations ( heap code-block -- seq )
    relocation>> find-heap-node payload>> >byte-array byte-array>relocations
    [ first 2 = ] filter ;

: relocation>pointer ( heap-node relocation -- ptr )
    over payload>> swap load-relative-value swap address>> + ;

: relocation-pointers ( heap heap-node code-block -- seq )
    swapd load-relocations [ relocation>pointer ] with map ;

M: vm:code-block pointers ( heap heap-node struct -- seq )
    [ relocation-pointers ] [ slots{ owner parameters relocation } ] bi
    append ;

M: vm:word pointers ( heap heap-node struct -- seq )
    2nip [
        slots{ def name props vocabulary }
    ] [ entry_point>> 4 cell * - ] bi suffix ;

M: object pointers ( heap heap-node struct -- seq )
    3drop { } ;

: collect-pointers ( heap heap-node -- seq )
    dup object>> pointers [ 1 <= ] reject [ 15 unmask ] map ;
