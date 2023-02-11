! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: alien destructors help.markup help.syntax math ;
IN: memory.piles

HELP: <pile>
{ $values
    { "size" integer }
    { "pile" pile }
}
{ $description "Allocates " { $snippet "size" } " bytes of raw memory for a new " { $link pile } ". The pile should be " { $link dispose } "d when it is no longer needed." } ;

HELP: not-enough-pile-space
{ $values
    { "pile" pile }
}
{ $description "This error is thrown by " { $link pile-alloc } " when the " { $link pile } " does not have enough remaining space for the requested allocation." } ;

HELP: pile
{ $class-description "A " { $snippet "pile" } " is a block of raw memory that can be apportioned out in constant time. A pile is allocated using the " { $link <pile> } " word. Blocks of memory can be requested from the pile using " { $link pile-alloc } ", and all the pile's memory can be reclaimed with " { $link pile-empty } "." } ;

HELP: pile-align
{ $values
    { "pile" pile } { "align" "a power of two" }
}
{ $description "Adjusts a " { $link pile } "'s internal state so that the next call to " { $link pile-alloc } " will return a pointer aligned to " { $snippet "align" } " bytes relative to the pile's initial offset." } ;

HELP: pile-alloc
{ $values
    { "pile" pile } { "size" integer }
    { "alien" alien }
}
{ $description "Requests " { $snippet "size" } " bytes from a " { $link pile } ". If the pile does not have enough space to satisfy the request, a " { $link not-enough-pile-space } " error is thrown." } ;

HELP: <pile-c-array>
{ $values
    { "pile" pile } { "n" integer } { "c-type" "a C type" }
    { "alien" alien }
}
{ $description "Requests enough space from a " { $link pile } " to hold " { $snippet "n" } " values of " { $snippet "c-type" } ". If the pile does not have enough space to satisfy the request, a " { $link not-enough-pile-space } " error is thrown." } ;

HELP: <pile-c-object>
{ $values
    { "pile" pile } { "c-type" "a C type" }
    { "alien" alien }
}
{ $description "Requests enough space from a " { $link pile } " to hold a value of " { $snippet "c-type" } ". If the pile does not have enough space to satisfy the request, a " { $link not-enough-pile-space } " error is thrown." } ;

HELP: pile-empty
{ $values
    { "pile" pile }
}
{ $description "Reclaims all the memory allocated out of a " { $link pile } ". Allocations will resume from the beginning of the pile." } ;

ARTICLE: "memory.piles" "Piles"
"A " { $link pile } " is a block of raw memory. Portions of its memory can be allocated from the beginning of the pile in constant time, and the pile can be emptied and its pointer reset to the beginning."
{ $subsections
    <pile>
    pile-alloc
    <pile-c-array>
    <pile-c-object>
    pile-align
    pile-empty
}
"An example of the utility of piles is in video games. For example, the game Abuse was scripted with a Lisp dialect. In order to avoid stalls from traditional GC or heap-based allocators, the Abuse Lisp VM would allocate values from a preallocated pile over the course of a frame, and release the entire pile at the end of the frame." ;

ABOUT: "memory.piles"
