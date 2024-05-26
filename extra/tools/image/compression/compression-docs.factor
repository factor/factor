! Copyright (C) 2024 nomennescio.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays help.markup help.syntax images ;
IN: tools.image.compression

ARTICLE: "tools.image.compression" "Factor image compression and uncompression"
{ $vocab-link "tools.image.compression" }
;


HELP: (compress)
{ $values
    { "byte-array" byte-array }
    { "compressed" byte-array }
}
{ $description "Compress bytes with current compression level" } ;

HELP: compression-level
{ $var-description "Compression parameter : 1 (least) .. 22 (most). Default value 12." } ;

HELP: compress
{ $values
    { "byte-array" byte-array }
    { "compressed" byte-array }
}
{ $description "Compresses bytes, keep shortest sequence" }
;

! HELP: compress-code
! { $values
!     { "image" image }
!     { "image'" image }
! }
! { $description "Compresses code heap" }
! ;
!
! HELP: compress-data
! { $values
!     { "image" image }
!     { "image'" image }
! }
! { $description "Compresses data heap" }
! ;

HELP: compress-image
{ $values
    { "image" image }
    { "image'" image }
}
{ $description "Compresses data- and code heaps and syncs header" }
;


HELP: uncompress
{ $values
    { "byte-array" byte-array }
    { "uncompressed" byte-array }
}
{ $description "Compresses bytes" }
;

! HELP: uncompress-code
! { $values
!     { "image" image }
!     { "image'" image }
! }
! { $description "Compresses code heap" }
! ;
! 
! HELP: uncompress-data
! { $values
!     { "image" image }
!     { "image'" image }
! }
! { $description "Compresses data heap" }
! ;

HELP: uncompress-image
{ $values
    { "image" image }
    { "image'" image }
}
{ $description "Compresses data- and code heaps and syncs header" }
;

ABOUT: "tools.image.compression"
