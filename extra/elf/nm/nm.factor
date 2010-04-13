! Copyright (C) 2010 Erik Charlebois.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators elf formatting io.mmap kernel sequences ;
IN: elf.nm

: print-symbol ( sections symbol -- )
    [ sym>> st_value>> "%016d " printf ]
    [
        sym>> st_shndx>>
        {
            { SHN_UNDEF [ drop "undefined" ] }
            { SHN_ABS [ drop "absolute" ] }
            { SHN_COMMON [ drop "common" ] }
            [ swap nth name>> ]
        } case "%-16s " printf
    ]
    [ name>> "%s\n" printf ] tri ;
    
: nm ( path -- )
    [
        address>> <elf> sections
        dup ".symtab" find-section
        symbols [ name>> empty? not ] filter
        [ print-symbol ] with each
    ] with-mapped-file ;
