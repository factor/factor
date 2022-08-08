USING: accessors arrays byte-arrays byte-vectors combinators
http2.hpack.huffman io.encodings.string io.encodings.utf8 kernel
math math.bitwise multiline sequences ;

IN: http2.hpack

TUPLE: hpack-context
    { max-size integer initial: 4096 } { dynamic-table initial: { } } ;
    ! default the max size to 4096 according to RFC7540

ERROR: hpack-decode-error error-msg ;

<PRIVATE

! The static table for hpack compression/decompression,
! from RFC 7541, Appendix A.
CONSTANT: static-table {
    { f f } ! allows indexing to work out properly
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

: header-size ( header -- size )
    sum-lengths 32 +
    ;

! gives the index in the dynamic table such that the sum of the
! size of the elements before the index is less than or equal to
! the desired-size, or f if no entries need to be removed to
! attain the desired size
:: dynamic-table-remove-index ( dynamic-table desired-size -- i/f )
    0 dynamic-table [ header-size + dup desired-size >= ] find drop nip
    ;

! shrinks the dynamic table size to the given size (size, *not*
! length) (doesn't affect the max-size of the context)
: shrink-dynamic-table ( dynamic-table shrink-to -- shrunk-dynamic-table )
    dupd dynamic-table-remove-index [ head ] when*
    ;

:: add-header-to-table ( hpack-context header -- updated-context )
    hpack-context dynamic-table>> hpack-context max-size>>
    header header-size - shrink-dynamic-table
    header header-size hpack-context max-size>> <= [ header prefix ] when
    hpack-context swap >>dynamic-table
    ;

: set-dynamic-table-size ( hpack-context new-size -- updated-decode-context )
    [ >>max-size ] keep
    [ dup dynamic-table>> ] dip shrink-dynamic-table >>dynamic-table
    ;

! check bounds: i < len(static-table++decode-context) and i > 0
: check-index-bounds ( index decode-context -- )
    [ drop 0 > ] [ dynamic-table>> length static-table length + < ] 2bi
    and [ "invalid index given" hpack-decode-error ] unless ! if not valid throw error
    ;

: get-header-from-table ( hpack-context table-index -- field )
    [ swap check-index-bounds ] 2keep
    dup static-table length <  ! check if in static table
    [ static-table nth nip ]
    [ static-table length - swap dynamic-table>> nth ]
    if ;

: search-imperfect ( header table -- imperfect/f )
    swap first '[ _ first = ] find drop
    ;

: search-given-table ( header table -- imperfect/f perfect/f )
    [ search-imperfect ] [ index ] 2bi
    ;

: correct-dynamic-index ( dynamic-index/f -- whole-table-index/f )
    [ static-table length + ] [ f ] if*
    ;

: search-static-table ( header -- imperfect/f perfect/f )
    static-table search-given-table ;

: search-dynamic-table ( header hpack-context --  imperfect/f perfect/f )
    dynamic-table>> search-given-table
    [ correct-dynamic-index ] bi@
    ;

: search-table ( header hpack-context -- imperfect/f perfect/f )
    [ drop search-static-table ] [ search-dynamic-table ] 2bi
    ! combine results from static and dynamic tables
    swapd [ or ] 2bi@
    ;


! assumes the first-byte respects the prefix-length, such that
! the last prefix-length bits are all 0.
: encode-integer ( first-byte int prefix-length -- bytes )
    2^ 1 - 2dup < 
    [ drop bitor 1byte-array ]
    [ tuck [ bitor 1byte-array >byte-vector ] [ - ] 2bi*
      [ dup 128 >= ] [ [ 128 mod 128 + over push ] [ 128 /i ] bi ]
      while over push >byte-array
    ] if ;

! encodes a string without huffman encoding.
: encode-string-raw ( string -- bytes )
    utf8 encode
    0 over length 7 encode-integer
    prepend
    ;

: encode-string-huffman ( string -- bytes )
    huffman-encode
    128 over length 7 encode-integer
    prepend
    ;

:: encode-field ( encode-context header -- updated-context block )
    header encode-context search-table
    [ 128 swap 7 encode-integer encode-context swap nipd ]
    [ [ 64 swap 6 encode-integer ]
      [ 64 0 6 encode-integer header first encode-string-huffman append
        ] if* 
        header second encode-string-huffman append
        encode-context header add-header-to-table swap ]
    if*
    ;   

! /*
! version of decode integer that tries to be clever for less
! stack stuff, but not sure if it actually is...
:: decode-integer ( block current-index prefix-length -- block new-index number )
    current-index 1 + :> end-index!
    current-index block nth prefix-length 2^ 1 - [ mask ] keep over =
    [
        current-index 1 + block [ 7 bit? not ] find-from drop 1 + end-index!
        current-index 1 + end-index block subseq reverse
        0 [ 127 mask swap 128 * + ] reduce
        +
    ] when
    [ block end-index ] dip ; ! */

/*
! initial version of decode-integer, which closely follows the
! pseudocode from the rfc (RFC 7541, section 5.1)
: decode-integer-fragment ( block index I M -- block index+1 I' M+7 block[index+1] )
    ! increment index and get block[index]
    [ 1 + 2dup swap nth ] 2dip
    ! stack: block index+1 block[index+1] I M
    ! compute I' = (block[index+1] & 127) * 2^M + I
    pick 127 mask 2 pick ^ * '[ _ + ] dip
    7 + rot ;

: decode-integer ( block current-index prefix-length -- block new-index number )
    ! get the current octet, compute mask, apply mask
    [ 2dup swap nth ] dip 2^ 1 - [ mask ] keep
    over = 
    ! stack: block index I loop?
    [ 0
      [ 7 bit? ] [ decode-integer-fragment ] do while 
      ! stack: block index I M, get rid of M, we don't need it
      drop ]
    when ! the prefix matches the mask (exactly all 1s), must loop
    [ 1 + ] dip ! increment the index before return
    ; ! */

: decode-raw-string ( block current-index string-length -- block new-index string )
    over + dup [ pick subseq utf8 decode ] dip swap ;

: decode-huffman-string ( block current-index string-length -- block new-index string )
    over + dup [ pick subseq huffman-decode ] dip swap 
    ;

: decode-string ( block current-index -- block new-index string )
    [ 7 decode-integer ] [ swap nth 7 bit? ] 2bi
    [ decode-huffman-string ] [ decode-raw-string ] if ; 

: decode-literal-header ( decode-context block index index-length -- decode-context block new-index field )
    decode-integer
    ! string name if 0, else indexed
    [ decode-string ] [ pickd get-header-from-table first ] if-zero
    [ decode-string ] dip swap 2array
    ;

! block will be a byte array
:: decode-field ( decode-context block index -- updated-context block new-index field/f )
    decode-context block index
    {
        ! indexed header field
        { [ index block nth 7 bit? ] [ 7 decode-integer 
                decode-context swap get-header-from-table ] } 
        ! Literal header field with incremental indexing
        { [ index block nth 6 bit? ] [ 6 decode-literal-header 
                [ 2nip add-header-to-table ] 3keep ] } 
        ! dynamic table size update
        { [ index block nth 5 bit? ] [ 5 decode-integer -rot f
                [ set-dynamic-table-size ] 3dip ] }
        ! literal header field without indexing
        [ 4 decode-literal-header ]
    } cond ;

PRIVATE>

! headers is a sequence of tuples represented the unencoded headers
: hpack-encode ( encode-context headers -- updated-context block ) 
    [ encode-field ] map concat ;


! should give the updated dtable, and the list of decoded
! header fields. block is the bytestring (byte array) for the header block
: hpack-decode ( decode-context block -- updated-context decoded )
    [let V{ } clone :> decoded-list
    0 ! index in the block
    [ 2dup swap length < ] ! check that the block is longer than the index
    ! call decode-field and add the (possibly) decoded field to the list
    [ decode-field [ decoded-list push ]
                   [ decoded-list [ "Table size update not at start of header block"
                   hpack-decode-error ] unless-empty ] if* ]
    ! if the table was not empty, and we didn't get a header, throw an error.
    while
    2drop decoded-list >array
    ! double check the header list size?
    ] ;

