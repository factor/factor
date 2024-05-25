! Copyright (C) 2022-2024 nomennescio
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays help.markup help.syntax kernel tools.image memory strings ;
IN: tools.image.compressor

ARTICLE: "tools.image.compressor" "Compress Factor image file for loading by the VM"
"The " { $vocab-link "tools.image.compressor" } " vocabulary compresses Factor images such that the VM can load it and decompress it on the fly. Compressed and uncompressed Factor images are both supported by the VM and are only determined by their image headers." $nl
"You can also run the compressor on the current Factor image directly from the commandline:"  { $code "factor -run=tools.image.compressor [ -c <level> ] [ <input> [ <output> ] ]" } $nl
"The following arguments are supported:" $nl
{ $snippet "-c <level>" } " defines the compression level (1..22, default 12)" $nl
{ $snippet "<input>" } " if given compress this file, else the current Factor image" $nl
{ $snippet "<output>" } " if given save result into this file instead of overwriting input file" $nl
"To uncompress a compressed Factor image, you can start Factor with" { $code "factor -i=<compressed image>" } "then " { $link save-image-and-exit } $nl
"Embedded images in executables such as those created by the " { $vocab-link "tools.deploy" } " tool, can also be directly loaded, compressed, and saved."
$examples {
  { $code "factor -run=tools.image.compressor" }
  { $code "factor -run=tools.image.compressor -c 1 hello-ui.exe" }
  { $code "factor -run=tools.image.compressor -c 18 factor.image factor.image.compressed" }
}
;

HELP: (compress)
{ $values
    { "byte-array" byte-array }
    { "compressed" object }
}
{ $description "Compress bytes with current compression level" } ;

HELP: force-compression
{ $var-description "Enable force compression." }
{ $warning "This converts uncompressable images using " { $link >compressable } ", see warning there." } ;

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

HELP: compress-factor-image
{ $values
    { "image-file" string }
    { "compressed-file" string }
}
{ $description "Load, compresses and saves a Factor image" }
;

HELP: compress-current-image
{ $description "Loads, compresses and saves current Factor image" }
;

ABOUT: "tools.image.compressor"
