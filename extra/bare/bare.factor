! Copyright (C) 2022 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs combinators endian hashtables io
io.encodings.binary io.encodings.string io.encodings.utf8
io.files io.streams.byte-array kernel math math.bitwise
math.order math.parser multiline namespaces parser peg.ebnf
sequences sets strings words words.constant ;

IN: bare

! types

SINGLETONS: uint ;
SINGLETONS: int ;
SINGLETONS: u8 u16 u32 u64 ;
SINGLETONS: i8 i16 i32 i64 ;
SINGLETONS: f32 f64 ;
SINGLETONS: bool ;
SINGLETONS: str ;
TUPLE: data length ;
SINGLETONS: void ;
TUPLE: enum values ;
TUPLE: optional type ;
TUPLE: list type length ;
TUPLE: map from to ;
TUPLE: union members ;
TUPLE: struct fields ;
TUPLE: schema types ;

! errors

ERROR: invalid-length length ;
ERROR: invalid-enum value ;
ERROR: invalid-union value ;
ERROR: unknown-type name ;
ERROR: duplicate-keys keys ;
ERROR: duplicate-values values ;
ERROR: not-enough-entries ;
ERROR: cannot-be-void type ;

<PRIVATE

: check-length ( length/f -- length/f )
    dup [ 1 64 on-bits between? [ invalid-length ] unless ] when* ;

: check-duplicate-keys ( alist -- alist )
    dup keys duplicates [ duplicate-keys ] unless-empty ;

: check-duplicate-values ( alist -- alist )
    dup H{ } clone [ '[ _ push-at ] assoc-each ] keep
    [ nip length 1 > ] { } assoc-filter-as
    [ duplicate-values ] unless-empty ;

: check-duplicates ( alist -- alist )
    check-duplicate-keys check-duplicate-values ;

: assign-values ( alist -- alist' )
    0 swap [ rot or dup 1 + -rot ] assoc-map nip ;

: check-entries ( alist -- alist )
    dup assoc-empty? [ not-enough-entries ] when ;

: check-void ( type -- type )
    dup void? [ cannot-be-void ] when ;

PRIVATE>

! constructors

: <data> ( length -- data )
    check-length data boa ;

: <enum> ( values -- enum )
    assign-values check-duplicates check-entries enum boa ;

: <optional> ( type -- optional )
    check-void optional boa ;

: <list> ( type length -- list )
    [ check-void ] [ check-length ] bi* list boa ;

: <map> ( from to -- map )
    ! XXX: check key types?
    [ check-void ] bi@ map boa ;

: <union> ( members -- union )
    assign-values check-duplicates check-entries union boa ;

: <struct> ( fields -- struct )
    check-duplicate-keys check-entries
    dup [ check-void 2drop ] assoc-each struct boa ;

: <schema> ( types -- schema )
    check-entries schema boa ;

! main interface

GENERIC: read-bare ( schema -- obj )

GENERIC: write-bare ( obj schema -- )

: bare> ( encoded schema -- obj )
    swap binary [ read-bare ] with-byte-reader ;

: >bare ( obj schema -- encoded )
    binary [ write-bare ] with-byte-writer ;

! writing implementation

M: uint write-bare
    drop [ dup 0x80 >= ] [
        [ 0x7f bitand 0x80 bitor write1 ] [ -7 shift ] bi
    ] while write1 ;

M: int write-bare
    drop 2 * dup 0 < [ neg 1 - ] when uint write-bare ;

M: u8 write-bare drop write1 ;
M: u16 write-bare drop 2 >le write ;
M: u32 write-bare drop 4 >le write ;
M: u64 write-bare drop 8 >le write ;

M: i8 write-bare drop 1 >le write ;
M: i16 write-bare drop 2 >le write ;
M: i32 write-bare drop 4 >le write ;
M: i64 write-bare drop 8 >le write ;

M: f32 write-bare drop float>bits u32 write-bare ;
M: f64 write-bare drop double>bits u64 write-bare ;

M: bool write-bare drop >boolean 1 0 ? u8 write-bare ;

M: str write-bare drop utf8 encode T{ data } write-bare ;

M: data write-bare
    length>> [ dup length uint write-bare ] unless write ;

M: void write-bare 2drop ;

M: enum write-bare
    values>> ?at [ uint write-bare ] [ invalid-enum ] if ;

M: optional write-bare
    over 1 0 ? u8 write-bare
    '[ _ type>> write-bare ] when* ;

M: list write-bare
    [ length>> [ dup length uint write-bare ] unless ]
    [ type>> '[ _ write-bare ] each ] bi ;

M: map write-bare
    over assoc-size uint write-bare
    [ from>> ] [ to>> ] bi [ write-bare ] bi-curry@
    '[ _ _ bi* ] assoc-each ;

! XXX: M: union write-bare

M: struct write-bare
    fields>> [ [ dupd of ] [ write-bare ] bi* ] assoc-each drop ;

! reading implementation

M: uint read-bare
    drop 0 0 [
        read1
        [ 0x7f bitand rot [ 7 * shift bitor ] keep 1 + swap ]
        [ 0x80 bitand zero? not ] bi
    ] loop nip ;

M: int read-bare
    drop uint read-bare dup odd? [ 1 + neg ] when 2 /i ;

M: u8 read-bare drop read1 ;
M: u16 read-bare drop 2 read le> ;
M: u32 read-bare drop 4 read le> ;
M: u64 read-bare drop 8 read le> ;

M: i8 read-bare drop 1 read signed-le> ;
M: i16 read-bare drop 2 read signed-le> ;
M: i32 read-bare drop 4 read signed-le> ;
M: i64 read-bare drop 8 read signed-le> ;

M: f32 read-bare drop 4 read le> bits>float ;
M: f64 read-bare drop 8 read le> bits>double ;

M: bool read-bare
    drop read1 {
        { 0 [ f ] }
        { 1 [ t ] }
        [ throw ]
    } case ;

M: str read-bare drop T{ data } read-bare utf8 decode ;

M: data read-bare
    length>> [ read ] [ uint read-bare read ] if* ;

M: void read-bare drop f ; ! XXX: this isn't right

M: enum read-bare
    [ uint read-bare ] dip values>> ?value-at
    [ invalid-enum ] unless ;

M: optional read-bare
    u8 read-bare 1 = [ type>> read-bare ] [ drop f ] if ;

M: list read-bare
    [ length>> [ uint read-bare ] unless* ]
    [ type>> '[ _ read-bare ] replicate ] bi ;

M: map read-bare
    [ uint read-bare ] dip [ from>> ] [ to>> ] bi
    '[ _ _ [ read-bare ] bi@ 2array ] replicate ;

M: union read-bare
    [ uint read-bare ] dip members>> ?value-at
    [ read-bare ] [ invalid-union ] if ;

M: struct read-bare
    fields>> [ read-bare ] assoc-map ;

! schema

<PRIVATE

SYMBOL: user-types

: lookup-user-type ( name -- type )
    user-types get ?at [ unknown-type ] unless ;

: insert-user-type ( name type -- )
    swap user-types [ ?set-at ] change ;

EBNF: (parse-schema) [=[

space     = [ \t\n]
comment   = "#" [^\n]* "\n"?
ws        = ((space | comment)*)~
upper     = [A-Z]
alpha     = [A-Za-z]
digit     = [0-9]
number    = digit+                         => [[ string>number ]]

length    = ws "["~ ws number ws "]"~
value     = ws "="~ ws number

type      = ws "<"~ ws any-type ws ">"~

uint      = "uint"                         => [[ uint ]]
u8        = "u8"                           => [[ u8 ]]
u16       = "u16"                          => [[ u16 ]]
u32       = "u32"                          => [[ u32 ]]
u64       = "u64"                          => [[ u64 ]]

int       = "int"                          => [[ int ]]
i8        = "i8"                           => [[ i8 ]]
i16       = "i16"                          => [[ i16 ]]
i32       = "i32"                          => [[ i32 ]]
i64       = "i64"                          => [[ i64 ]]

f32       = "f32"                          => [[ f32 ]]
f64       = "f64"                          => [[ f64 ]]

bool      = "bool"                         => [[ bool ]]
str       = "str"                          => [[ str ]]
data      = "data"~ length?                => [[ <data> ]]
void      = "void"                         => [[ void ]]

enum-value-name = upper (upper|digit|[_])* => [[ first2 swap prefix >string ]]
enum-value = enum-value-name value?        => [[ >array ]]
enum-values = (ws enum-value ws)*
enum      = "enum"~ ws "{"~ ws enum-values ws "}"~ => [[ <enum> ]]

uints     = uint|u8|u16|u32|u64
ints      = int|i8|i16|i32|i64
floats    = f32|f64
primitive = uints|ints|floats|bool|str|data|void|enum

optional  = "optional"~ type               => [[ <optional> ]]
list      = "list"~ type length?           => [[ first2 <list> ]]
map       = "map"~ type type               => [[ first2 <map> ]]

struct-field-name = alpha+                 => [[ >string ]]
struct-field = struct-field-name ws ":"~ ws any-type => [[ >array ]]
struct-fields = (ws struct-field ws)*
struct    = "struct"~ ws "{"~ ws struct-fields ws "}"~ => [[ <struct> ]]

union-member  = any-type value?            => [[ >array ]]
union-members = union-member (ws "|"~ ws union-member)* => [[ first2 swap prefix ]]
union     = "union"~ ws "{"~ ws ("|"?)~ ws union-members? ws ("|"?)~ ws "}"~ => [[ <union> ]]

aggregate = optional|list|map|struct|union

defined   = user-type-name => [[ lookup-user-type ]]

any-type  = aggregate|primitive|defined

user-type-name = (alpha|digit)+            => [[ >string ]]
user-type = "type"~ ws user-type-name ws any-type
          => [[ first2 [ insert-user-type ] [ 2array ] 2bi ]]

schema = (ws user-type ws)* => [[ <schema> ]]

]=]

PRIVATE>

: parse-schema ( string -- schema )
    H{ } clone user-types [ (parse-schema) ] with-variable ;

: load-schema ( path -- schema )
    utf8 file-contents parse-schema ;

: define-schema ( schema -- )
    ! XXX: define user types as tuples with bare-fields word-prop?
    types>> [
        [ create-word-in dup reset-generic ]
        [ define-constant ] bi*
    ] assoc-each ;

SYNTAX: SCHEMA: scan-object parse-schema define-schema ;
