! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test alien.cxx.syntax alien.inline.syntax
alien.marshall.syntax alien.marshall accessors kernel ;
IN: alien.cxx.syntax.tests

DELETE-C-LIBRARY: test
C-LIBRARY: test

COMPILE-AS-C++

C-INCLUDE: <string>

C-TYPEDEF: std::string string

C++-CLASS: std::string c++-root

GENERIC: to-string ( obj -- str )

C++-METHOD: std::string to-string const-char* c_str ( )

CM-FUNCTION: std::string* new_string ( const-char* s )
    return new std::string(s);
;

;C-LIBRARY

ALIAS: <std::string> new_string

{ 1 1 } [ new_string ] must-infer-as
{ 1 1 } [ c_str_std__string ] must-infer-as
[ t ] [ "abc" <std::string> std::string? ] unit-test
[ "abc" ] [ "abc" <std::string> to-string ] unit-test


DELETE-C-LIBRARY: inheritance
C-LIBRARY: inheritance

COMPILE-AS-C++

C-INCLUDE: <cstring>

<RAW-C
class alpha {
    public:
    alpha(const char* s) {
        str = s;
    };
    const char* render() {
        return str;
    };
    virtual const char* chop() {
        return str;
    };
    virtual int length() {
        return strlen(str);
    };
    const char* str;
};

class beta : alpha {
    public:
    beta(const char* s) : alpha(s + 1) { };
    const char* render() {
        return str + 1;
    };
    virtual const char* chop() {
        return str + 2;
    };
};
RAW-C>

C++-CLASS: alpha c++-root
C++-CLASS: beta alpha

CM-FUNCTION: alpha* new_alpha ( const-char* s )
    return new alpha(s);
;

CM-FUNCTION: beta* new_beta ( const-char* s )
    return new beta(s);
;

ALIAS: <alpha> new_alpha
ALIAS: <beta> new_beta

GENERIC: render ( obj -- obj )
GENERIC: chop ( obj -- obj )
GENERIC: length ( obj -- n )

C++-METHOD: alpha render const-char* render ( )
C++-METHOD: beta render const-char* render ( )
C++-VIRTUAL: alpha chop const-char* chop ( )
C++-VIRTUAL: beta chop const-char* chop ( )
C++-VIRTUAL: alpha length int length ( )

;C-LIBRARY

{ 1 1 } [ render_alpha ] must-infer-as
{ 1 1 } [ chop_beta ] must-infer-as
{ 1 1 } [ length_alpha ] must-infer-as
[ t ] [ "x" <alpha> alpha#? ] unit-test
[ t ] [ "x" <alpha> alpha? ] unit-test
[ t ] [ "x" <beta> alpha? ] unit-test
[ f ] [ "x" <beta> alpha#? ] unit-test
[ 5 ] [ "hello" <alpha> length ] unit-test
[ 4 ] [ "hello" <beta> length ] unit-test
[ "hello" ] [ "hello" <alpha> render ] unit-test
[ "llo" ] [ "hello" <beta> render ] unit-test
[ "ello" ] [ "hello" <beta> underlying>> \ alpha# new swap >>underlying render ] unit-test
[ "hello" ] [ "hello" <alpha> chop ] unit-test
[ "lo" ] [ "hello" <beta> chop ] unit-test
[ "lo" ] [ "hello" <beta> underlying>> \ alpha# new swap >>underlying chop ] unit-test
