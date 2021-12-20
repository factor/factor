USING: classes.dispatch.covariant-tuples classes.dispatch.eql
classes.dispatch.syntax math tools.test ;
IN: classes.dispatch.syntax.tests


{ T{ covariant-tuple f {
         T{ class-specializer f fixnum }
         float
     }
   } }
[ { \ fixnum float } interpret-dispatch-spec ] unit-test
