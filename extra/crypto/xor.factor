USING: errors kernel math sequences ;
IN: crypto

TUPLE: no-xor-key ;

: xor-crypt ( key seq -- seq )
    over empty? [ <no-xor-key> throw ] when
    [ length ] keep
    [ >r over mod-nth r> bitxor ] 2map nip ;
