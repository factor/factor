USING: alien alien.c-types classes classes.predicate kernel
math math.order words ;
IN: classes.c-types

PREDICATE: char < fixnum
    HEX: -80 HEX: 7f between? ;

PREDICATE: uchar < fixnum
    HEX: 0 HEX: ff between? ;

PREDICATE: short < fixnum
    HEX: -8000 HEX: 7fff between? ;

PREDICATE: ushort < fixnum
    HEX: 0 HEX: ffff between? ;

PREDICATE: int < integer
    HEX: -8000,0000 HEX: 7fff,ffff between? ;

PREDICATE: uint < integer
    HEX: 0 HEX: ffff,ffff between? ;

PREDICATE: longlong < integer
    HEX: -8000,0000,0000,0000 HEX: 7fff,ffff,ffff,ffff between? ;

PREDICATE: ulonglong < integer
    HEX: 0 HEX: ffff,ffff,ffff,ffff between? ;

SYMBOLS: long ulong ;

<<
    "long" heap-size 8 =
    [
        \  long integer [ HEX: -8000,0000,0000,0000 HEX: 7fff,ffff,ffff,ffff between? ] define-predicate-class
        \ ulong integer [ HEX:                    0 HEX: ffff,ffff,ffff,ffff between? ] define-predicate-class
    ] [
        \  long integer [ HEX: -8000,0000 HEX: 7fff,ffff between? ] define-predicate-class
        \ ulong integer [ HEX:          0 HEX: ffff,ffff between? ] define-predicate-class
    ] if
>>

: set-class-c-type ( class c-type -- )
    "class-c-type" set-word-prop ;

: class-c-type ( class -- c-type )
    "class-c-type" word-prop ;

alien        "void*"     set-class-c-type
\ f          "void*"     set-class-c-type
pinned-c-ptr "void*"     set-class-c-type
boolean      "bool"      set-class-c-type
char         "char"      set-class-c-type
uchar        "uchar"     set-class-c-type
short        "short"     set-class-c-type
ushort       "ushort"    set-class-c-type
int          "int"       set-class-c-type
uint         "uint"      set-class-c-type
long         "long"      set-class-c-type
ulong        "ulong"     set-class-c-type
longlong     "longlong"  set-class-c-type
ulonglong    "ulonglong" set-class-c-type
float        "double"    set-class-c-type

PREDICATE: c-type-class < class
    "class-c-type" word-prop ;

M: c-type-class c-type class-c-type c-type ;
M: c-type-class c-type-align class-c-type c-type-align ;
M: c-type-class c-type-getter class-c-type c-type-getter ;
M: c-type-class c-type-setter class-c-type c-type-setter ;
M: c-type-class c-type-boxer-quot class-c-type c-type-boxer-quot ;
M: c-type-class c-type-unboxer-quot class-c-type c-type-unboxer-quot ;
M: c-type-class heap-size class-c-type heap-size ;

