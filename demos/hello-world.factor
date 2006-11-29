! This is a bit more complex than the simplest hello world,
! which is:
!   "Hello World" print
! Instead, we define a module, and a main entry hook; when you
! run the module in the listener with the following command,
!   "demos/hello-world" run-module
! It prints the above message.

USING: io ;
PROVIDE: demos/hello-world ;
MAIN: demos/hello-world "Hello World" print ;
