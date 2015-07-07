USING: accessors  arrays assocs classes classes.struct io
locals math.bitwise namespaces sequences tools.image-analyzer.utils
tools.image-analyzer.vm vm ;
IN: tools.image-analyzer.data-heap-reader
FROM: alien.c-types => char heap-size ;
FROM: kernel => bi dup keep nip swap ;
FROM: layouts => data-alignment ;
FROM: math => + - * align neg shift ;

: object-tag ( vm-object -- tag )
    header>> 5 2 bit-range ;

GENERIC: read-payload ( rel-base struct -- tuple )

: remainder-padding ( payload-size vm-object -- n )
    class-heap-size + dup data-alignment get align swap - ;

: seek-past-padding ( payload-size vm-object -- )
    remainder-padding seek-relative seek-input ;

:: read-padded-payload ( count vm-object c-type -- payload )
    count c-type heap-size * :> payload-size
    payload-size [
        c-type read-bytes>array
    ] [ vm-object seek-past-padding ] bi ;

: read-array-payload ( vm-array -- payload )
    [ capacity>> -4 shift ] keep cell read-padded-payload ;

: read-char-payload ( n-bytes vm-object -- payload )
    char read-padded-payload ;

: read-no-payload ( vm-object -- payload )
    0 swap seek-past-padding { } ;

: layout-address ( rel-base vm-tuple -- address )
    layout>> 15 unmask - neg ;

M: array-payload read-payload ( rel-base vm-object -- payload )
    nip read-array-payload ;

M: no-payload read-payload ( rel-base vm-object -- payload )
    nip read-no-payload ;

M: byte-array read-payload ( rel-base vm-object -- payload )
    nip [ capacity>> -4 shift ] keep read-char-payload ;

M: string read-payload ( rel-base vm-string -- payload )
    nip [ length>> -4 shift ] keep read-char-payload ;

M: tuple read-payload ( rel-base vm-tuple -- payload )
    [
        [
            layout-address seek-absolute seek-input
            tuple-layout read-struct size>> -4 shift
        ] save-io-excursion
    ] keep cell read-padded-payload ;

: peek-read-object ( -- vm-base )
    [ object read-struct ] save-io-excursion ;

: (read-object) ( -- vm-object )
    peek-read-object object-tag tag>class read-struct ;

: read-object ( rel-base -- object )
    (read-object) [ read-payload ] keep swap 2array ;
