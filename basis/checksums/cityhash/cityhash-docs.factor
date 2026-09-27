! Copyright (C) 2026 John Benediktsson
! See https://factorcode.org/license.txt for BSD license.

USING: checksums help.markup help.syntax kernel math ;
IN: checksums.cityhash

HELP: cityhash-32
{ $class-description "The unseeded CityHash32 checksum algorithm. Results are unsigned 32-bit integers. CityHash32 does not define a seeded variant." } ;

HELP: cityhash-64
{ $class-description "The CityHash64 checksum algorithm. Results are unsigned 64-bit integers. Construct an instance with " { $link <cityhash-64> } "." } ;

HELP: <cityhash-64>
{ $values { "seed" { $maybe integer } } { "cityhash-64" cityhash-64 } }
{ $description "Constructs a CityHash64 checksum. A seed of " { $link f } " selects CityHash64; an integer selects CityHash64WithSeed. Integer seeds are reduced modulo 2^64, so zero is a seed and differs from the unseeded variant." } ;

HELP: cityhash-128
{ $class-description "The CityHash128 checksum algorithm. Results are unsigned 128-bit integers with Uint128Low64 in bits 0 through 63 and Uint128High64 in bits 64 through 127." } ;

HELP: <cityhash-128>
{ $values { "seed" { $maybe integer } } { "cityhash-128" cityhash-128 } }
{ $description "Constructs a CityHash128 checksum. A seed of " { $link f } " selects CityHash128; an integer selects CityHash128WithSeed. Integer seeds are reduced modulo 2^128 and use the same low/high word layout as the result." } ;

ARTICLE: "checksums.cityhash" "CityHash checksums"
"The " { $vocab-link "checksums.cityhash" } " vocabulary implements Google's non-cryptographic CityHash algorithms in Factor. They implement the " { $link checksum } " protocol and return integers. Input is a sequence of bytes; encode text to bytes before hashing."
{ $subsections cityhash-32 cityhash-64 <cityhash-64> cityhash-128 <cityhash-128> }
{ $examples
    { $example "USING: checksums checksums.cityhash prettyprint ;"
        "B{ } cityhash-32 checksum-bytes ." "3696677242" }
}
"Reference implementation: " { $url "https://github.com/google/cityhash" } "." ;

ABOUT: "checksums.cityhash"
