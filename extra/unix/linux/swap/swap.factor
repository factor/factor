
USING: alien.syntax ;

IN: unix.linux.swap

: SWAP_FLAG_PREFER	HEX: 8000 ; ! Set if swap priority is specified.
: SWAP_FLAG_PRIO_MASK	HEX: 7fff ;
: SWAP_FLAG_PRIO_SHIFT	0 ;

FUNCTION: int swapon ( char* path, int flags ) ;

FUNCTION: int swapoff ( char* path ) ;