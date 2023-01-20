! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs math.order sequences ;
IN: compiler.cfg.comparisons

SYMBOL: +unordered+

SYMBOLS:
    cc<  cc<=  cc=  cc>  cc>=  cc<>  cc<>=
    cc/< cc/<= cc/= cc/> cc/>= cc/<> cc/<>= ;

SYMBOLS:
    vcc-all vcc-notall vcc-any vcc-none ;

SYMBOLS: cc-o cc/o ;

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
        { cc-o   cc/o   }
        { cc/o   cc-o   }
    } at ;

: negate-vcc ( cc -- cc' )
    H{
        { vcc-all vcc-notall }
        { vcc-any vcc-none }
        { vcc-none vcc-any }
        { vcc-notall vcc-all }
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
    } at member-eq? ;
