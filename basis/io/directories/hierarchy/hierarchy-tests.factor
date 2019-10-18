USING: io.directories io.directories.hierarchy kernel
sequences tools.test ;

{ { "classes/tuple/tuple.factor" } } [
    "resource:core" [
        "." directory-tree-files [ "classes/tuple/tuple.factor" = ] filter
    ] with-directory
] unit-test

{ { "classes/tuple" } } [
    "resource:core" [
        "." directory-tree-files [ "classes/tuple" = ] filter
    ] with-directory
] unit-test

{ { "classes/tuple/tuple.factor" } } [
    "resource:core" [
        [ "classes/tuple/tuple.factor" = ] filter
    ] with-directory-tree-files
] unit-test
