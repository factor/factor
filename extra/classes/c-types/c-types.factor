! (c)Joe Groff bsd license
USING: alien alien.c-types classes classes.predicate kernel
math math.bitwise math.order namespaces sequences words
specialized-arrays.direct.alien
specialized-arrays.direct.bool
specialized-arrays.direct.char
specialized-arrays.direct.complex-double
specialized-arrays.direct.complex-float
specialized-arrays.direct.double
specialized-arrays.direct.float
specialized-arrays.direct.int
specialized-arrays.direct.long
specialized-arrays.direct.longlong
specialized-arrays.direct.short
specialized-arrays.direct.uchar
specialized-arrays.direct.uint
specialized-arrays.direct.ulong
specialized-arrays.direct.ulonglong
specialized-arrays.direct.ushort ;
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

UNION: single-float float ;
UNION: single-complex complex ;

SYMBOLS: long ulong long-bits ;

<<
    "long" heap-size 8 =
    [
        \  long integer [ HEX: -8000,0000,0000,0000 HEX: 7fff,ffff,ffff,ffff between? ] define-predicate-class
        \ ulong integer [ HEX:                    0 HEX: ffff,ffff,ffff,ffff between? ] define-predicate-class
        64 \ long-bits set-global
    ] [
        \  long integer [ HEX: -8000,0000 HEX: 7fff,ffff between? ] define-predicate-class
        \ ulong integer [ HEX:          0 HEX: ffff,ffff between? ] define-predicate-class
        32 \ long-bits set-global
    ] if
>>

: set-class-c-type ( class initial c-type <direct-array> -- )
    [ "initial-value" set-word-prop ]
    [ c-type "class-c-type" set-word-prop ]
    [ "class-direct-array" set-word-prop ] tri-curry* tri ;

: class-c-type ( class -- c-type )
    "class-c-type" word-prop ;
: class-direct-array ( class -- <direct-array> )
    "class-direct-array" word-prop ;

\ f            f            "void*"          \ <direct-void*-array>          set-class-c-type
pinned-c-ptr   f            "void*"          \ <direct-void*-array>          set-class-c-type
boolean        f            "bool"           \ <direct-bool-array>           set-class-c-type
char           0            "char"           \ <direct-char-array>           set-class-c-type
uchar          0            "uchar"          \ <direct-uchar-array>          set-class-c-type
short          0            "short"          \ <direct-short-array>          set-class-c-type
ushort         0            "ushort"         \ <direct-ushort-array>         set-class-c-type
int            0            "int"            \ <direct-int-array>            set-class-c-type
uint           0            "uint"           \ <direct-uint-array>           set-class-c-type
long           0            "long"           \ <direct-long-array>           set-class-c-type
ulong          0            "ulong"          \ <direct-ulong-array>          set-class-c-type
longlong       0            "longlong"       \ <direct-longlong-array>       set-class-c-type
ulonglong      0            "ulonglong"      \ <direct-ulonglong-array>      set-class-c-type
float          0.0          "double"         \ <direct-double-array>         set-class-c-type
single-float   0.0          "float"          \ <direct-float-array>          set-class-c-type
complex        C{ 0.0 0.0 } "complex-double" \ <direct-complex-double-array> set-class-c-type
single-complex C{ 0.0 0.0 } "complex-float"  \ <direct-complex-float-array>  set-class-c-type

char      [  8 bits  8 >signed ] "coercer" set-word-prop
uchar     [  8 bits            ] "coercer" set-word-prop
short     [ 16 bits 16 >signed ] "coercer" set-word-prop
ushort    [ 16 bits            ] "coercer" set-word-prop
int       [ 32 bits 32 >signed ] "coercer" set-word-prop
uint      [ 32 bits            ] "coercer" set-word-prop
long      [ [ bits ] [ >signed ] ] long-bits get-global prefix "coercer" set-word-prop
ulong     [   bits               ] long-bits get-global prefix "coercer" set-word-prop
longlong  [ 64 bits 64 >signed ] "coercer" set-word-prop
ulonglong [ 64 bits            ] "coercer" set-word-prop

PREDICATE: c-type-class < class
    "class-c-type" word-prop ;

GENERIC: direct-array-of ( alien len class -- array ) inline

M: c-type-class direct-array-of
    class-direct-array execute( alien len -- array ) ; inline

M: c-type-class c-type class-c-type ;
M: c-type-class c-type-align class-c-type c-type-align ;
M: c-type-class c-type-getter class-c-type c-type-getter ;
M: c-type-class c-type-setter class-c-type c-type-setter ;
M: c-type-class c-type-boxer-quot class-c-type c-type-boxer-quot ;
M: c-type-class c-type-unboxer-quot class-c-type c-type-unboxer-quot ;
M: c-type-class heap-size class-c-type heap-size ;

