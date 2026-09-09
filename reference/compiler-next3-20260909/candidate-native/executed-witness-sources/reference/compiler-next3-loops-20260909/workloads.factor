! Ordinary typed source; no custom IR or unsafe arithmetic primitives.
USING: kernel locals math math.bitwise sequences typed ;
IN: compiler.loop-witness

TYPED:: invariant-xor-loop ( x: fixnum y: fixnum n: fixnum -- result: fixnum )
    0 n [ x y bitxor bitxor ] times ; inline
