! Copyright (C) 2024 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors command-line formatting io kernel make math
math.parser namespaces sequences ;
IN: gilded-rose

TUPLE: GildedRose
    Items ;

TUPLE: Item
    Name SellIn Quality ;

: Item.ToString ( item -- str )
    [ Name>> ] [ SellIn>> ] [ Quality>> ] tri "%s %d %d" sprintf ;

:: GildedRose.UpdateQuality ( this -- )
    this Items>> length [| i |
        i this Items>> nth Name>> "Aged Brie" = not
        i this Items>> nth Name>> "Backstage passes to a TAFKAL80ETC concert" = not
        and [
            i this Items>> nth Quality>> 0 > [
                i this Items>> nth Name>> "Sulfuras, Hand of Ragnaros" = not [
                    i this Items>> nth Quality>> 1 -
                    i this Items>> nth Quality<<
                ] when
            ] when
        ] [
            i this Items>> nth Quality>> 50 < [
                i this Items>> nth Quality>> 1 +
                i this Items>> nth Quality<<
                i this Items>> nth Name>> "Backstage passes to a TAFKAL80ETC concert" = [
                    i this Items>> nth SellIn>> 11 < [
                        i this Items>> nth Quality>> 50 < [
                            i this Items>> nth Quality>> 1 +
                            i this Items>> nth Quality<<
                        ] when
                    ] when
                    i this Items>> nth SellIn>> 6 < [
                        i this Items>> nth Quality>> 50 < [
                            i this Items>> nth Quality>> 1 +
                            i this Items>> nth Quality<<
                        ] when
                    ] when
                ] when
            ] when
        ] if

        i this Items>> nth Name>> "Sulfuras, Hand of Ragnaros" = not [
            i this Items>> nth SellIn>> 1 -
            i this Items>> nth SellIn<<
        ] when

        i this Items>> nth SellIn>> 0 < [
            i this Items>> nth Name>> "Aged Brie" = not [
                i this Items>> nth Name>> "Backstage passes to a TAFKAL80ETC concert" = [
                    i this Items>> nth Quality>> 0 > [
                        i this Items>> nth Name>> "Sulfuras, Hand of Ragnaros" = not [
                            i this Items>> nth Quality>> 1 -
                            i this Items>> nth Quality<<
                        ] when
                    ] when
                ] [
                    i this Items>> nth Quality>> i this Items>> nth Quality>> -
                    i this Items>> nth Quality<<
                ] if
            ] [
                i this Items>> nth Quality>> 50 < [
                    i this Items>> nth Quality>> 1 +
                    i this Items>> nth Quality<<
                ] when
            ] if
        ] when
    ] each-integer ;

: main ( -- )
    "OMGHAI!" print
    [
        "+5 Dexterity Vest" 10 20 Item boa ,
        "Aged Brie" 2 0 Item boa ,
        "Elixir of the Mongoose" 5 7 Item boa ,
        "Sulfuras, Hand of Ragnaros" 0 80 Item boa ,
        "Sulfuras, Hand of Ragnaros" -1 80 Item boa ,
        "Backstage passes to a TAFKAL80ETC concert" 15 20 Item boa ,
        "Backstage passes to a TAFKAL80ETC concert" 10 49 Item boa ,
        "Backstage passes to a TAFKAL80ETC concert" 5 49 Item boa ,
        ! This conjured item does not work properly yet.
        "Conjured Mana Cake" 3 6 Item boa ,
    ] { } make GildedRose boa

    command-line get [ 2 ] [ first dec> ] if-empty [
        "-------- day %d --------\n" printf
        "name, sellIn, quality" print
        dup Items>> [ Item.ToString print ] each
        nl
        GildedRose.UpdateQuality
    ] with each-integer ;

MAIN: main
