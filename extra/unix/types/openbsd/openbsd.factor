USING: layouts combinators vocabs.loader ;
IN: unix.stat

cell-bits {
    { 32 [ "unix.types.openbsd.32" require ] }
    { 64 [ "unix.types.openbsd.64" require ] }
} case
