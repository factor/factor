USING: alien.c-types classes.struct vm ;
IN: tools.image-analyzer.vm

STRUCT: boxed-float
    { header cell }
    { n double } ;

STRUCT: byte-array
    { header cell }
    { capacity cell } ;
