USING: command-line.parser kernel math math.parser namespaces
prettyprint random sequences ;

IN: tools.random

CONSTANT: OPTIONS {
    T{ option
        { name "--integer" }
        { help "compute a random integer" }
        { const t }
        { default f }
    }
    T{ option
        { name "--float" }
        { help "compute a random float" }
        { const t }
        { default f }
    }
    T{ option
        { name "--choice" }
        { help "compute a random choice" }
        { const t }
        { default f }
    }
    T{ option
        { name "input" }
        { help "the random input" }
        { #args "*" }
    }
}

MAIN: [
    OPTIONS [
        "input" get [ [ string>number ] keep or ] map
        "integer" get [ [ >integer ] map ] when
        "float" get [ [ >float ] map ] when
        "choice" get [ random . ] [ [ random . ] each ] if
    ] with-options
]

