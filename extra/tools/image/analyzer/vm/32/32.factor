USING: alien.c-types classes.struct vm ;
IN: tools.image.analyzer.vm.32

STRUCT: boxed-float
    { header cell_t }
    { padding cell_t }
    { n double } ;

STRUCT: byte-array
    { header cell_t }
    { capacity cell_t }
    { padding0 cell_t }
    { padding1 cell_t } ;
