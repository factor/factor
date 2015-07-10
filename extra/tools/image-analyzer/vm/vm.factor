USING: alien.c-types assocs classes.struct kernel kernel.private vm ;
IN: tools.image-analyzer.vm

! These structs and words correspond to vm/image.hpp
STRUCT: image-header
    { magic cell }
    { version cell }
    { data-relocation-base cell }
    { data-size cell }
    { code-relocation-base cell }
    { code-size cell }
    { true-object cell }
    { bignum-zero cell }
    { bignum-pos-one cell }
    { bignum-neg-one cell }
    { special-objects cell[special-object-count] } ;

! These structs and words correspond to vm/layouts.hpp
STRUCT: object
    { header cell } ;

STRUCT: alien
    { header cell }
    { base cell }
    { expired cell }
    { displacement cell }
    { address cell } ;

STRUCT: array
    { header cell }
    { capacity cell } ;

STRUCT: bignum
    { header cell }
    { capacity cell } ;


STRUCT: callstack
    { header cell }
    { length cell } ;

STRUCT: dll
    { header cell }
    { path cell }
    { handle void* } ;

STRUCT: quotation
    { header cell }
    { array cell }
    { cached_effect cell }
    { cache_counter cell }
    { entry_point cell } ;

STRUCT: string
    { header cell }
    { length cell }
    { aux cell }
    { hashcode cell } ;

STRUCT: tuple
    { header cell }
    { layout cell } ;

STRUCT: tuple-layout
    { header cell }
    { capacity cell }
    { klass cell }
    { size cell }
    { echelon cell } ;

STRUCT: word
    { header cell }
    { hashcode cell }
    { name cell }
    { vocabulary cell }
    { def cell }
    { props cell }
    { pic_def cell }
    { pic_tail_def cell }
    { subprimitive cell }
    { entry_point cell } ;

STRUCT: wrapper
    { header cell }
    { object cell } ;

! These structs and words correspond to vm/code_blocks.hpp
STRUCT: code-block
    { header cell }
    { owner cell }
    { parameters cell }
    { relocation cell } ;
