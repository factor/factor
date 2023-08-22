! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays io kernel make math math.order
math.parser ranges sequences sorting ;
IN: rosetta-code.knapsack

! https://rosettacode.org/wiki/Knapsack_problem/0-1

! A tourist wants to make a good trip at the weekend with his
! friends. They will go to the mountains to see the wonders of
! nature, so he needs to pack well for the trip. He has a good
! knapsack for carrying things, but knows that he can carry a
! maximum of only 4kg in it and it will have to last the whole
! day. He creates a list of what he wants to bring for the trip
! but the total weight of all items is too much. He then decides
! to add columns to his initial list detailing their weights and a
! numerical value representing how important the item is for the
! trip.

! The tourist can choose to take any combination of items from
! the list, but only one of each item is available. He may not cut
! or diminish the items, so he can only take whole units of any
! item.

! Which items does the tourist carry in his knapsack so that
! their total weight does not exceed 400 dag [4 kg], and their
! total value is maximized?

TUPLE: item
    name weight value ;

CONSTANT: items {
        T{ item f "map" 9 150 }
        T{ item f "compass" 13 35 }
        T{ item f "water" 153 200 }
        T{ item f "sandwich" 50 160 }
        T{ item f "glucose" 15 60 }
        T{ item f "tin" 68 45 }
        T{ item f "banana" 27 60 }
        T{ item f "apple" 39 40 }
        T{ item f "cheese" 23 30 }
        T{ item f "beer" 52 10 }
        T{ item f "suntan cream" 11 70 }
        T{ item f "camera" 32 30 }
        T{ item f "t-shirt" 24 15 }
        T{ item f "trousers" 48 10 }
        T{ item f "umbrella" 73 40 }
        T{ item f "waterproof trousers" 42 70 }
        T{ item f "waterproof overclothes" 43 75 }
        T{ item f "note-case" 22 80 }
        T{ item f "sunglasses" 7 20 }
        T{ item f "towel" 18 12 }
        T{ item f "socks" 4 50 }
        T{ item f "book" 30 10 }
    }

CONSTANT: limit 400

: make-table ( -- table )
    items length 1 + [ limit 1 + 0 <array> ] replicate ;

:: iterate ( item-no table -- )
    item-no table nth :> prev
    item-no 1 + table nth :> curr
    item-no items nth :> item
    limit [1..b] [| weight |
        weight prev nth
        weight item weight>> - dup 0 >=
        [ prev nth item value>> + max ]
        [ drop ] if
        weight curr set-nth
    ] each ;

: fill-table ( table -- )
    [ items length <iota> ] dip
    '[ _ iterate ] each ;

:: extract-packed-items ( table -- items )
    [
        limit :> weight!
        items length <iota> <reversed> [| item-no |
            item-no table nth :> prev
            item-no 1 + table nth :> curr
            weight [ curr nth ] [ prev nth ] bi =
            [
                item-no items nth
                [ name>> , ] [ weight>> weight swap - weight! ] bi
            ] unless
        ] each
    ] { } make ;

: solve-knapsack ( -- items value )
    make-table [ fill-table ]
    [ extract-packed-items ] [ last last ] tri ;

: knapsack-main ( -- )
    solve-knapsack
    "Total value: " write number>string print
    "Items packed: " print
    sort
    [ "   " write print ] each ;

MAIN: knapsack-main
