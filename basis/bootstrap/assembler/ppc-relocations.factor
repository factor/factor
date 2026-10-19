! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private compiler.codegen.relocation compiler.constants
kernel combinators cpu.ppc.relocation ;
IN: bootstrap.assembler.ppc

! Bootstrap templates supply their word/literal parameters when instantiated.
: jit-rel ( class type -- )
    {
        { rt-vm [ 0 swap rel-vm ] }
        { rt-entry-point [ f swap rel-word ] }
        { rt-entry-point-pic [ f swap rel-word-pic ] }
        { rt-entry-point-pic-tail [ f swap rel-word-pic-tail ] }
        { rt-this [ rel-this ] }
        { rt-literal [ f swap rel-literal ] }
        { rt-untagged [ f swap rel-untagged ] }
        { rt-dlsym [ [ f f ] dip rel-dlsym ] }
        { rt-here [ 0 swap rel-here ] }
        { rt-megamorphic-cache-hits [ rel-megamorphic-cache-hits ] }
    } case ;
: jit-vm ( offset class -- ) rel-vm ;
: jit-dlsym ( name class -- ) [ f ] dip rel-dlsym ;
: jit-dlsym-toc ( name class -- ) [ f ] dip rel-dlsym-toc ;
