USING: edn kernel linked-assocs multiline sequences tools.test ;

{
    {
        null
        t
        f
        "hungarian breakfast"
        "farmer's cheesy omelette"
        103
        114
        97
        99
        101
        T{ keyword { name "eggs" } }
        T{ keyword { name "cheese" } }
        T{ keyword { name "olives" } }
        T{ symbol { name "spoon" } }
        T{ symbol { name "kitchen/spoon" } }
        T{ symbol { name "kitchen/fork" } }
        T{ symbol { name "github/fork" } }
        42
        3.14159
        {
            T{ keyword { name "bun" } }
            T{ keyword { name "beef-patty" } }
            9
            "yum!"
        }
        V{
            T{ keyword { name "gelato" } }
            1
            2
            T{ symbol { name "-2" } }
        }
        LH{
            { T{ keyword { name "eggs" } } 2 }
            { T{ keyword { name "lemon-juice" } } 3.5 }
            { T{ keyword { name "butter" } } 1 }
        }
        LH{
            { V{ 1 2 3 4 } "tell the people what she wore" }
            { V{ 5 6 7 8 } "the more you see the more you hate" }
        }
        HS{
            88
            T{ keyword { name "a" } }
            T{ keyword { name "b" } }
            "huat"
        }
        T{ tagged
            { name "MyYelpClone/MenuItem" }
            { value
                LH{
                    { T{ keyword { name "name" } } "eggs-benedict" }
                    { T{ keyword { name "rating" } } 10 }
                }
            }
        }
    }
    t ! round-trip
} [
    [=[
; Comments start with a semicolon.
; Anything after the semicolon is ignored.

;;;;;;;;;;;;;;;;;;;
;;; Basic Types ;;;
;;;;;;;;;;;;;;;;;;;

nil         ; also known in other languages as null

; Booleans
true
false

; Strings are enclosed in double quotes
"hungarian breakfast"
"farmer's cheesy omelette"

; Characters are preceded by backslashes
\g \r \a \c \e

; Keywords start with a colon. They behave like enums. Kind of
; like symbols in Ruby.
:eggs
:cheese
:olives

; Symbols are used to represent identifiers. 
; You can namespace symbols by using /. Whatever precedes / is
; the namespace of the symbol.
spoon
kitchen/spoon ; not the same as spoon
kitchen/fork
github/fork   ; you can't eat with this

; Integers and floats
42
3.14159

; Lists are sequences of values
(:bun :beef-patty 9 "yum!")

; Vectors allow random access
[:gelato 1 2 -2]

; Maps are associative data structures that associate the key with its value
{:eggs        2
 :lemon-juice 3.5
 :butter      1}

; You're not restricted to using keywords as keys
{[1 2 3 4] "tell the people what she wore",
 [5 6 7 8] "the more you see the more you hate"}

; You may use commas for readability. They are treated as whitespace.

; Sets are collections that contain unique elements.
#{:a :b 88 "huat"}

;;;;;;;;;;;;;;;;;;;;;;;
;;; Tagged Elements ;;;
;;;;;;;;;;;;;;;;;;;;;;;

; EDN can be extended by tagging elements with # symbols.

#MyYelpClone/MenuItem {:name "eggs-benedict" :rating 10}
]=] edn> dup >edn edn> first dupd =
] unit-test
