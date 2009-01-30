
USING: kernel namespaces vars ;

IN: self

VAR: self

: with-self ( quot obj -- ) [ >self call ] with-scope ;

: save-self ( quot -- ) self> [ self> clone >self call ] dip >self ;
