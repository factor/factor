! Copyright (C) 2019 HMC Clinic.
! See http://factorcode.org/license.txt for BSD license.

USING: arrays accessors csv io io.encodings.utf8 kernel locals math math.parser
math.statistics prettyprint sequences tensors ;
IN: tensors.demos

<PRIVATE

! Normalize across each of the features
:: normalize ( X -- norm )
    X X mean t- X std t/
;

:: compute-cost ( X y params -- cost )
    ! Compute (1/(2*n_samples))
    1 2 y shape>> first * /
    ! Compute h
    X params matmul
    ! Compute sum((h-y)**2)
    y t- dup t* sum
    ! Multiply to get final cost
    * ;

:: gradient-descent ( X y params lr n-iters -- history params )
    lr y shape>> first / :> batch-lr
    { n-iters } zeros :> history
    X transpose :> X-T
    params
    n-iters [
        ! Update params with
        ! params = params - (learning_rate/n_samples) * X.T @ (X @ params - y)
        swap dup :> old-params
        batch-lr X-T X old-params matmul y t- matmul t* t- :> new-params
        ! Compute the cost and add it to the history
        X y new-params compute-cost swap history set-nth
        new-params
    ] each-integer
    history swap ;

PRIVATE>

:: linear-regression ( X y lr n-iters -- )
    X normalize
    ! Add the constant coefficient
    y shape>> first 1 2array ones swap 2array hstack :> X-norm
    ! Create the array of parameters
    X-norm shape>> second 1 2array zeros :> params
    ! Compute the initial cost
    X-norm y params compute-cost
    ! Print!
    number>string "The initial cost is " swap append print
    ! Perform gradient descent
    X-norm y params lr n-iters gradient-descent
    "The optimal parameters are " print .
    last number>string "The final cost was " swap append print
    ;

! Load and return the boston house-prices dataset
: load-boston-data ( -- X y )
    "vocab:tensors/demos/data.csv" utf8 file>csv
    [ [ string>number ] map ] map >tensor
    "vocab:tensors/demos/target.csv" utf8 file>csv
    [ [ string>number ] map ] map >tensor ;