IN: specialized-arrays

ERROR: cannot-define-array-in-deployed-app type ;

: define-array-vocab ( type -- ) throw-cannot-define-array-in-deployed-app ;
