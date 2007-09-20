USING: kernel sequences namespaces errors io math tables arrays generic hashtables vectors strings parser ;
USING: prettyprint test ;
USING: regexp-internals regexp ;

[ "dog" ] [ "dog" "cat|dog" make-regexp regexp-match first >string ] unit-test 
[ "cat" ] [ "cat" "cat|dog" make-regexp regexp-match first >string ] unit-test 
[ "a" ] [ "a" "a|b|c" make-regexp regexp-match first >string ] unit-test 
[ "" ] [ "" "a*" make-regexp regexp-match first >string ] unit-test 
[ "aaaa" ] [ "aaaa" "a*" make-regexp regexp-match first >string ] unit-test 
[ "aaaa" ] [ "aaaa" "a+" make-regexp regexp-match first >string ] unit-test 
[ t ] [ "" "a+" make-regexp regexp-match empty? ] unit-test 
[ "cadog" ] [ "cadog" "ca(t|d)og" make-regexp regexp-match first >string ] unit-test 
[ "catog" ] [ "catog" "ca(t|d)og" make-regexp regexp-match first >string ] unit-test 
[ "cadog" ] [ "abcadoghi" "ca(t|d)og" make-regexp regexp-match first >string ] unit-test 
[ t ] [ "abcatdoghi" "ca(t|d)og" make-regexp regexp-match empty? ] unit-test 

[ "abcdefghijklmnopqrstuvwxyz" ] [ "abcdefghijklmnopqrstuvwxyz" "a+b+c+d+e+f+g+h+i+j+k+l+m+n+o+p+q+r+s+t+u+v+w+x+y+z+" make-regexp regexp-match first >string ] unit-test 
[ "aabbccddeeffgghhiijjkkllmmnnooppqqrrssttuuvvwwxxyyzz" ] [ "aabbccddeeffgghhiijjkkllmmnnooppqqrrssttuuvvwwxxyyzz" "a+b+c+d+e+f+g+h+i+j+k+l+m+n+o+p+q+r+s+t+u+v+w+x+y+z+" make-regexp regexp-match first >string ] unit-test 
[ t ] [ "aabbccddeeffgghhiijjkkllmmnnooppqqrrssttuuvvwwxxyy" "a+b+c+d+e+f+g+h+i+j+k+l+m+n+o+p+q+r+s+t+u+v+w+x+y+z+" make-regexp regexp-match empty? ] unit-test 
[ "abcdefghijklmnopqrstuvwxyz" ] [ "abcdefghijklmnopqrstuvwxyz" "a*b*c*d*e*f*g*h*i*j*k*l*m*n*o*p*q*r*s*t*u*v*w*x*y*z*" make-regexp regexp-match first >string ] unit-test 
[ "" ] [ "" "a*b*c*d*e*f*g*h*i*j*k*l*m*n*o*p*q*r*s*t*u*v*w*x*y*z*" make-regexp regexp-match first >string ] unit-test 
[ "az" ] [ "az" "a*b*c*d*e*f*g*h*i*j*k*l*m*n*o*p*q*r*s*t*u*v*w*x*y*z*" make-regexp regexp-match first >string ] unit-test 

[ t ] [ "abc" "a?b?c?" make-regexp regexp-match length 3 = ] unit-test
[ "ac" ] [ "ac" "a?b?c?" make-regexp regexp-match first >string ] unit-test
[ "" ] [ "" "a?b?c?" make-regexp regexp-match first >string ] unit-test
[ t ] [ "aabc" "a?b?c?" make-regexp regexp-match length 4 = ] unit-test
[ "abbbccdefefffeffe" ] [ "abbbccdefefffeffe" "(a?b*c+d(e|f)*)+" make-regexp regexp-match first >string ] unit-test
[ t ] [ "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "a?a?a?a?a?a?a?a?a?a?a?a?a?a?a?a?a?a?a?a?a?a?a?a?a?a?a?a?a?aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" make-regexp regexp-match length 29 = ] unit-test

