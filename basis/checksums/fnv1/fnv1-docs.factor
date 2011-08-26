USING: help.markup help.syntax ;
IN: checksums.fnv1

HELP: fnv1-32
{ $class-description "Fowler-Noll-Vo checksum algorithm, v1, 32-bit." } ;

HELP: fnv1a-32
{ $class-description "Fowler-Noll-Vo checksum algorithm, v1a, 32-bit." } ;


HELP: fnv1-64
{ $class-description "Fowler-Noll-Vo checksum algorithm, v1, 64-bit." } ;

HELP: fnv1a-64
{ $class-description "Fowler-Noll-Vo checksum algorithm, v1a, 64-bit." } ;


HELP: fnv1-128
{ $class-description "Fowler-Noll-Vo checksum algorithm, v1, 128-bit." } ;

HELP: fnv1a-128
{ $class-description "Fowler-Noll-Vo checksum algorithm, v1a, 128-bit." } ;


HELP: fnv1-256
{ $class-description "Fowler-Noll-Vo checksum algorithm, v1, 256-bit." } ;

HELP: fnv1a-256
{ $class-description "Fowler-Noll-Vo checksum algorithm, v1a, 256-bit." } ;


HELP: fnv1-512
{ $class-description "Fowler-Noll-Vo checksum algorithm, v1, 512-bit." } ;

HELP: fnv1a-512
{ $class-description "Fowler-Noll-Vo checksum algorithm, v1a, 512-bit." } ;


HELP: fnv1-1024
{ $class-description "Fowler-Noll-Vo checksum algorithm, v1, 1024-bit." } ;

HELP: fnv1a-1024
{ $class-description "Fowler-Noll-Vo checksum algorithm, v1a, 1024-bit." } ;

ARTICLE: "checksums.fnv1" "Fowler-Noll-Vo checksum"
  "The Fowler-Noll-Vo checksum algorithm is another simple and fast checksum. It comes in 32, 64, 128, 256, 512 and 1024-bit versions, each in 1 and 1a variants. The 1a variants tend to produce a slightly better result. See " { $url "http://en.wikipedia.org/wiki/Fowler_Noll_Vo_hash" } " for more details."
{ $subsections
    fnv1-32
    fnv1a-32
}
{ $subsections
    fnv1-64
    fnv1a-64
}
{ $subsections
    fnv1-128
    fnv1a-128
}
{ $subsections
    fnv1-256
    fnv1a-256
}
{ $subsections
    fnv1-512
    fnv1a-512
}
{ $subsections
    fnv1-1024
    fnv1a-1024
} ;

ABOUT: "checksums.fnv1"
