! Copyright (C) 2022 Raghu Ranganathan.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays help.markup help.syntax kernel multiline strings ;
IN: compression.bzip3

HELP: compress
{ $values byte-array: byte-array block-size/f: { $maybe "integer" } byte-array': byte-array }
{ $description "Takes a byte array and block size, and pushes a compressed byte array from bzip3." } ;

HELP: decompress
{ $values byte-array: byte-array byte-array': byte-array }
{ $description Takes a valid bzip3 compressed byte array, and pushes its decompressed form. } ;

HELP: internal-error
{ $values msg: object }
{ $description Throws an { $link internal-error } error. }
{ $error-description A bzip3 internal error. Error type is indicated in { $snippet "msg" } . } ;

HELP: invalid-block-size
{ $values size: object }
{ $description Throws an  { $link invalid-block-size }  error. }
{ $error-description Occurs if the given "block" size for compression is not in the range of 65 KiB and 511 MiB. } ;

HELP: version
{ $values c-string: string }
{ $description Pushes the version info of the bzip3 release installed on your system. } ;

ARTICLE: "compression.bzip3" "Compressing data with bzip3"
The { $vocab-link "compression.bzip3" } vocabulary can compress and decompress binary data with the help of the 
{ $url "https://github.com/kspalaiologos/bzip3" "bzip3" } library. All data is represented in the form of { $link "byte-arrays" } .

bzip3 is best used with text or code, and hence the { $vocab-link "io.encodings" } vocabularies, specifically the
{ $link "io.encodings.string" } , { $vocab-link "io.encodings.utf8" } and { $vocab-link "io.encodings.ascii" } will be of help.

If you are an experienced user and would like to use the low level API of bzip3, the { $link "compression.bzip3.ffi" } library
exposes the C bindings that allows for better performance via threading and other customizations. In order to use the functions 
imported you will need to use the { $vocab-link "alien" } vocabulary. ;

ABOUT: "compression.bzip3"
