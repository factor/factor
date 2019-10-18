
USING: kernel namespaces vars ;

IN: self

VAR: self

: with-self ( quot obj -- ) [ >self call ] with-scope ;

: save-self ( quot -- ) self> >r self> clone >self call r> >self ;

! : save-self ( quot -- ) [ self> clone >self call ] with-scope ;