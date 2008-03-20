USING: layouts combinators vocabs.loader ;
IN: unix.stat

cell-bits {
    { 32 [ "unix.stat.openbsd.32" require ] }
    { 64 [ "unix.stat.openbsd.64" require ] }
} case
