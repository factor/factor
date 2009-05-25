USING: accessors compiler.units combinators fry generalizations io
io.encodings.binary io.sockets kernel
parser sequences serialize vocabs vocabs.parser words ;
IN: modules.rpc

DEFER: get-words

: with-in-vocab ( vocab quot -- vocab ) over
  [ '[ _ set-current-vocab @ ] current-vocab name>> swap dip set-current-vocab ] dip vocab ; inline

: remote-quot ( addrspec vocabspec effect str -- quot )
   '[ _ 5000 <inet> binary
      [
         _ serialize _ in>> length narray serialize _ serialize flush deserialize dup length firstn
      ] with-client
    ] ;

: define-remote ( addrspec vocabspec effect str -- ) [
      [ remote-quot ] 2keep create-in -rot define-declared word make-inline
   ] with-compilation-unit ;

: remote-vocab ( addrspec vocabspec -- vocab )
   dup "-remote" append [ 
      [ (( -- words )) [ "get-words" remote-quot ] keep call-effect ] 2keep
      [ rot first2 swap define-remote ] 2curry each
   ] with-in-vocab ;