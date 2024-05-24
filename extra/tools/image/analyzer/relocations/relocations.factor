USING: alien.c-types alien.data assocs combinators.smart
compiler.constants kernel layouts math sequences vm ;
IN: tools.image.analyzer.relocations

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

: decode-relative-relocation ( address byte-array relocation -- value )
    third [ [ 4 - ] keep rot subseq int cast-array first ] keep + + ;

: decode-absolute-relocation ( byte-array relocation -- value )
    third [ cell - ] keep rot subseq cell_t cast-array first ;

: interesting-relocation? ( relocation -- ? )
    first { 1 2 3 6 } member? ;

: decode-relocation ( address byte-array relocation -- value )
    dup second rc-relative = [ decode-relative-relocation ] [
        decode-absolute-relocation nip
    ] if ;
