USING: arrays command-line io kernel math math.floats.env math.floats.env.private namespaces parser sequences prettyprint system ;
IN: sh.integer-env.true-probe
command-line get first run-file
floating-point-supported? dup "NORMAL-FP-CAPABILITY" print . [ ] [ 5 exit ] if
get-fp-env 4array dup [ first4 set-fp-env ] dip get-fp-env 4array =
dup "NORMAL-FP-ENV-ROUNDTRIP" print . [ 0 ] [ 6 ] if exit
