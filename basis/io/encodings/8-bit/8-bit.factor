! Copyright (C) 2008 Daniel Ehrenberg, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs biassocs kernel io.encodings math.parser
sequences hashtables io.encodings.ascii generic parser
classes.tuple words words.symbol io io.files splitting
namespaces math compiler.units accessors classes.singleton
classes.mixin io.encodings.iana fry simple-flat-file lexer ;
IN: io.encodings.8-bit

<PRIVATE

: encoding-file ( file-name -- stream )
    "vocab:io/encodings/8-bit/" ".TXT" surround ;

SYMBOL: 8-bit-encodings
8-bit-encodings [ H{ } clone ] initialize

TUPLE: 8-bit { biassoc biassoc read-only } ;

: 8-bit-encode ( char 8-bit -- byte )
    biassoc>> value-at [ encode-error ] unless* ; inline

M: 8-bit encode-char
    swap [ 8-bit-encode ] dip stream-write1 ;

M: 8-bit encode-string
    swap [ '[ _ 8-bit-encode ] B{ } map-as ] dip stream-write ;

M: 8-bit decode-char
    swap stream-read1 dup
    [ swap biassoc>> at [ replacement-char ] unless* ]
    [ 2drop f ]
    if ;

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
