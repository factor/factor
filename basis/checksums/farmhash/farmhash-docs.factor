! Copyright (C) 2026 John Benediktsson
! See https://factorcode.org/license.txt for BSD license.

USING: checksums help.markup help.syntax kernel math ;
IN: checksums.farmhash

HELP: farmhash-32
{ $class-description "The portable farmhashmk 32-bit checksum algorithm. Unseeded results match Google's Fingerprint32. Results are unsigned integers." } ;

HELP: <farmhash-32>
{ $values { "seed" { $maybe integer } } { "farmhash-32" farmhash-32 } }
{ $description "Constructs a FarmHash32 checksum. A seed of " { $link f } " selects Fingerprint32; an integer selects farmhashmk::Hash32WithSeed, without debug tweaks. Seeds are reduced modulo 2^32. Zero is a seed and is distinct from selecting the unseeded algorithm." } ;

HELP: farmhash-64
{ $class-description "The portable farmhashna 64-bit checksum algorithm. Unseeded results match Google's Fingerprint64. Results are unsigned integers." } ;

HELP: <farmhash-64>
{ $values { "seed" { $maybe integer } } { "farmhash-64" farmhash-64 } }
{ $description "Constructs a FarmHash64 checksum. A seed of " { $link f } " selects Fingerprint64; an integer selects farmhashna::Hash64WithSeed, without debug tweaks. Seeds are reduced modulo 2^64." } ;

HELP: farmhash-128
{ $class-description "The FarmHash128 checksum algorithm, identical to CityHash128. Results are unsigned 128-bit integers with Uint128Low64 in bits 0 through 63 and Uint128High64 in bits 64 through 127." } ;

HELP: <farmhash-128>
{ $values { "seed" { $maybe integer } } { "farmhash-128" farmhash-128 } }
{ $description "Constructs a FarmHash128 checksum. A seed of " { $link f } " selects Fingerprint128; an integer selects CityHash128WithSeed. Seeds are reduced modulo 2^128 and use the same low/high word layout as the result." } ;

ARTICLE: "checksums.farmhash" "FarmHash checksums"
"The " { $vocab-link "checksums.farmhash" } " vocabulary implements portable, non-cryptographic FarmHash algorithms using the " { $link checksum } " protocol. Input is a sequence of bytes; encode text to bytes before hashing."
$nl
"Unseeded hashes use Google's stable Fingerprint32, Fingerprint64, and Fingerprint128 algorithms. Seeded hashes use the fixed variants documented below. These choices give consistent results across architectures and build modes. Google's generic Hash32 and Hash64 APIs may select different algorithms depending on the CPU and build configuration."
{ $subsections farmhash-32 <farmhash-32> farmhash-64 <farmhash-64> farmhash-128 <farmhash-128> }
{ $examples
    { $example "USING: checksums checksums.farmhash prettyprint ;"
        "B{ } f <farmhash-64> checksum-bytes ." "11160318154034397263" }
}
"Reference implementation: " { $url "https://github.com/google/farmhash" } "." ;

ABOUT: "checksums.farmhash"
