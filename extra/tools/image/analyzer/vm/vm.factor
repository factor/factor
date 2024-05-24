USING: alien.c-types assocs classes.struct kernel kernel.private vm ;
IN: tools.image.analyzer.vm

! These structs and words correspond to vm/image.hpp
STRUCT: image-header
    { magic cell_t }
    { version cell_t }
    { data-relocation-base cell_t }
    { data-size cell_t }
    { code-relocation-base cell_t }
    { code-size cell_t }
    { escaped-data-size cell_t }
    { compressed-data-size cell_t initial: 0 }
    { compressed-code-size cell_t initial: 0 }
    { reserved-4 cell_t }
    { special-objects cell_t[special-object-count] } ;

! These structs and words correspond to vm/layouts.hpp
STRUCT: object
    { header cell_t } ;

STRUCT: alien
    { header cell_t }
    { base cell_t }
    { expired cell_t }
    { displacement cell_t }
    { address cell_t } ;

STRUCT: array
    { header cell_t }
    { capacity cell_t } ;

STRUCT: bignum
    { header cell_t }
    { capacity cell_t } ;


STRUCT: callstack
    { header cell_t }
    { length cell_t } ;

STRUCT: dll
    { header cell_t }
    { path cell_t }
    { handle void* } ;

STRUCT: quotation
    { header cell_t }
    { array cell_t }
    { cached_effect cell_t }
    { cache_counter cell_t }
    { entry_point cell_t } ;

STRUCT: string
    { header cell_t }
    { length cell_t }
    { aux cell_t }
    { hashcode cell_t } ;

STRUCT: tuple
    { header cell_t }
    { layout cell_t } ;

STRUCT: tuple-layout
    { header cell_t }
    { capacity cell_t }
    { klass cell_t }
    { size cell_t }
    { echelon cell_t } ;

STRUCT: word
    { header cell_t }
    { hashcode cell_t }
    { name cell_t }
    { vocabulary cell_t }
    { def cell_t }
    { props cell_t }
    { pic_def cell_t }
    { pic_tail_def cell_t }
    { subprimitive cell_t }
    { entry_point cell_t } ;

STRUCT: wrapper
    { header cell_t }
    { object cell_t } ;

! These structs and words correspond to vm/code_blocks.hpp
STRUCT: code-block
    { header cell_t }
    { owner cell_t }
    { parameters cell_t }
    { relocation cell_t } ;

TUPLE: heap-node address object payload ;

TUPLE: code-heap-node < heap-node free? gc-maps ;
