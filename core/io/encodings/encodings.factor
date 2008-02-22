! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel sequences sbufs vectors namespaces
growable strings io classes continuations combinators
io.styles io.streams.plain io.encodings.binary splitting
io.streams.string io.streams.duplex ;
IN: io.encodings

! Decoding

TUPLE: decode-error ;

: decode-error ( -- * ) \ decode-error construct-empty throw ;

SYMBOL: begin

: push-decoded ( buf ch -- buf ch state )
    over push 0 begin ;

: push-replacement ( buf -- buf ch state )
    ! This is the replacement character
    HEX: fffd push-decoded ;

: finish-decoding ( buf ch state -- str )
    begin eq? [ decode-error ] unless drop "" like ;

: start-decoding ( seq length -- buf ch state seq )
    <sbuf> 0 begin roll ;

GENERIC: decode-step ( buf byte ch state encoding -- buf ch state )

: decode ( seq quot -- string )
    >r dup length start-decoding r>
    [ -rot ] swap compose each
    finish-decoding ; inline

: space ( resizable -- room-left )
    dup underlying swap [ length ] 2apply - ;

: full? ( resizable -- ? ) space zero? ;

: end-read-loop ( buf ch state stream quot -- string/f )
    2drop 2drop >string f like ;

: decode-read-loop ( buf ch state stream encoding -- string/f )
    >r >r pick r> r> rot full?  [ end-read-loop ] [
        over stream-read1 [
            -rot tuck >r >r >r -rot r> decode-step r> r> decode-read-loop
        ] [ end-read-loop ] if*
    ] if ;

: decode-read ( length stream encoding -- string )
    >r swap start-decoding r>
    decode-read-loop ;

TUPLE: decoded code cr ;
: <decoded> ( stream decoding-class -- decoded-stream )
    dup binary eq? [ drop ] [
        construct-empty { set-delegate set-decoded-code }
        decoded construct
    ] if ;

: cr+ t swap set-decoded-cr ; inline

: cr- f swap set-decoded-cr ; inline

: line-ends/eof ( stream str -- str ) f like swap cr- ; inline

: line-ends\r ( stream str -- str ) swap cr+ ; inline

: line-ends\n ( stream str -- str )
    over decoded-cr over empty? and
    [ drop dup cr- stream-readln ] [ swap cr- ] if ; inline

: handle-readln ( stream str ch -- str )
    {
        { f [ line-ends/eof ] }
        { CHAR: \r [ line-ends\r ] }
        { CHAR: \n [ line-ends\n ] }
    } case ;

: fix-read ( stream string -- string )
    over decoded-cr [
        over cr-
        "\n" ?head [
            swap stream-read1 [ add ] when*
        ] [ nip ] if
    ] [ nip ] if ;

M: decoded stream-read
    tuck { delegate decoded-code } get-slots decode-read fix-read ;

M: decoded stream-read-partial stream-read ;

: read-until-loop ( stream delim -- ch )
    ! Copied from { c-reader stream-read-until }!!!
    over stream-read1 dup [
        dup pick memq? [ 2nip ] [ , read-until-loop ] if
    ] [
        2nip
    ] if ;

M: decoded stream-read-until
    ! Copied from { c-reader stream-read-until }!!!
    [ swap read-until-loop ] "" make
    swap over empty? over not and [ 2drop f f ] when ;

: fix-read1 ( stream char -- char )
    over decoded-cr [
        over cr-
        dup CHAR: \n = [
            drop stream-read1
        ] [ nip ] if
    ] [ nip ] if ;

M: decoded stream-read1
    1 swap stream-read [ first ] [ f ] if* ;

M: decoded stream-readln ( stream -- str )
    "\r\n" over stream-read-until handle-readln ;

! Encoding

TUPLE: encode-error ;

: encode-error ( -- * ) \ encode-error construct-empty throw ;

TUPLE: encoded code ;
: <encoded> ( stream encoding-class -- encoded-stream )
    construct-empty { set-delegate set-encoded-code } encoded construct ;

GENERIC: encode-string ( string encoding -- byte-array )
M: tuple-class encode-string construct-empty encode-string ;

M: encoded stream-write1
    >r 1string r> stream-write ;

M: encoded stream-write
    [ encoded-code encode-string ] keep delegate stream-write ;

M: encoded dispose delegate dispose ;

INSTANCE: encoded plain-writer

! Rebinding duplex streams which have not read anything yet

: reencode ( stream encoding -- newstream )
    over encoded? [ >r delegate r> ] when <encoded> ;

: redecode ( stream encoding -- newstream )
    over decoded? [ >r delegate r> ] when <decoded> ;

: <encoded-duplex> ( duplex-stream encoding -- duplex-stream )
    swap { duplex-stream-in duplex-stream-out } get-slots
    pick reencode >r swap redecode r> <duplex-stream> ;
