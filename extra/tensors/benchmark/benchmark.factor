! Copyright (C) 2019 HMC Clinic.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays kernel locals math math.functions math.statistics memory
sequences tools.time ;
IN: tensors.benchmark

! puts items from els (a quotation) on stack, runs ops (a quot w no stack effect) n times
! returns an array with times (ns) for each trial
:: benchmark-multiple ( els: ( -- .. ) op: ( .. -- .. ) n -- ..arr )
    ! put els on stack
    els call
    ! create array
    n 0 <array> :> arr
    ! perform op n times
    n [ gc [ op benchmark ] dip arr set-nth ] each-integer
    arr ; inline


! finds the confidence interval of seq with significance level 95
:: confidence-interval ( seq -- {c1,c2} )
    seq mean :> m
    ! HARDCODING ALERT: z value for alpha = 95 is 1.96
    seq sample-std 1.96 *
    ! div by sqrt(n)
    seq length sqrt / :> modifier
    m modifier -
    m modifier +
    2array ;
