IN: temporary
USING: tools completion words sequences test ;

[ ] [ "" apropos ] unit-test
[ ] [ "swp" apropos ] unit-test
[ f ] [ "swp" all-words word-completions empty? ] unit-test
