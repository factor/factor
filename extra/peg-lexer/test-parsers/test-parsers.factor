USING: peg-lexer math.parser strings ;
IN: peg-lexer.test-parsers

ON-BNF: test1
      num = [1-4]* => [[ >string ]]
      expr = num ( "-end" | "-done" )
;ON-BNF

ON-BNF: test2
      num = [1-4]* => [[ >string string>number ]]
      expr= num [5-9]
;ON-BNF

ON-BNF: test3
      tokenizer = <foreign factor>
      expr= "heavy" "duty" "testing"
;ON-BNF