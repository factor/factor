USING: drunken-bishop io.streams.string tools.test ;

{ "\
+-----------------+
|       .=o.  .   |
|     . *+*. o    |
|      =.*..o     |
|       o + ..    |
|        S o.     |
|         o  .    |
|          .  . . |
|              o .|
|               E.|
+-----------------+
" } [
    [
        "fc94b0c1e5b0987c5843997697ee9fb7" drunken-bishop.
    ] with-string-writer
] unit-test

{ "\
+-----------------+
|       .=o.  .   |
|     . *+*. o    |
|      =.*..o     |
|       o + ..    |
|        S o.     |
|         o  .    |
|          .  . . |
|              o .|
|               E.|
+-----------------+
" } [
    [
        "fc94b0c1e5b0987c5843997697ee9fb7" drunken-bishop.
    ] with-string-writer
] unit-test
