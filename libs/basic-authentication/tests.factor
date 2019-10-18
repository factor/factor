! Copyright (c) 2007 Chris Double.
! See http://factor.sf.net/license.txt for BSD license.
USING: kernel sha2 basic-authentication test namespaces base64 sequences ;
IN: temporary

{ t } [
  [
    H{ } clone realms set    
    H{ { "admin" "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8" } } "test-realm" add-realm
    "test-realm" "Basic " "admin:password" >base64 append authorization-ok?
  ] with-scope 
] unit-test 

{ f } [
  [
    H{ } clone realms set    
    H{ { "admin" "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8" } } "test-realm" add-realm
    "test-realm" "Basic " "admin:passwordx" >base64 append authorization-ok?
  ] with-scope 
] unit-test 

{ f } [
  [
    H{ } clone realms set    
    H{ { "admin" "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8" } } "test-realm" add-realm
    "test-realm" "Basic " "xadmin:password" >base64 append authorization-ok?
  ] with-scope 
] unit-test 

{ t } [
  [
    H{ } clone realms set    
    [ "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8" = swap "admin" = and ] "test-realm" add-realm
    "test-realm" "Basic " "admin:password" >base64 append authorization-ok?
  ] with-scope 
] unit-test 

{ f } [
  [
    H{ } clone realms set    
    [ "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8" = swap "admin" = and ] "test-realm" add-realm
    "test-realm" "Basic " "xadmin:password" >base64 append authorization-ok?
  ] with-scope 
] unit-test 

{ f } [
  [
    H{ } clone realms set    
    [ "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8" = swap "admin" = and ] "test-realm" add-realm
    "test-realm" "Basic " "admin:xpassword" >base64 append authorization-ok?
  ] with-scope 
] unit-test 

{ f } [
  [
    f realms set    
    "test-realm" "Basic " "admin:password" >base64 append authorization-ok?
  ] with-scope 
] unit-test 

{ f } [
  [
    H{ } clone realms set    
    "test-realm" "Basic " "admin:password" >base64 append authorization-ok?
  ] with-scope 
] unit-test 
