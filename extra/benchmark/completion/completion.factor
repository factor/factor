
USING: kernel sequences tools.completion ;

IN: benchmark.completion

: completion-benchmark ( -- )
    "nth" 25,000 [
        {
            nth ?nth nths set-nth insert-nth
            remove-nth remove-nth! change-nth
        }
    ] replicate concat [ named completions ] keep
    2length assert= ;

MAIN: completion-benchmark
