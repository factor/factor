USING: alien.c-types alien.data assocs combinators.smart kernel math
sequences ;
IN: tools.image-analyzer.relocations

CONSTANT: rel-params {
    { 9 1 }
    { 0 2 } { 13 2 }
}

: rel-type ( uint -- type )
    -28 shift 0xf bitand ;

: rel-class ( uint -- class )
    -24 shift 0xf bitand ;

: rel-offset ( uint -- offset )
    0xffffff bitand ;

: rel-nr-params ( uint -- n )
    rel-params at 0 or ;

: uint>relocation ( uint -- relocation )
    { [ rel-type ] [ rel-class ] [ rel-offset ] [ rel-nr-params ] }
    cleave>array ;

: byte-array>relocations ( byte-array -- relocations )
    uint cast-array [ uint>relocation ] { } map-as ;

: load-relative-value ( byte-array relocation -- value )
    third [ [ 4 - ] keep rot subseq int cast-array first ] keep + ;
