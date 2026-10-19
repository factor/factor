! Upgrade a pre-capture s390x checkpoint for native variadic callback tests.
! Run from the directory containing s390x_bootstrap_export.factor's .bin files.
USING: accessors arrays io.encodings.binary io.files kernel kernel.private math
sequences system ;
IN: s390x.callback.upgrade

cpu name>> "s390x" = [
    CALLBACK-STUB special-object clone
    "s390x-VARARGS-CALLBACK-relocations.bin" binary file-contents
    "s390x-VARARGS-CALLBACK.bin" binary file-contents 2array
    over length 3 >= [ [ 2 rot set-nth ] 2keep drop ] [ suffix ] if
    CALLBACK-STUB set-special-object
] when
