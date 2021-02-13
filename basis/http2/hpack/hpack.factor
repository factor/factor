USING: combinators fry locals kernel math multiline sequences ;

IN: hpack

: hpack-encode ( -- ) ;

<PRIVATE

TUPLE: decode-context
    { max-size } { dynamic-table initial: { } } ;

! The static table for hpack compression/decompression
CONSTANT: static-table {
    { } ! empty so indexing works out properly
    { ":authority" f }
    { ":method" "GET" }
    { ":method" "POST" }
    { ":path" "/" }
    { ":path" "/index.html" }
    { ":scheme" "http" }
    { ":scheme" "https" }
    { ":status" "200" }
    { ":status" "204" }
    { ":status" "206" }
    { ":status" "304" }
    { ":status" "400" }
    { ":status" "404" }
    { ":status" "500" }
    { "accept-charset" f }
    { "accept-encoding" "gzip, deflate" }
    { "accept-language" f }
    { "accept-ranges" f }
    { "accept" f }
    { "access-control-allow-origin" f }
    ! TODO: finish transcribing the static table
}

! block will be a byte array
:: decode-field ( decode-context block index -- updated-context block new-index field/f )
    {
        ! the action quote will leave the consumed/new-index,
        ! the field decoded or f
        { [ index block nth 0 bit? ] [ /* action quote */ ] } 
        { [ index block nth 1 bit? ] [ /* action quote */ ] } 
        { [ index block nth 2 bit? ] [ /* action quote */ ] } 
        [ /* default action quote */ ]
    } cond ;

: get-header-from-table ( decode-context table-index -- field/f )
    ! check bounds: i < len(static-table++decode-context) and i > 0
    dup pick dynamic-table>> length static-table length + < 
    over 0 > 
    and [ ] unless ! if not valid throw error
    dup static-table length <  ! check if in static table
    [ nip static-table nth ] [ swap dynamic-table>> nth ] if
    ;

: add-header-to-table ( decode-context header -- updated-context )

    ;

PRIVATE>


! should give the updated dtable, and the list of decoded
! header fields. block is the bytestring (byte array) for the header block
: hpack-decode ( decode-context block -- updated-context decoded )
    V{ } clone -rot ! a vector for decoded stuff, under the stack inputs
    0 ! index in the block
    ! check that the block is longer than the index
    [ 2keep swap length < ]
    ! call decode-field and add the (possibly) decoded field to the list
    ! (if the list has stuff, then we have to add...)
    [ decode-field '[ _ [ suffix ] when* ] 3dip ]
    while
    ! double check the table size
    ;

