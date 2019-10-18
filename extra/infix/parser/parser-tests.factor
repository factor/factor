! Copyright (C) 2009 Philipp Brüschweiler
! See http://factorcode.org/license.txt for BSD license.
USING: infix.ast infix.parser infix.tokenizer tools.test ;
IN: infix.parser.tests

[ T{ ast-number { value 1 } } ] [ "1" build-infix-ast ] unit-test
[ T{ ast-negation f T{ ast-number { value 1 } } } ]
[ "-1" build-infix-ast ] unit-test
[ T{ ast-op
    { left
        T{ ast-op
            { left T{ ast-number { value 1 } } }
            { right T{ ast-number { value 2 } } }
            { op "+" }
        }
    }
    { right T{ ast-number { value 4 } } }
    { op "+" }
} ] [ "1+2+4" build-infix-ast ] unit-test

[ T{ ast-op
    { left T{ ast-number { value 1 } } }
    { right
        T{ ast-op
            { left T{ ast-number { value 2 } } }
            { right T{ ast-number { value 3 } } }
            { op "*" }
        }
    }
    { op "+" }
} ] [ "1+2*3" build-infix-ast ] unit-test

[ T{ ast-op 
    { left T{ ast-number { value 1 } } }
    { right T{ ast-number { value 2 } } }
    { op "+" }
} ] [ "(1+2)" build-infix-ast ] unit-test

[ T{ ast-local { name "foo" } } ] [ "foo" build-infix-ast ] unit-test
[ "-" build-infix-ast ] must-fail

[ T{ ast-function
    { name "foo" }
    { arguments
        V{
            T{ ast-op
                { left T{ ast-number { value 1 } } }
                { right T{ ast-number { value 2 } } }
                { op "+" }
            }
            T{ ast-op
                { left T{ ast-number { value 2 } } }
                { right T{ ast-number { value 3 } } }
                { op "%" }
            }
        }
    }
} ] [ "foo (1+ 2,2%3)  " build-infix-ast ] unit-test

[ T{ ast-op
    { left
        T{ ast-op
            { left
                T{ ast-function
                    { name "bar" }
                    { arguments V{ } }
                }
            }
            { right
                T{ ast-array
                    { name "baz" }
                    { index
                        T{ ast-op
                            { left
                                T{ ast-op
                                    { left
                                        T{ ast-number
                                            { value 2 }
                                        }
                                    }
                                    { right
                                        T{ ast-number
                                            { value 3 }
                                        }
                                    }
                                    { op "/" }
                                }
                            }
                            { right
                                T{ ast-number { value 4 } }
                            }
                            { op "+" }
                        }
                    }
                }
            }
            { op "+" }
        }
    }
    { right T{ ast-number { value 2 } } }
    { op "/" }
} ] [ "(bar() + baz[2/ 3+4 ] )/2" build-infix-ast ] unit-test

[ T{ ast-op
    { left T{ ast-number { value 1 } } }
    { right
        T{ ast-op
            { left T{ ast-number { value 2 } } }
            { right T{ ast-number { value 3 } } }
            { op "/" }
        }
    }
    { op "+" }
} ] [ "1\n+\n2\r/\t3" build-infix-ast ] unit-test

[ T{ ast-negation
    { term
        T{ ast-function
            { name "foo" }
            { arguments
                V{
                    T{ ast-number { value 2 } }
                    T{ ast-negation
                        { term T{ ast-number { value 3 } } }
                    }
                }
            }
        }
    }
} ] [ "-foo(+2,-3)" build-infix-ast ] unit-test

[ T{ ast-array
    { name "arr" }
    { index
        T{ ast-op
            { left
                T{ ast-negation
                    { term
                        T{ ast-op
                            { left
                                T{ ast-function
                                    { name "foo" }
                                    { arguments
                                        V{
                                            T{ ast-number
                                                { value 2 }
                                            }
                                        }
                                    }
                                }
                            }
                            { right
                                T{ ast-negation
                                    { term
                                        T{ ast-number
                                            { value 1 }
                                        }
                                    }
                                }
                            }
                            { op "+" }
                        }
                    }
                }
            }
            { right T{ ast-number { value 3 } } }
            { op "/" }
        }
    }
} ] [ "+arr[-(foo(2)+-1)/3]" build-infix-ast ] unit-test

[ "foo bar baz" build-infix-ast ] must-fail
[ "1+2/4+" build-infix-ast ] must-fail
[ "quaz(2/3,)" build-infix-ast ] must-fail
