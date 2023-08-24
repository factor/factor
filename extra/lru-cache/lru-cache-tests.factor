USING: assocs kernel lru-cache sorting tools.test ;

{
    { { 3 3 } { 4 4 } { 5 5 } }
} [
    3 <lru-hash>
    1 1 pick set-at
    2 2 pick set-at
    3 3 pick set-at
    4 4 pick set-at
    5 5 pick set-at
    >alist sort
] unit-test

{
    { { 1 1 } { 4 4 } { 5 5 } }
} [
    3 <lru-hash>
    1 1 pick set-at
    2 2 pick set-at
    3 3 pick set-at
    1 over at drop
    4 4 pick set-at
    5 5 pick set-at
    >alist sort
] unit-test

{
    { { 2 2 } { 4 4 } { 5 5 } }
} [
    3 <lru-hash>
    1 1 pick set-at
    2 2 pick set-at
    3 3 pick set-at
    1 over delete-at
    1 over at drop
    2 over at drop
    4 4 pick set-at
    5 5 pick set-at
    >alist sort
] unit-test

{
    { { 3 3 } { 4 4 } { 5 5 } }
} [
    3 <fifo-hash>
    1 1 pick set-at
    2 2 pick set-at
    3 3 pick set-at
    4 4 pick set-at
    5 5 pick set-at
    >alist sort
] unit-test

{
    { { 1 1 } { 4 4 } { 5 5 } }
} [
    3 <fifo-hash>
    1 1 pick set-at
    2 2 pick set-at
    3 3 pick set-at
    1 1 pick set-at
    4 4 pick set-at
    5 5 pick set-at
    >alist sort
] unit-test

{
    { { 1 1 } { 2 2 } { 5 5 } }
} [
    3 <lifo-hash>
    1 1 pick set-at
    2 2 pick set-at
    3 3 pick set-at
    4 4 pick set-at
    5 5 pick set-at
    >alist sort
] unit-test

{
    { { 2 2 } { 3 3 } { 5 5 } }
} [
    3 <lifo-hash>
    1 1 pick set-at
    2 2 pick set-at
    3 3 pick set-at
    1 over delete-at
    4 4 pick set-at
    5 5 pick set-at
    >alist sort
] unit-test
