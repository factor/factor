! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors documents io.styles kernel namespaces
sequences tools.test ui.tools.listener.history ;

{ } [ <document> "d" set ] unit-test
{ } [ "d" get <empty-history> "h" set ] unit-test

{ } [ "1" "d" get set-doc-string ] unit-test
{ T{ input f "1" } } [ "h" get history-add ] unit-test

{ } [ "2" "d" get set-doc-string ] unit-test
{ T{ input f "2" } } [ "h" get history-add ] unit-test

{ } [ "3" "d" get set-doc-string ] unit-test
{ T{ input f "3" } } [ "h" get history-add ] unit-test

{ } [ "" "d" get set-doc-string ] unit-test

{ } [ "h" get history-recall-previous ] unit-test
{ "3" } [ "d" get doc-string ] unit-test

{ } [ "h" get history-recall-previous ] unit-test
{ "2" } [ "d" get doc-string ] unit-test

{ } [ "h" get history-recall-previous ] unit-test
{ "1" } [ "d" get doc-string ] unit-test

{ } [ "h" get history-recall-previous ] unit-test
{ "1" } [ "d" get doc-string ] unit-test

{ } [ "h" get history-recall-next ] unit-test
{ "2" } [ "d" get doc-string ] unit-test

{ } [ "22" "d" get set-doc-string ] unit-test

{ } [ "h" get history-recall-next ] unit-test
{ "3" } [ "d" get doc-string ] unit-test

{ } [ "h" get history-recall-previous ] unit-test
{ "22" } [ "d" get doc-string ] unit-test

{ } [ "h" get history-recall-previous ] unit-test
{ "1" } [ "d" get doc-string ] unit-test

{ } [ "222" "d" get set-doc-string ] unit-test
{ T{ input f "222" } } [ "h" get history-add ] unit-test

{ } [ "h" get history-recall-previous ] unit-test
{ } [ "h" get history-recall-previous ] unit-test
{ } [ "h" get history-recall-previous ] unit-test

{ "22" } [ "d" get doc-string ] unit-test

{ } [ <document> "d" set ] unit-test
{ } [ "d" get <empty-history> "h" set ] unit-test

{ } [ "aaa" "d" get set-doc-string ] unit-test
{ T{ input f "aaa" } } [ "h" get history-add ] unit-test

{ } [ "" "d" get set-doc-string ] unit-test
{ T{ input f "" } } [ "h" get history-add ] unit-test
{ T{ input f "" } } [ "h" get history-add ] unit-test
{ } [ "   " "d" get set-doc-string ] unit-test
{ } [ "h" get history-recall-previous ] unit-test

{ 1 } [
    "abc" <document> [ set-doc-string ] [ <empty-history> ] bi
    [ history-add drop ]
    [ history-add drop ]
    [ elements>> length ] tri
] unit-test
