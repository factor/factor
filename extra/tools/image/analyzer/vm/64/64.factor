USING: alien.c-types classes.struct vm ;
IN: tools.image.analyzer.vm.64

STRUCT: boxed-float
    { header cell_t }
    { n double } ;

STRUCT: byte-array
    { header cell_t }
    { capacity cell_t } ;
