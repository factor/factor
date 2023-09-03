! Copyright (C) 2023 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors assocs colors kernel math math.parser sequences
ui ui.gadgets ui.gadgets.borders ui.gadgets.buttons
ui.gadgets.labels ui.gadgets.tracks ui.pens.solid webbrowser ;

IN: periodic-table

SYMBOLS: +alkali-metal+ +alkaline-earth-metal+ +lanthanide+
    +actinide+ +transition-metal+ +unknown+
    +post-transition-metal+ +metalloid+ +reactive-non-metal+
    +halogen+ +noble-gas+ ;

CONSTANT: group-colors {
    { +alkali-metal+          COLOR: #ff6268 }
    { +alkaline-earth-metal+  COLOR: #ffddb2 }
    { +lanthanide+            COLOR: #ffbffb }
    { +actinide+              COLOR: #ff98c9 }
    { +transition-metal+      COLOR: #ffbfc1 }
    { +unknown+               COLOR: #cccccc }
    { +post-transition-metal+ COLOR: #999999 }
    { +metalloid+             COLOR: #cbcc9e }
    { +reactive-non-metal+    COLOR: #b6fda9 }
    { +halogen+               COLOR: #ffffa6 }
    { +noble-gas+             COLOR: #beffff }
}

CONSTANT: elements {
    { "H" "Hydrogen" +reactive-non-metal+ }
    { "He" "Helium" +noble-gas+ }
    { "Li" "Lithium" +alkali-metal+ }
    { "Be" "Beryllium" +alkaline-earth-metal+ }
    { "B" "Boron" +metalloid+ }
    { "C" "Carbon" +reactive-non-metal+ }
    { "N" "Nitrogen" +reactive-non-metal+ }
    { "O" "Oxygen" +reactive-non-metal+ }
    { "F" "Fluorine" +reactive-non-metal+ }
    { "Ne" "Neon" +noble-gas+ }
    { "Na" "Sodium" +alkali-metal+ }
    { "Mg" "Magnesium" +alkaline-earth-metal+ }
    { "Al" "Aluminium" +post-transition-metal+ }
    { "Si" "Silicon" +metalloid+ }
    { "P" "Phosphorus" +reactive-non-metal+ }
    { "S" "Sulfur" +reactive-non-metal+ }
    { "Cl" "Chlorine" +reactive-non-metal+ }
    { "Ar" "Argon" +noble-gas+ }
    { "K" "Potassium" +alkali-metal+ }
    { "Ca" "Calcium" +alkaline-earth-metal+ }
    { "Sc" "Scandium" +transition-metal+ }
    { "Ti" "Titanium" +transition-metal+ }
    { "V" "Vanadium" +transition-metal+ }
    { "Cr" "Chromium" +transition-metal+ }
    { "Mn" "Manganese" +transition-metal+ }
    { "Fe" "Iron" +transition-metal+ }
    { "Co" "Cobalt" +transition-metal+ }
    { "Ni" "Nickel" +transition-metal+ }
    { "Cu" "Copper" +transition-metal+ }
    { "Zn" "Zinc" +post-transition-metal+ }
    { "Ga" "Gallium" +post-transition-metal+ }
    { "Ge" "Germanium" +metalloid+ }
    { "As" "Arsenic" +metalloid+ }
    { "Se" "Selenium" +reactive-non-metal+ }
    { "Br" "Bromine" +reactive-non-metal+ }
    { "Kr" "Krypton" +noble-gas+ }
    { "Rb" "Rubidium" +alkali-metal+ }
    { "Sr" "Strontium" +alkaline-earth-metal+ }
    { "Y" "Yttrium" +transition-metal+ }
    { "Zr" "Zirconium" +transition-metal+ }
    { "Nb" "Niobium" +transition-metal+ }
    { "Mo" "Molybdenum" +transition-metal+ }
    { "Tc" "Technetium" +transition-metal+ }
    { "Ru" "Ruthenium" +transition-metal+ }
    { "Rh" "Rhodium" +transition-metal+ }
    { "Pd" "Palladium" +transition-metal+ }
    { "Ag" "Silver" +transition-metal+ }
    { "Cd" "Cadmium" +post-transition-metal+ }
    { "In" "Indium" +post-transition-metal+ }
    { "Sn" "Tin" +post-transition-metal+ }
    { "Sb" "Antimony" +metalloid+ }
    { "Te" "Tellurium" +metalloid+ }
    { "I" "Iodine" +reactive-non-metal+ }
    { "Xe" "Xenon" +noble-gas+ }
    { "Cs" "Caesium" +alkali-metal+ }
    { "Ba" "Barium" +alkaline-earth-metal+ }
    { "La" "Lanthanum" +lanthanide+ }
    { "Ce" "Cerium" +lanthanide+ }
    { "Pr" "Praseodymium" +lanthanide+ }
    { "Nd" "Neodymium" +lanthanide+ }
    { "Pm" "Promethium" +lanthanide+ }
    { "Sm" "Samarium" +lanthanide+ }
    { "Eu" "Europium" +lanthanide+ }
    { "Gd" "Gadolinium" +lanthanide+ }
    { "Tb" "Terbium" +lanthanide+ }
    { "Dy" "Dysprosium" +lanthanide+ }
    { "Ho" "Holmium" +lanthanide+ }
    { "Er" "Erbium" +lanthanide+ }
    { "Tm" "Thulium" +lanthanide+ }
    { "Yb" "Ytterbium" +lanthanide+ }
    { "Lu" "Lutetium" +lanthanide+ }
    { "Hf" "Hafnium" +transition-metal+ }
    { "Ta" "Tantalum" +transition-metal+ }
    { "W" "Tungsten" +transition-metal+ }
    { "Re" "Rhenium" +transition-metal+ }
    { "Os" "Osmium" +transition-metal+ }
    { "Ir" "Iridium" +transition-metal+ }
    { "Pt" "Platinum" +transition-metal+ }
    { "Au" "Gold" +transition-metal+ }
    { "Hg" "Mercury" +post-transition-metal+ }
    { "Tl" "Thallium" +post-transition-metal+ }
    { "Pb" "Lead" +post-transition-metal+ }
    { "Bi" "Bismuth" +post-transition-metal+ }
    { "Po" "Polonium" +post-transition-metal+ }
    { "At" "Astatine" +post-transition-metal+ }
    { "Rn" "Radon" +noble-gas+ }
    { "Fr" "Francium" +alkali-metal+ }
    { "Ra" "Radium" +alkaline-earth-metal+ }
    { "Ac" "Actinium" +actinide+ }
    { "Th" "Thorium" +actinide+ }
    { "Pa" "Protactinium" +actinide+ }
    { "U" "Uranium" +actinide+ }
    { "Np" "Neptunium" +actinide+ }
    { "Pu" "Plutonium" +actinide+ }
    { "Am" "Americium" +actinide+ }
    { "Cm" "Curium" +actinide+ }
    { "Bk" "Berkelium" +actinide+ }
    { "Cf" "Californium" +actinide+ }
    { "Es" "Einsteinium" +actinide+ }
    { "Fm" "Fermium" +actinide+ }
    { "Md" "Mendelevium" +actinide+ }
    { "No" "Nobelium" +actinide+ }
    { "Lr" "Lawrencium" +actinide+ }
    { "Rf" "Rutherfordium" +transition-metal+ }
    { "Db" "Dubnium" +transition-metal+ }
    { "Sg" "Seaborgium" +transition-metal+ }
    { "Bh" "Bohrium" +transition-metal+ }
    { "Hs" "Hassium" +transition-metal+ }
    { "Mt" "Meitnerium" +unknown+ }
    { "Ds" "Darmstadtium" +unknown+ }
    { "Rg" "Roentgenium" +unknown+ }
    { "Cn" "Copernicium" +post-transition-metal+ }
    { "Nh" "Nihonium" +unknown+ }
    { "Fl" "Flerovium" +unknown+ }
    { "Mc" "Moscovium" +unknown+ }
    { "Lv" "Livermorium" +unknown+ }
    { "Ts" "Tennesine" +unknown+ }
    { "Og" "Oganesson" +unknown+ }
}

CONSTANT: periodic-table {
    {   1   f   f   f   f   f   f   f   f   f   f   f   f   f   f   f   f   2 }
    {   3   4   f   f   f   f   f   f   f   f   f   f   5   6   7   8   9  10 }
    {  11  12   f   f   f   f   f   f   f   f   f   f  13  14  15  16  17  18 }
    {  19  20  21  22  23  24  25  26  27  28  29  30  31  32  33  34  35  36 }
    {  37  38  39  40  41  42  43  44  45  46  47  48  49  50  51  52  53  54 }
    {  55  56  57  72  73  74  75  76  77  78  79  80  81  82  83  84  85  86 }
    {  87  88  89 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 }
    f
    {   f   f   f  58  59  60  61  62  63  64  65  66  67  68  69  70  71   f }
    {   f   f   f  90  91  92  93  94  95  96  97  98  99 100 101 102 103   f }
    f
}

:: <element-label> ( atomic-number symbol name -- gadget )
    vertical <track>
    atomic-number number>string <label>
        [ 10 >>size ] change-font f track-add
    symbol <label> [ t >>bold? ] change-font f track-add
    name <label> [ 8 >>size ] change-font f track-add ;

: <element> ( atomic-number/f -- element )
    [
        dup 1 - elements nth first3
        [ <element-label> ] [ group-colors at ] bi*
    ] [
        "" <label> f
    ] if*
    [ { 40 35 } >>pref-dim { 5 5 } <border> ]
    [ [ <solid> >>interior ] when* ] bi* ;

: <element-button> ( atomic-number/f -- element )
    [ <element> ] keep [
        1 - elements nth second
        "https://en.wikipedia.org/wiki/" prepend
        '[ drop _ open-url ] <roll-button>
    ] when* ;

: <legend> ( -- gadget )
    horizontal <track> { 3 3 } >>gap
    group-colors [
        [ name>> rest but-last <label> { 3 3 } <border> ]
        [ <solid> >>interior ] bi*
        f track-add
    ] assoc-each ;

: <periodic-table> ( -- gadget )
    vertical <track> { 3 3 } >>gap
    periodic-table [
        horizontal <track> { 3 3 } >>gap swap
        [ [ <element-button> f track-add ] each ]
        [ "" <label> { 10 10 } >>pref-dim f track-add ] if*
        f track-add
    ] each <legend> f track-add ;

MAIN-WINDOW: periodic-table-window
    { { title "Periodic Table" } }
    <periodic-table> { 5 5 } <border> >>gadgets ;
