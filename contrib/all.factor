USING: modules words  ;

REQUIRE: aim cairo concurrency coroutines crypto dlists
embedded gap-buffer httpd math postgresql process random-tester
splay-trees sqlite units ;

"x11" vocab [
    "factory" require
    "x11" require
]
