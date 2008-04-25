USING: kernel sequences math.functions math ;
IN: project-euler.100

: euler100 ( -- n )
    1 1
    [ dup dup 1- * 2 * 10 24 ^ <= ]
    [ tuck 6 * swap - 2 - ] [ ] while nip ;
