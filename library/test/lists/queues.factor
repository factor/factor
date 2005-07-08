IN: temporary
USING: kernel lists math sequences test ;

[ [ 1 2 3 4 5 ] ] [
    <queue> [ 1 2 3 4 5 ] [ swap enque ] each
    5 [ drop deque swap ] project nip
] unit-test

[ [ 1 4 9 16 25 ] ] [
    <queue> [ 1 2 3 4 5 ] [ swap enque ] each
    [ sq ] que-map
    5 [ drop deque swap ] project nip
] unit-test
