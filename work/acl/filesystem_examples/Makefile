CFLAGS= -ansi -Wall -g
.c:
	gcc-4.0 $(CFLAGS) -o $@ $<
.c.o:
	gcc-4.0 $(CFLAGS) -c $<

TARGETS = acl_api_fragment kqueue_fragment rmx setx lsx


default all:    $(TARGETS) Makefile

clobber clean:
	rm -f $(TARGETS) *.o a.out

