USING: alien.c-types alien.data alien.syntax arrays combinators compiler.units
destructors io kernel libc math memory words ;
IN: s390x.callback.gc.smoke
LIBRARY: libc
CALLBACK: int gc-comparator ( void* a, void* b )
FUNCTION: void qsort ( void* base, size_t count, size_t size, gc-comparator comparator )
: callback-sort ( -- bytes )
    [
        B{ 0 0 0 3 0 0 0 1 0 0 0 2 } malloc-byte-array &free
        dup 3 4 [ gc [ int deref ] bi@ - ] gc-comparator qsort
        12 memory>byte-array
    ] with-destructors ;
{ (malloc) (free) memcpy qsort callback-sort } compile
callback-sort B{ 0 0 0 1 0 0 0 2 0 0 0 3 } =
[ "CALLBACK-GC-PASS" print ] [ "callback sort mismatch" throw ] if
