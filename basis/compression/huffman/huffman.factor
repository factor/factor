! Copyright (C) 2009 Marc Fauconneau.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs bit-arrays bitstreams combinators
fry hashtables heaps io kernel locals math math.order
math.parser math.ranges multiline namespaces sequences sorting
vectors ;
QUALIFIED-WITH: bitstreams bs
IN: compression.huffman

<PRIVATE

SYMBOL: leaf-table
SYMBOL: node-heap

TUPLE: huffman-code
    { value fixnum }
    { size fixnum }
    { code fixnum } ;

: <huffman-code> ( -- huffman-code )
    0 0 0 huffman-code boa ; inline

: next-size ( huffman-code -- )
    [ 1 + ] change-size
    [ 2 * ] change-code drop ; inline

: next-code ( huffman-code -- )
    [ 1 + ] change-code drop ; inline

:: all-patterns ( huffman-code n -- seq )
    n log2 huffman-code size>> - :> free-bits
    free-bits 0 >
    [ free-bits 2^ <iota> [ huffman-code code>> free-bits 2^ * + ] map ]
    [ huffman-code code>> free-bits neg 2^ /i 1array ] if ;

:: huffman-each ( ... tdesc quot: ( ... huffman-code -- ... ) -- ... )
    <huffman-code> :> code
    tdesc
    [
        code next-size
        [ code value<< code clone quot call code next-code ] each
    ] each ; inline

: update-reverse-table ( huffman-code n table -- )
    [ drop all-patterns ]
    [ nip '[ _ swap _ set-at ] each ] 3bi ;

:: reverse-table ( tdesc n -- rtable )
   n f <array> <enumerated> :> table
   tdesc [ n table update-reverse-table ] huffman-each
   table seq>> ;

TUPLE: huffman-tree
    { code maybe{ fixnum } }
    { left maybe{ huffman-tree } }
    { right maybe{ huffman-tree } } ;

: <huffman-tree> ( code left right -- huffman-tree )
    huffman-tree boa ;

: <huffman-internal> ( left right -- huffman-tree )
    huffman-tree new swap >>left swap >>right ;

: leaf? ( huff-tree -- ? )
    [ left>> not ] [ right>> not ] bi and ;

: gen-leaves ( lit-seq -- leaves )
    [ huffman-tree new swap >>code ] map ; 

: build-leaf-table ( leaves --  )
    dup empty? [ drop ] [ dup first leaf-table get inc-at rest build-leaf-table ] if ;
 
: insert-leaves ( -- ) leaf-table get unzip swap zip node-heap get heap-push-all  ;

: combine-two ( -- )
    node-heap get heap-pop node-heap get heap-pop swap [ + ] dip pick <huffman-internal> swap node-heap get heap-push drop ;

: build-tree ( lit-seq -- heap )
    gen-leaves build-leaf-table insert-leaves [ node-heap get heap-size 1 > ] [ combine-two ] while node-heap get ; 

! Walks down a huffman tree and outputs a dictionary of codes 
: (generate-codes) ( huff-tree -- code-dict ) 
    dup leaf? [ code>> ?{ } swap  H{ } clone ?set-at ] 
              [ 
                [ left>> (generate-codes) [ ?{ f } prepend ] assoc-map ] 
                [ right>> (generate-codes) [ ?{ t } prepend ] assoc-map ] bi assoc-union! 
              ] if ;

: generate-codes ( lit-seq -- code-dict )
    [
        H{ } clone leaf-table set
        <min-heap> node-heap set
        build-tree heap-pop swap (generate-codes) nip
    ] with-scope ;

! Ordering of codes that is useful for generating canonical codes.
! Sort by length, then lexicographically.
:: <==> ( b1 b2  -- <=> )
    {
      { [ b1 length  b2 length <  ] [ +lt+ ] }
      { [ b2 length  b1 length  <  ] [ +gt+ ] }
      { [ b1 reverse bit-array>integer b2 reverse bit-array>integer < ] [ +lt+ ] }
      { [ b2 reverse bit-array>integer b1 reverse bit-array>integer < ] [ +gt+ ] }
      [ +eq+ ]
    } cond ;

: compare! ( obj1 obj2 quot -- <==> )
    bi@ <==> ; inline

: sort-with! ( seq quot -- sortedseq )
    [ compare! ] curry sort ; inline

: sort-values! ( obj -- sortedseq )
    >alist [ second ] sort-with! ;

: get-next-code ( code current -- next )
   [ reverse bit-array>integer 1 + ] [ length ] bi <bits> >bit-array reverse dup length pick length swap - [ f ] replicate append nip ;

! Does most of the work of converting a collection of codes to canonical ones. 
: (canonize-codes) ( current codes  -- codes )
    dup empty? [ 2drop V{ } clone ] [ dup first pick get-next-code dup pick 1 tail (canonize-codes) ?push 2nip ] if ;

! Basically a wrapper for the above recursive helper 
: canonize-codes ( codes -- codes )
    dup first dup pick 1 tail (canonize-codes) ?push nip reverse ;





PRIVATE>

TUPLE: huffman-decoder
    { bs bit-reader }
    { tdesc array }
    { rtable array }
    { bits/level fixnum } ;

: <huffman-decoder> ( bs tdesc -- huffman-decoder )
    huffman-decoder new
        swap >>tdesc
        swap >>bs
        16 >>bits/level
        dup [ tdesc>> ] [ bits/level>> 2^ ] bi reverse-table >>rtable ; inline

: read1-huff ( huffman-decoder -- elt )
    16 over [ bs>> bs:peek ] [ rtable>> nth ] bi
    [ size>> swap bs>> bs:seek ] [ value>> ] bi ; inline

: reverse-bits ( value bits -- value' )
    [ integer>bit-array ] dip
    f pad-tail reverse bit-array>integer ; inline

: read1-huff2 ( huffman-decoder -- elt )
    16 over [ bs>> bs:peek 16 reverse-bits ] [ rtable>> nth ] bi
    [ size>> swap bs>> bs:seek ] [ value>> ] bi ; inline

! Outputs a dictionary of canonical codes
: generate-canonical-codes ( lit-seq -- code-dict )
    generate-codes sort-values! unzip canonize-codes zip ;

