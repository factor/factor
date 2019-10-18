! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: math.functions math.similarity tools.test ;

IN: math.similarity.tests

CONSTANT: a { 1 2 1 5 1 0 0 }
CONSTANT: b { 0 0 0 0 2 3 1 }

{ t } [ a a euclidian-similarity 1.0 1e-10 ~ ] unit-test
{ t } [ a b euclidian-similarity 0.1336766024001917 1e-10 ~ ] unit-test

{ t } [ a a pearson-similarity 1.0 1e-10 ~ ] unit-test
{ t } [ a b pearson-similarity 0.2376861940759582 1e-10 ~ ] unit-test

{ t } [ a a cosine-similarity 1.0 1e-10 ~ ] unit-test
{ t } [ a b cosine-similarity 0.5472455591261534 1e-10 ~ ] unit-test
