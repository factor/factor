! This is a bit more complex than the simplest hello world,
! which is:
!   "Hello World" print
! Instead, we define a module, and a main entry hook; when you
! run the module in the listener with the following command,
!   "examples/hello-world" run-module
! It prints the above message.

PROVIDE: examples/hello-world ;
MAIN: examples/hello-world "Hello World" print ;
