
USING: kernel sequences math ;

IN: sequences.lib

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: picker ( quot -- quot ) [ 2dup ] swap append [ 0 > -rot ? ] append ;

: maximum ( seq quot -- item ) >r dup first swap r> picker each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: compare-length ( a b -- n ) >r length r> length <=> ;

: longest ( seq -- obj ) [ compare-length ] maximum ;
