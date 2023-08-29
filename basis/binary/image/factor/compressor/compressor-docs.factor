! Copyright (C) 2022-2023 nomennescio
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays help.markup help.syntax strings ;
IN: binary.image.factor.compressor

ARTICLE: "binary.image.factor.compressor" "Compress Factor image file for loading by the VM"
"The " { $vocab-link "binary.image.factor.compressor" } " vocabulary compresses Factor images such that the VM can load it and decompress it on the fly. Compressed and uncompressed Factor images are both supported by the VM and are only determined by their headers." $nl
"You can also run the compressor on the current Factor image directly from the commandline:"  { $code "factor -run=binary.image.factor.compressor" } ;

HELP: image
{ $class-description "In-memory Factor image" } ;

HELP: image-header
{ $class-description "Factor image header structure" } ;

HELP: >compression-header
{ $values
    { "headerv4" image-header }
    { "headerv4+" image-header }
}
{ $description "Converts any header into a compression supporting header" }
;

HELP: compress
{ $values
    { "byte-array" byte-array }
    { "compressed" byte-array }
}
{ $description "Compresses bytes" }
;

HELP: compress-code
{ $values
    { "image" image }
    { "image'" image }
}
{ $description "Compresses code heap" }
;

HELP: compress-data
{ $values
    { "image" image }
    { "image'" image }
}
{ $description "Compresses data heap" }
;

HELP: load-factor-image
{ $values
    { "filename" string }
    { "image" image }
}
{ $description "Load Factor image into memory" }
;

HELP: save-factor-image
{ $values
    { "image" image }
    { "filename" string }
}
{ $description "Save Factor image from memory" }
;

HELP: compress-factor-image
{ $values
    { "filename" string }
}
{ $description "Load, compresses and saves Factor image with \".compressed\" appended to its filename." }
;

HELP: sync-header
{ $values
    { "image" image }
    { "image'" image }
}
{ $description "Sync header from actual data and code sizes" }
;

HELP: compress-current-image
{ $description "Load, compresses and saves current Factor image with \".compressed\" appended to its filename." }
;

ABOUT: "binary.image.factor.compressor"