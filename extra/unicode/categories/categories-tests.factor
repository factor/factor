USING: tools.test kernel unicode.categories words sequences unicode.syntax ;

[ { f f t t f t t f f t } ] [ CHAR: A { 
    blank? letter? LETTER? Letter? digit? 
    printable? alpha? control? uncased? character? 
} [ execute ] curry* map ] unit-test
[ "Nd" ] [ CHAR: 3 category ] unit-test
