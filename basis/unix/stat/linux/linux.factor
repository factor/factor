USING: alien.syntax layouts combinators vocabs.loader ;
IN: unix.stat

cell-bits
{
    { 32 [ "unix.stat.linux.32" require ] }
    { 64 [ "unix.stat.linux.64" require ] }
} case
