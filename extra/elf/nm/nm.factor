! Copyright (C) 2010 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators elf formatting io.mmap kernel sequences ;
IN: elf.nm

: print-symbol ( sections symbol -- )
    [ sym>> st_value>> "%016x " printf ]
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

: elf-nm ( path -- )
    [
        sections dup ".symtab" find-section
        symbols [ name>> empty? ] reject
        [ print-symbol ] with each
    ] with-mapped-elf ;
