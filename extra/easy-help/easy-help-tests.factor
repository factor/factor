USING: easy-help help.markup tools.test ;

{ { $description } } [ $description{ } ] unit-test

{ { $description "this and that" } } [
    $description{ this and that }
] unit-test

{ { $description { $snippet "this" } " and that" } } [
    $description{ { $snippet "this" } and that }
] unit-test

{ { $description "this " { $snippet "and" } " that" } } [
    $description{ this { $snippet "and" } that }
] unit-test

{ { $description "this and " { $snippet "that" } } } [
    $description{ this and { $snippet "that" } }
] unit-test

{ { $description "this and " { $snippet "that" } "." } } [
    $description{ this and { $snippet "that" } . }
] unit-test

{ { $description "this, " { $snippet "that" } ", and the other." } } [
    $description{ this, { $snippet "that" } , and the other. }
] unit-test
