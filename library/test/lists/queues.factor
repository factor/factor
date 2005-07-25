IN: temporary
USING: kernel lists math sequences test ;

[ { 1 2 3 4 5 } ] [
    <queue> [ 1 2 3 4 5 ] [ swap enque ] each
    5 [ drop deque swap ] map nip
] unit-test
