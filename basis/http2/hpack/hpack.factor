USING: accessors arrays combinators fry locals kernel math
math.functions math.bitwise multiline sequences strings ;

IN: hpack

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

! headers will be a list of tuples
:: encode-field ( encode-context headers index -- updated-context block new-index field/f )
    {
        ! first search if the header is in the header table

        ! TODO if not encode it as a literal and then add it to table 

        ! TODO if in table, if perfect match, use it, else, use indexed literal
        ;
: search-table ( - ) ;

: encode-literal ( - ) ;    

: decode-integer-fragment ( block index I M -- block index+1 I' M+7 block[index+1] )
    ! increment index and get block[index]
    [ 1 + ] 2dip [ 2dup swap nth ] 2dip
    ! stack: block index+1 block[index+1] I M
    ! compute I' = (block[index+1] & 127) * 2^M + I
    pick 127 mask 2 pick ^ * '[ _ + ] dip
    7 + rot ;


: decode-integer ( block current-index prefix-length -- block new-index number )
    ! get the current octet, compute mask, apply mask
    [ 2dup swap nth ] dip 2 swap ^ 1 - [ mask ] keep
    over = 
    ! stack: block index I loop?
    [ 0
        ! TODO: consider rewriting this loop using sequence
        ! words and clever thinking (maybe something like
        ! finding the index of the next byte starting with 0,
        ! mapping each byte to the corresponding integer,
        ! reducing in a clever way and adding the offset
      [ 7 bit? ] [ decode-integer-fragment ] do while 
      ! stack: block index I M, get rid of M, we don't need it
      drop ]
    when ! the prefix matches the mask (exactly all 1s), must loop
    [ 1 + ] dip ! increment the index before return
    ;

: decode-string ( block current-index -- block new-index string )
    2dup swap nth 7 bit?
    [ 7 decode-integer ] dip
    [ + "" ] ! Huffman encoding case, currently just a stub for stack effects
    [ over + dup ! compute the last index and the new index
      [ pick subseq >string ] dip swap ]
    if ; 

: header-entry-size ( table-entry -- size )

;

: >>max-size ( decode-context new-size -- updated-context )
    drop ! minimial definition that should stack check.
    ;

: add-header-to-table ( decode-context header -- updated-context )
    drop ! minimial definition that should stack check.

    ;

: get-header-from-table ( decode-context table-index -- field )
    ! check bounds: i < len(static-table++decode-context) and i > 0
    dup pick dynamic-table>> length static-table length + < 
    over 0 > 
    and [ ] unless ! if not valid throw error TODO: add error
    dup static-table length <  ! check if in static table
    [ nip static-table nth ]
    [ static-table length - 1 - swap dynamic-table>> nth ]
    if ;

: decode-literal-header ( decode-context block index index-length -- decode-context block new-index field )
    decode-integer dup 0 = 
    [ ! string name
      drop decode-string
      [ decode-string ] dip
      swap 2array ]
    [ ! indexed name
      pickd get-header-from-table
      [ decode-string ] dip
      first swap 2array ]
    if ;

! block will be a byte array
:: decode-field ( decode-context block index -- updated-context block new-index field/f )
    {
        ! the action quote will leave the new context, the
        ! block, the consumed/new-index, and the field decoded or f
        
        ! indexed header field
        { [ index block nth 7 bit? ] [ decode-context
                block index 7 decode-integer 
                decode-context swap get-header-from-table ] } 
        ! Literal header field with incremental indexing
        { [ index block nth 6 bit? ] [ decode-context block
                index 6 decode-literal-header 
            /* TODO: add table modification effects! */ ] } 
        ! dynamic table size update
        { [ index block nth 5 bit? ] [ decode-context block
        index f /* action quote */ ] } ! TODO: actually modify the table
        ! literal header field without indexing
        [ decode-context block index 4 decode-literal-header ]
    } cond ;


PRIVATE>
! headers is a sequence of tuples represented the unencoded headers
! 
: hpack-encode ( encode-context headers -- updated-context block ) 
    [let V{} :> block!
    0
    [ dup block length < ]
    ! while the index is less than the length
    [ encode-field [ block swap suffix block! ] 
                   [ block empty? [] unless ] if* ]
    while
    2drop block
    ]
    ! convert block sequence into a bytestring for sending over http
    >byte-array
;


! should give the updated dtable, and the list of decoded
! header fields. block is the bytestring (byte array) for the header block
: hpack-decode ( decode-context block -- updated-context decoded )
    [let V{ } clone :> decoded-list!
    0 ! index in the block
    ! check that the block is longer than the index
    [ dup decoded-list length < ]
    ! call decode-field and add the (possibly) decoded field to the list
    ! (if the list has stuff, then we have to add...)
    ! TODO: throw error if the field is f when the decode list
    ! is nonempty
    [ decode-field [ decoded-list swap suffix decoded-list! ]
                   [ decoded-list empty? [ ] unless ] if* ]
! if the table was not empty, and we didn't get a header, throw an error. TODO: add error
    while
    2drop decoded-list
    ! double check the table size
    ]
    ;

