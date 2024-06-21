USING: accessors assocs classes.struct io kernel locals math.bitwise
namespaces system tools.image.analyzer.utils tools.image.analyzer.vm
vm vocabs.parser ;
IN: tools.image.analyzer.data-heap-reader
FROM: alien.c-types => uchar heap-size ;
FROM: arrays => 2array ;
FROM: kernel => ? boa bi dup keep nip swap ;
FROM: layouts => data-alignment ;
FROM: math => + - * align neg shift ;

<<
! For the two annoying structs that differ on 32 and 64 bit.
cpu x86.32?
"tools.image.analyzer.vm.32"
"tools.image.analyzer.vm.64"
? use-vocab
>>

: tag>class ( tag -- class )
    {
        { 2 array }
        { 3 boxed-float }
        { 4 quotation }
        { 5 bignum }
        { 6 alien }
        { 7 tuple }
        { 8 wrapper }
        { 9 byte-array }
        { 10 callstack }
        { 11 string }
        { 12 word }
        { 13 dll }
    } at ;

: object-tag ( object -- tag )
    header>> 5 2 bit-range ;

UNION: no-payload
    alien
    boxed-float
    dll
    quotation
    wrapper
    word ;

UNION: array-payload
    array
    bignum ;

GENERIC: read-payload ( rel-base struct -- tuple )

: remainder-padding ( payload-size object -- n )
    class-heap-size + dup data-alignment get align swap - ;

: seek-past-padding ( payload-size object -- )
    remainder-padding seek-relative seek-input ;

:: read-padded-payload ( count object c-type -- payload )
    count c-type heap-size * :> payload-size
    payload-size [
        c-type read-bytes>array
    ] [ object seek-past-padding ] bi ;

: read-array-payload ( array -- payload )
    [ capacity>> -4 shift ] keep cell_t read-padded-payload ;

: read-uchar-payload ( n-bytes object -- payload )
    uchar read-padded-payload ;

: read-no-payload ( object -- payload )
    0 swap seek-past-padding { } ;

: layout-address ( rel-base tuple -- address )
    layout>> untag - neg ;

M: array-payload read-payload ( rel-base object -- payload )
    nip read-array-payload ;

M: no-payload read-payload ( rel-base object -- payload )
    nip read-no-payload ;

M: byte-array read-payload ( rel-base object -- payload )
    nip [ capacity>> -4 shift ] keep read-uchar-payload ;

M: callstack read-payload ( rel-base object -- payload )
    nip [ length>> -4 shift ] keep read-uchar-payload ;

M: string read-payload ( rel-base string -- payload )
    nip [ length>> -4 shift ] keep read-uchar-payload ;

M: tuple read-payload ( rel-base tuple -- payload )
    [
        [
            layout-address seek-absolute seek-input
            tuple-layout read-struct size>> -4 shift
        ] save-io-excursion
    ] keep cell_t read-padded-payload ;

: peek-read-object ( -- object )
    [ object read-struct ] save-io-excursion ;

: (read-object) ( -- object )
    peek-read-object object-tag tag>class read-struct ;

: read-object ( rel-base -- object )
    tell-input swap (read-object) [ read-payload ] 1check heap-node boa ;
