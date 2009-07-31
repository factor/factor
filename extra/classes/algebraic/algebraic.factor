USING: classes.parser classes.tuple classes.union kernel peg
peg-lexer sequences ;
IN: classes.algebraic

ON-BNF: DATA:
tokenizer = <foreign factor>
delimit = "|" => [[ drop ignore ]]
tuple = (!("|"|";").)+ => [[ unclip create-class-in [ tuple rot define-tuple-class ] keep ]]
expr = . tuple (delimit tuple)* ";" => [[ first3 swap prefix [ create-class-in ] dip define-union-class ignore ]]
;ON-BNF