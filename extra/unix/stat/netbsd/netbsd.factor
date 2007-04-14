USING: layouts combinators vocabs.loader ;
IN: unix.stat

cell-bits {
    { 32 [ "unix.stat.netbsd.32" require ] }
    { 64 [ "unix.stat.netbsd.64" require ] }
} case
