USING: crypto.common kernel math sequences ;
IN: crypto.xor

ERROR: no-xor-key ;

: xor-crypt ( key seq -- seq' )
    over empty? [ no-xor-key ] when
    dup length rot [ mod-nth bitxor ] curry 2map ;
