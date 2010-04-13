! Copyright (C) 2010 Erik Charlebois.
! See http://factorcode.org/license.txt for BSD license.
USING: elf help.markup help.syntax ;
IN: elf.nm

HELP: nm
{ $values
    { "path" "a pathname string" }
}
{ $description "Prints information about the symbols in the ELF object at the given path." } ;

HELP: print-symbol
{ $values
    { "sections" "sequence of section" } { "symbol" symbol }
}
{ $description "Prints the value, section and name of the given symbol." } ;

ARTICLE: "elf.nm" "ELF nm"
{ $description "Utility to print the values, sections and names of the symbols in a given ELF file. In an ELF executable or shared library, the symbol values are typically their virtual addresses. In a relocatable ELF object, they are section-relative offsets." }
;

ABOUT: "elf.nm"
