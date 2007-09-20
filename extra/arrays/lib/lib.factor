
USING: kernel arrays sequences sequences.private macros ;

IN: arrays.lib

MACRO: narray ( n -- quot )
    dup [ f <array> ] curry
    swap <reversed> [
        [ swap [ set-nth-unsafe ] keep ] curry
    ] map concat append ;
