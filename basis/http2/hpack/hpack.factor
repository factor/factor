USING: accessors arrays byte-arrays byte-vectors combinators fry
http2.hpack.huffman io.encodings.string io.encodings.utf8 locals
kernel math math.functions math.bitwise multiline sequences ;

IN: http2.hpack

TUPLE: hpack-context
    { max-size integer initial: 4096 } { dynamic-table initial: { } } ;
    ! default the max size to 4096 according to RFC7540

ERROR: hpack-decode-error error-msg ;

<PRIVATE

! The static table for hpack compression/decompression
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

: dynamic-table-size ( decode-context -- table-size )
    [ header-size ] map sum
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

:: add-header-to-table ( decode-context header -- updated-context )
    decode-context dynamic-table>> decode-context max-size>>
    header header-size - shrink-dynamic-table
    header header-size decode-context max-size>> <= [ header prefix ] when
    decode-context swap >>dynamic-table
    ;

: set-dynamic-table-size ( decode-context new-size -- updated-decode-context )
    [ >>max-size ] keep
    [ dup dynamic-table>> ] dip shrink-dynamic-table >>dynamic-table
    ;

! check bounds: i < len(static-table++decode-context) and i > 0
: check-index-bounds ( decode-context index -- )
    [ nip 0 > ] [ swap dynamic-table>> length static-table length + < ] 2bi
    and [ "invalid index given" hpack-decode-error ] unless ! if not valid throw error
    ;

: get-header-from-table ( decode-context table-index -- field )
    [ check-index-bounds ] 2keep
    dup static-table length <  ! check if in static table
    [ static-table nth nip ]
    [ static-table length - swap dynamic-table>> nth ]
    if ;

: search-stable ( header -- perfect/f imperfect/f )
    static-table
    ;
: search-dtable ( header encode-context -- perfect index/f )
    ! index starts at 0
    dynamic-table>> 
    [ index ] 
    [ [ first ] dip [ first over = ] find ] 2bi
    ;


! assumes the first-byte respects the prefix-length, such that
! the last prefix-length bits are all 0.
: encode-integer ( first-byte int prefix-length -- bytes )
    2^ 1 - 2dup < 
    [ drop bitor 1byte-array ]
    [ swap over [ bitor 1byte-array >byte-vector ] [ - ] 2bi* 
      [ dup 128 >= ] [ [ 128 mod 128 + suffix ] [ 128 /i ] bi ]
      while suffix >byte-array
    ] if ;

! encodes a string without huffman encoding.
: encode-string ( string -- bytes )
    utf8 encode
    0 over length 7 encode-integer
    prepend
    ;

: encode-string-huffman ( string -- bytes )
    huffman-encode
    128 over length 7 encode-integer
    prepend
    ;

! headers will be a list of tuples
:: encode-field ( encode-context headers -- updated-context block )
        ! first search if the header is in the header table
        encode-context name search-table
        ! TODO if not encode it as a literal and then add it to table 
        [  ]
        ! TODO if in table, if perfect match, use it, else, use indexed literal
        ;   

: decode-integer-fragment ( block index I M -- block index+1 I' M+7 block[index+1] )
    ! increment index and get block[index]
    [ 1 + 2dup swap nth ] 2dip
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
    [ encode-field ] map concat
    ! convert block sequence into a bytestring for sending over http
    >byte-array
;


! should give the updated dtable, and the list of decoded
! header fields. block is the bytestring (byte array) for the header block
: hpack-decode ( decode-context block -- updated-context decoded )
    [let V{ } clone :> decoded-list!
    0 ! index in the block
    [ 2dup swap length < ] ! check that the block is longer than the index
    ! call decode-field and add the (possibly) decoded field to the list
    [ decode-field [ decoded-list swap suffix decoded-list! ]
                   [ decoded-list [ "Table size update not at start of header block"
                   hpack-decode-error ] unless-empty ] if* ]
    ! if the table was not empty, and we didn't get a header, throw an error.
    while
    2drop decoded-list >array
    ! double check the header list size?
    ]
    ;

