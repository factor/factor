USING: crypto.common kernel math sequences ;
IN: crypto.xor

TUPLE: no-xor-key ;

: xor-crypt ( key seq -- seq )
    over empty? [ no-xor-key construct-empty throw ] when
    dup length rot [ mod-nth bitxor ] curry 2map ;
