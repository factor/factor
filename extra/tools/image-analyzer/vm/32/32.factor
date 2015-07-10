USING: alien.c-types classes.struct vm ;
IN: tools.image-analyzer.vm.32

STRUCT: boxed-float
    { header cell }
    { padding cell }
    { n double } ;

STRUCT: byte-array
    { header cell }
    { capacity cell }
    { padding0 cell }
    { padding1 cell } ;
