! Copyright (C) 2008 Daniel Ehrenberg, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: math.parser arrays io.encodings sequences kernel assocs
hashtables io.encodings.ascii generic parser classes.tuple words
words.symbol io io.files splitting namespaces math
compiler.units accessors classes.singleton classes.mixin
io.encodings.iana fry simple-flat-file lexer ;
IN: io.encodings.8-bit

<PRIVATE

: encoding-file ( file-name -- stream )
    "vocab:io/encodings/8-bit/" ".TXT" surround ;

SYMBOL: 8-bit-encodings
8-bit-encodings [ H{ } clone ] initialize

TUPLE: 8-bit biassoc ;

: encode-8-bit ( char stream assoc -- )
    swapd value-at
    [ swap stream-write1 ] [ encode-error ] if* ; inline

M: 8-bit encode-char biassoc>> encode-8-bit ;

: decode-8-bit ( stream assoc -- char/f )
    swap stream-read1
    [ swap at [ replacement-char ] unless* ]
    [ drop f ] if* ; inline

M: 8-bit decode-char biassoc>> decode-8-bit ;

MIXIN: 8-bit-encoding

M: 8-bit-encoding <encoder>
    8-bit-encodings get-global at <encoder> ;

M: 8-bit-encoding <decoder>
    8-bit-encodings get-global at <decoder> ;

: create-encoding ( name -- word )
    create-in
    [ define-singleton-class ]
    [ 8-bit-encoding add-mixin-instance ]
    [ ] tri ;

: load-encoding ( name iana-name file-name -- )
    [ create-encoding dup ]
    [ register-encoding ]
    [ encoding-file flat-file>biassoc 8-bit boa ] tri*
    swap 8-bit-encodings get-global set-at ;

PRIVATE>

SYNTAX: 8-BIT: scan scan scan load-encoding ;
