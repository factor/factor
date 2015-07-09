USING: accessors  arrays assocs classes classes.struct io
locals math.bitwise namespaces sequences tools.image-analyzer.utils
tools.image-analyzer.vm vm ;
IN: tools.image-analyzer.data-heap-reader
FROM: alien.c-types => char heap-size ;
FROM: kernel => bi dup keep nip swap ;
FROM: layouts => data-alignment ;
FROM: math => + - * align neg shift ;

: object-tag ( object -- tag )
    header>> 5 2 bit-range ;

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
    [ capacity>> -4 shift ] keep cell read-padded-payload ;

: read-char-payload ( n-bytes object -- payload )
    char read-padded-payload ;

: read-no-payload ( object -- payload )
    0 swap seek-past-padding { } ;

: layout-address ( rel-base tuple -- address )
    layout>> 15 unmask - neg ;

M: array-payload read-payload ( rel-base object -- payload )
    nip read-array-payload ;

M: no-payload read-payload ( rel-base object -- payload )
    nip read-no-payload ;

M: byte-array read-payload ( rel-base object -- payload )
    nip [ capacity>> -4 shift ] keep read-char-payload ;

M: callstack read-payload ( rel-base object -- payload )
    nip [ length>> -4 shift ] keep read-char-payload ;

M: string read-payload ( rel-base string -- payload )
    nip [ length>> -4 shift ] keep read-char-payload ;

M: tuple read-payload ( rel-base tuple -- payload )
    [
        [
            layout-address seek-absolute seek-input
            tuple-layout read-struct size>> -4 shift
        ] save-io-excursion
    ] keep cell read-padded-payload ;

: peek-read-object ( -- object )
    [ object read-struct ] save-io-excursion ;

: (read-object) ( -- object )
    peek-read-object object-tag tag>class read-struct ;

: read-object ( rel-base -- object )
    (read-object) [ read-payload ] keep swap 2array ;
