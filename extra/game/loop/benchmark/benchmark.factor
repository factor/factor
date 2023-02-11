! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types classes.struct game.loop
game.loop.private kernel sequences specialized-vectors
tools.time.struct ;
IN: game.loop.benchmark

STRUCT: game-loop-benchmark
    { benchmark-data-pair benchmark-data-pair }
    { tick# ulonglong }
    { frame# ulonglong } ;

SPECIALIZED-VECTOR: game-loop-benchmark

: <game-loop-benchmark> ( benchmark-data-pair tick frame -- obj )
    \ game-loop-benchmark new
        swap >>frame#
        swap >>tick#
        swap >>benchmark-data-pair ; inline

: ensure-benchmark-data ( loop -- vector )
    dup benchmark-data>> [
        game-loop-benchmark-vector{ } clone
        >>benchmark-data
    ] unless
    benchmark-data>> ; inline

M: game-loop record-benchmarking ( loop quot: ( loop -- benchmark-data-pair ) -- )
    [
        [ [ call( loop -- ) ] with-benchmarking ]
        [ drop tick#>> ]
        [ drop frame#>> ]
        2tri
        <game-loop-benchmark>
    ]
    [ drop ensure-benchmark-data ]
    2bi push ;
