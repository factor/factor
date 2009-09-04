! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs math.order sequences ;
IN: compiler.cfg.comparisons

SYMBOL: +unordered+

SYMBOLS:
    cc<  cc<=  cc=  cc>  cc>=  cc<>  cc<>= 
    cc/< cc/<= cc/= cc/> cc/>= cc/<> cc/<>= ;

: negate-cc ( cc -- cc' )
    H{
        { cc<    cc/<   }
        { cc<=   cc/<=  }
        { cc>    cc/>   }
        { cc>=   cc/>=  }
        { cc=    cc/=   }
        { cc<>   cc/<>  }
        { cc<>=  cc/<>= }
        { cc/<   cc<    } 
        { cc/<=  cc<=   }
        { cc/>   cc>    }
        { cc/>=  cc>=   } 
        { cc/=   cc=    } 
        { cc/<>  cc<>   } 
        { cc/<>= cc<>=  }
    } at ;

: swap-cc ( cc -- cc' )
    H{
        { cc<   cc> }
        { cc<=  cc>= }
        { cc>   cc< }
        { cc>=  cc<= }
        { cc=   cc= }
        { cc<>  cc<> }
        { cc<>= cc<>= }
        { cc/<   cc/> }
        { cc/<=  cc/>= }
        { cc/>   cc/< }
        { cc/>=  cc/<= }
        { cc/=   cc/= }
        { cc/<>  cc/<> }
        { cc/<>= cc/<>= }
    } at ;

: order-cc ( cc -- cc' )
    H{
        { cc<    cc<  }
        { cc<=   cc<= }
        { cc>    cc>  }
        { cc>=   cc>= }
        { cc=    cc=  }
        { cc<>   cc/= }
        { cc<>=  t    }
        { cc/<   cc>= } 
        { cc/<=  cc>  }
        { cc/>   cc<= }
        { cc/>=  cc<  } 
        { cc/=   cc/= } 
        { cc/<>  cc=  } 
        { cc/<>= f    }
    } at ;

: evaluate-cc ( result cc -- ? )
    H{
        { cc<    { +lt+                       } }
        { cc<=   { +lt+ +eq+                  } }
        { cc=    {      +eq+                  } }
        { cc>=   {      +eq+ +gt+             } }
        { cc>    {           +gt+             } }
        { cc<>   { +lt+      +gt+             } }
        { cc<>=  { +lt+ +eq+ +gt+             } }
        { cc/<   {      +eq+ +gt+ +unordered+ } }
        { cc/<=  {           +gt+ +unordered+ } }
        { cc/=   { +lt+      +gt+ +unordered+ } }
        { cc/>=  { +lt+           +unordered+ } }
        { cc/>   { +lt+ +eq+      +unordered+ } }
        { cc/<>  {      +eq+      +unordered+ } }
        { cc/<>= {                +unordered+ } }
    } at memq? ;

