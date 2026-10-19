! Execute with a native Linux m68k compiler image and this checkout's resources.
! Load only the measured platform schema so the probe is independent of the
! complete Unix I/O dependency tree.
USING: alien.c-types arrays classes.struct compiler.units io kernel
math math.bitwise vocabs words ;

"unix.stat.linux.m68k.32" require
"stat-func" "unix.stat" lookup-word 1array compile
"stat" "unix.stat" lookup-word
dup heap-size 92 = [ ] [ "wrong m68k stat64 size" throw ] if
new dup "/tmp" swap "stat-func" "unix.stat" lookup-word
execute( path buf -- n ) 0 = [ ] [ "m68k stat64 call failed" throw ] if
"st_mode>>" "accessors" lookup-word execute( data -- mode )
0o170000 bitand 0o040000 =
[ "m68k Factor stat64 schema and native call: PASS" print ]
[ "m68k stat64 directory mode mismatch" throw ] if
