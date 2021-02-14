USING: accessors combinators fry locals kernel math multiline sequences ;

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
    { "age" f }
    { "allow" f }
    { "authorization" f }
    { "cache-control" f }
    { "content-disposition" f }
    { "content-encoding" f }
    { "content-language" f }
    { "content-length" f }
    { "content-location" f }
    { "content-range" f }
    { "content-type" f }
    { "cookie" f }
    { "date" f }
    { "etag" f }
    { "expect" f }
    { "expires" f }
    { "from" f }
    { "host" f }
    { "if-match" f }
    { "if-modified-since" f }
    { "if-none-match" f }
    { "if-range" f }
    { "if-unmodified-since" f }
    { "last-modified" f }
    { "link" f }
    { "location" f }
    { "max-forwards" f }
    { "proxy-authenticate" f }
    { "proxy-authorization" f }
    { "range" f }
    { "referer" f }
    { "refresh" f }
    { "retry-after" f }
    { "server" f }
    { "set-cookie" f }
    { "strict-transport-security" f }
    { "transfer-encoding" f }
    { "user-agent" f }
    { "vary" f }
    { "via" f }
    { "www-authenticate" f }
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

: get-header-from-table ( decode-context table-index -- field )
    ! check bounds: i < len(static-table++decode-context) and i > 0
    dup pick dynamic-table>> length static-table length + < 
    over 0 > 
    and [ ] unless ! if not valid throw error TODO: add error
    dup static-table length <  ! check if in static table
    [ nip static-table nth ]
    [ static-table length - 1 - swap dynamic-table>> nth ]
    if ;

: header-entry-size ( table-entry -- size )

;

: >>max-size ( decode-context new-size -- updated-context )
    drop ! minimial definition that should stack check.
    ;

: add-header-to-table ( decode-context header -- updated-context )
    drop ! minimial definition that should stack check.

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

