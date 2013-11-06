USING: assocs fry kernel math mirrors sequences splitting strings ;
IN: pcre.utils

: replace-all ( seq subseqs new -- seq )
    swapd '[ _ replace ] reduce ;

: split-subseqs ( seq subseqs -- seqs )
    dup first [ replace-all ] keep split-subseq [ >string ] map harvest ;

: 2with ( param1 param2 obj quot -- obj curry )
    [ -rot ] dip [ [ rot ] dip call ] 3curry ; inline

: gen-array-addrs ( base size n -- addrs )
    iota [ * + ] 2with map ;

: utf8-start-byte? ( byte -- ? )
    0xc0 bitand 0x80 = not ;

: next-utf8-char ( byte-array pos -- pos' )
    1 + 2dup swap ?nth
    [ utf8-start-byte? [ nip ] [ next-utf8-char ] if ] [ 2drop f ] if* ;
