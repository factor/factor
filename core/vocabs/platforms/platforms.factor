! Copyright (C) 2018 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors compiler.units kernel multiline parser
sequences splitting system vocabs.parser ;
IN: vocabs.platforms

: with-vocabulary ( quot suffix -- )
    [
        [ [ current-vocab name>> ] dip ?tail drop ]
        [ append ] bi set-current-vocab
        call
    ] [
        [ current-vocab name>> ] dip ?tail drop set-current-vocab
    ] bi ; inline

: parse-platform-section ( string suffix -- )
    [
        [ [ string-lines parse-lines ] curry with-nested-compilation-unit ]
        curry
    ] dip
    ! XXX: call( -- ) -> drop for definitions only
    ! or make call( -- ) smart-infer the quot
    with-vocabulary call( -- ) ; inline
