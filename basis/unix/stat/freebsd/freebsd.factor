USING: layouts combinators vocabs.loader ;
IN: unix.stat

cell-bits {
    { 32 [ "unix.stat.freebsd.32" require ] }
    { 64 [ "unix.stat.freebsd.64" require ] }
} case
