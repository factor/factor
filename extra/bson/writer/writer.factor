! Copyright (C) 2010 Sascha Matzke.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs bson.constants byte-arrays
calendar combinators.short-circuit fry hashtables io io.binary
kernel linked-assocs literals math math.parser namespaces byte-vectors
quotations sequences serialize strings vectors dlists alien.accessors ;
FROM: words => word? word ;
FROM: typed => TYPED: ;
FROM: combinators => cond ;
IN: bson.writer

<PRIVATE

CONSTANT: INT32-SIZE { 0 1 2 3 }
CONSTANT: INT64-SIZE { 0 1 2 3 4 5 6 7 }

PRIVATE>

TYPED: get-output ( -- stream: byte-vector )
    output-stream get ; inline

TYPED: with-length ( quot -- bytes-written: integer start-index: integer )
    [ get-output [ length ] [ ] bi ] dip
    call length swap [ - ] keep ; inline

: (with-length-prefix) ( quot: ( .. -- .. ) length-quot: ( bytes-written -- length ) -- )
    [ [ B{ 0 0 0 0 } write ] prepose with-length ] dip swap
    [ call( written -- length ) get-output underlying>> ] dip set-alien-unsigned-4 ; inline

: with-length-prefix ( quot: ( .. -- .. ) -- )
    [ ] (with-length-prefix) ; inline
    
: with-length-prefix-excl ( quot: ( .. -- .. ) -- )
    [ 4 - ] (with-length-prefix) ; inline

: (>le) ( x n -- )
    [ nth-byte write1 ] with each ; inline
    
<PRIVATE

TYPED: write-int32 ( int: integer -- ) INT32-SIZE (>le) ; inline

TYPED: write-double ( real: float -- ) double>bits INT64-SIZE (>le) ; inline

TYPED: write-cstring ( string: string -- )
    get-output [ length ] [  ] bi copy 0 write1 ; inline

: write-longlong ( object -- ) INT64-SIZE (>le) ; inline

: write-eoo ( -- ) T_EOO write1 ; inline

TYPED: write-header ( name: string object type: integer -- object )
    write1 [ write-cstring ] dip ; inline

DEFER: write-pair

TYPED: write-byte-array ( binary: byte-array -- )
    [ length write-int32 ]
    [ T_Binary_Bytes write1 write ] bi ; inline

TYPED: write-mdbregexp ( regexp: mdbregexp -- )
   [ regexp>> write-cstring ]
   [ options>> write-cstring ] bi ; inline

TYPED: write-sequence ( array: sequence -- )
   '[
        _ [ number>string swap write-pair ] each-index
        write-eoo
    ] with-length-prefix ; inline recursive

TYPED: write-oid ( oid: oid -- )
    [ a>> write-longlong ] [ b>> write-int32 ] bi ; inline

: write-oid-field ( assoc -- )
    [ MDB_OID_FIELD dup ] dip at
    [ dup oid? [ T_OID write-header write-oid ] [ write-pair ] if ] 
    [ drop ] if* ; inline

: skip-field? ( name value -- name value boolean )
    over { [ MDB_OID_FIELD = ] [ MDB_META_FIELD = ] } 1|| ; inline

UNION: hashtables hashtable linked-assoc ;

TYPED: write-assoc ( assoc: hashtables -- )
    '[ _ [ write-oid-field ] [
            [ skip-field? [ 2drop ] [ write-pair ] if ] assoc-each 
         ] bi write-eoo
    ] with-length-prefix ; inline recursive

UNION: code word quotation ;

TYPED: (serialize-code) ( code: code -- )
  object>bytes
  [ length write-int32 ]
  [ T_Binary_Custom write1 write ] bi ; inline

TYPED: write-string ( string: string -- )
    '[ _ write-cstring ] with-length-prefix-excl ; inline

TYPED: write-boolean ( bool: boolean -- )
    [ 1 write1 ] [ 0 write1 ] if ; inline

TYPED: write-pair ( name: string obj -- )
    {
        {
            [ dup { [ hashtable? ] [ linked-assoc? ] } 1|| ]
            [ T_Object write-header write-assoc ]
        } {
            [ dup { [ array? ] [ vector? ] [ dlist? ] } 1|| ]
            [ T_Array write-header write-sequence ]
        } {
            [ dup byte-array? ]
            [ T_Binary write-header write-byte-array ]
        } {
            [ dup string? ]
            [ T_String write-header write-string ]
        } {
            [ dup oid? ]
            [ T_OID write-header write-oid ]
        } {
            [ dup integer? ]
            [ T_Integer write-header write-int32 ]
        } {
            [ dup boolean? ] 
            [ T_Boolean write-header write-boolean ]
        } {
            [ dup real? ]
            [ T_Double write-header >float write-double ]
        } {
            [ dup timestamp? ]
            [ T_Date write-header timestamp>millis write-longlong ]
        } {
            [ dup mdbregexp? ]
            [ T_Regexp write-header write-mdbregexp ]
        } {
            [ dup quotation? ]
            [ T_Binary write-header (serialize-code) ]
        } {
            [ dup word? ]
            [ T_Binary write-header (serialize-code) ]
        } {
            [ dup dbref? ]
            [ T_Object write-header dbref>assoc write-assoc ]
        } {
            [ dup f = ]
            [ T_NULL write-header drop ]
        }
    } cond ;

PRIVATE>

TYPED: assoc>bv ( assoc: hashtables -- byte-vector: byte-vector )
    [ BV{ } clone dup ] dip '[ _ write-assoc ] with-output-stream* ; inline

TYPED: assoc>stream ( assoc: hashtables -- )
    write-assoc ; inline

TYPED: mdb-special-value? ( value -- ?: boolean )
   { [ timestamp? ] [ quotation? ] [ mdbregexp? ]
     [ oid? ] [ byte-array? ] } 1|| ; inline