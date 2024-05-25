! Copyright (C) 2024 nomennescio
! See https://factorcode.org/license.txt for BSD license.
USING: classes help.markup help.syntax kernel math quotations
strings tools.image ;

HELP: compressable-image
{ $class-description "predicate class to indicate compressable images" } ;

HELP: >compressable
{ $values
    { "uncompressable-image" object }
    { "compressable-image" object }
}
{ $description "Converts an uncompressable image to a compressable image." }
{ $warning "Such an image cannot be loaded by older Factor versions that do not support loading of compressed images. In extreme cases such older Factor versions might not be able to start due to this. Keep backups of important image files before compressing them." } ;

! HELP: reset-header
! { $values
!     { "header" object }
!     { "header'" object }
! }
! { $description "reset header format" } ;

HELP: uncompressable-image
{ $description "Throws an " { $link uncompressable-image } " error." }
{ $error-description "in case an illegal operation is performed on an uncompressable image" } ;

HELP: embedded-image-footer.32
{ $class-description "32 bit embedded image footer" } ;

HELP: embedded-image-footer.64
{ $class-description "64 bit embedded image footer" } ;

HELP: image-header.32
{ $class-description "32 bit image header" } ;

HELP: image-header.64
{ $class-description "64 bit image header" } ;

HELP: embedded-image-footer.union
{ $class-description "Overlay of 32 and 64 bit embedded image footer" } ;

HELP: image-header.union
{ $class-description "Overlay of 32 and 64 bit image header" } ;

HELP: read-struct*
{ $values
    { "class" class }
    { "struct" object }
}
{ $description "read struct, even beyond EOF" } ;

HELP: skip-struct
{ $values
    { "struct" object }
}
{ $description "skip the size of a struct in the input stream" } ;

HELP: valid-image-footer?
{ $values
    { "footer" object }
    { "footer.32/footer.64/f" object }
}
{ $description "returns valid image footer or f" } ;

HELP: with-position
{ $values
    { "quot" quotation }
}
{ $description "marks position in input-stream and return to it after quotation has finished" } ;

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

HELP: sync-header
{ $values
    { "image" image }
    { "image'" image }
}
{ $description "Sync header from actual data and code sizes" }
;

HELP: check-image-header
{ $values
    { "header" object }
    { "header.32/header.64/*" object }
}
{ $description "Checks for a valid header, else throws error" } ;

HELP: embedded-image-footer
{ $class-description "Embedded footer at end of file indicates this is an embedded image" } ;

HELP: image-magic
{ $values
    { "value" object }
}
{ $description "Magic value for a valid Factor image" } ;

HELP: image-version
{ $values
    { "value" object }
}
{ $description "Current supported Factor image format version" } ;

HELP: read*
{ $values
    { "n" integer }
    { "bytes" object }
}
{ $description "read n bytes, return empty byte array if n equals 0" } ;

HELP: read-footer
{ $values
    { "footer-offset" object } { "footer" object }
}
{ $description "read the footer at given offset from beginning of file. Reads footer from end of file, while returning to current file position. Also returns offset to footer from beginning of file." } ;

HELP: read-footer*
{ $values
    { "footer-offset" object } { "footer/f" object }
}
{ $description "Read footer if it exists, return f otherwise" } ;

HELP: read-header
{ $values
    { "header.32/header.64/*" object }
}
{ $description "Read header" } ;

HELP: uncompressed-code?
{ $values
    { "image" object }
    { "?" boolean }
}
{ $description "Check if stored code heap is uncompressed" } ;

HELP: uncompressed-data?
{ $values
    { "image" object }
    { "?" boolean }
}
{ $description "Check if stored data heap is uncompressed" } ;

HELP: unsupported-image-header
{ $description "Throws an " { $link unsupported-image-header } " error." }
{ $error-description "Thrown when an image header is not recognized" } ;

HELP: valid-footer?
{ $values
    { "footer" object }
    { "?" boolean }
}
{ $description "Is it a valid footer?" } ;

HELP: valid-header?
{ $values
    { "header" object }
    { "?" boolean }
}
{ $description "Is it a valid header?" } ;
