! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors calendar constructors db2.types orm
orm.persistent sequences multiline ;
IN: orm.examples

TUPLE: user id name age ;
CONSTRUCTOR: <user> user ( name age -- obj ) ;
TUPLE: score id user score ;

PERSISTENT: user
    { "id" +db-assigned-key+ }
    { "name" VARCHAR }
    { "age" INTEGER } ;

PERSISTENT: score
    { "id" +db-assigned-key+ }
    { "user" user }
    { "score" INTEGER } ;


TUPLE: user2 id name age ;
CONSTRUCTOR: <user2> user2 ( name age -- obj ) ;
TUPLE: score2 id user score ;

PERSISTENT: user2
    { "id" INTEGER +primary-key+ }
    { "name" VARCHAR }
    { "age" INTEGER } ;

PERSISTENT: score2
    { "id" INTEGER +primary-key+ }
    { "user" user2 }
    { "score" INTEGER } ;


TUPLE: user3 id name age ;
CONSTRUCTOR: <user3> user3 ( name age -- obj ) ;
TUPLE: score3 id user score ;

PERSISTENT: user3
    { "id" INTEGER +primary-key+ }
    { "name" VARCHAR NOT-NULL }
    { "age" INTEGER NOT-NULL } ;

PERSISTENT: score3
    { "id" INTEGER +primary-key+ }
    { "user" user3 NOT-NULL }
    { "score" INTEGER NOT-NULL } ;


/*

T{ score2
    {
        user
        T{ user { "name" "erg" } }
    }
} select-tuples

{
    T{ score
        { id 0 }
        { user T{ user { id 0 } { name "erg" } { age 28 } } }
        { score 100 }
    }
    T{ score
        { id 1 }
        { user T{ user { id 0 } { name "erg" } { age 28 } } }
        { score 106 }
    }
}
*/

TUPLE: jar id name beans ;
TUPLE: bean id ;

PERSISTENT: bean
    { "id" INTEGER +primary-key+ } ;

PERSISTENT: jar
    { "id" INTEGER +primary-key+ }
    { "name" VARCHAR }
    { "beans" { bean sequence } } ;

/*

T{ bean } select-tuples
{
    T{ bean { id 1 } }
    T{ bean { id 2 } }
    T{ bean { id 3 } }
    T{ bean { id 4 } }
}

T{ jar } select-tuples
{
    T{ jar { id 1 } { "beans1" }
        { beans { T{ bean { id 1 } } T{ bean { id 2 } } } }
    }
    T{ jar { id 2 } { "beans2" }
        { beans { T{ bean { id 3 } } T{ bean { id 4 } } } }
    }
}

T{ jar { beans IGNORE } } select-tuples
{
    T{ jar { id 1 } { "beans1" } }
    T{ jar { id 2 } { "beans2" } }
}

*/

! Blogs
TUPLE: entity id author date content ;
CONSTRUCTOR: <entity> entity ( author content -- entity ) now >>date ;
PERSISTENT: entity
    { "id" +db-assigned-key+ }
    { "author" VARCHAR NOT-NULL } ! uid
    { "date" TIMESTAMP NOT-NULL }
    { "content" TEXT NOT-NULL } ;

TUPLE: post < entity title comments ;
CONSTRUCTOR: <post> post ( title -- entity ) now >>date ;
PERSISTENT: post
    { "title" VARCHAR NOT-NULL }
    { "comments" { entity sequence } } ;
