USING: kernel peg regexp2 sequences tools.test ;
IN: regexp2.tests

[ T{ parse-result f T{ slice f 3 3 "056" } 46 } ]
    [ "056" 'octal' parse ] unit-test
