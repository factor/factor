USING: assocs assoc-heaps heaps heaps.private kernel tools.test ;
IN: temporary

[
T{
    assoc-heap
    f
    H{ { 2 1 } }
    T{ min-heap T{ heap f V{ { 1 2 } } } }
}
] [ H{ } clone <assoc-min-heap> 1 2 pick heap-push ] unit-test

[
T{
    assoc-heap
    f
    H{ { 1 0 } { 2 1 } }
    T{ min-heap T{ heap f V{ { 0 1 } { 1 2 } } } }
}
] [  H{ } clone <assoc-min-heap> 1 2 pick heap-push 0 1 pick heap-push ] unit-test

[ T{ assoc-heap f H{ } T{ min-heap T{ heap f V{ } } } } ]
[
    H{ } clone <assoc-min-heap>
    1 2 pick heap-push 0 1 pick heap-push
    dup heap-pop 2drop dup heap-pop 2drop
] unit-test


[ 0 1 ] [
T{
    assoc-heap
    f
    H{ { 1 0 } { 2 1 } }
    T{ min-heap T{ heap f V{ { 0 1 } { 1 2 } } } }
} heap-pop
] unit-test

[ 1 2 ] [
T{
    assoc-heap
    f
    H{ { 1 0 } { 2 1 } }
    T{ max-heap T{ heap f V{ { 1 2 } { 0 1 } } } }
} heap-pop
] unit-test
