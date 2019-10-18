USING: help.markup help.syntax ;
IN: checksums.metrohash

HELP: metrohash-64
{ $class-description "MetroHash 64-bit checksum algorithm." } ;

HELP: metrohash-128
{ $class-description "MetroHash 128-bit checksum algorithm." } ;

ARTICLE: "checksums.metrohash" "MetroHash checksum"
"MetroHash is a set of non-cryptographic hash functions."
{ $subsections
    metrohash-64
    metrohash-128 } ;

ABOUT: "checksums.metrohash"
