To build libharu as a shared dylib on Mac OS X, modify the Makefile after calling ./configure --sharedHere are the relevant sections and the lines to be changed:...CC=ccPREFIX=/usr/localLIBNAME=libhpdf.aSONAME=libhpdf.dylibSOVER1=.1SOVER2=.0.0LIBTARGET=libhpdf.dylibCFLAGS=-Iinclude -fPIC -fno-common -c...$(SONAME): $(OBJS)$(CC) -dynamiclib -o $(SONAME)$(SOVER1)$(SOVER2) $(OBJS) $(LDFLAGS) -Wlln -sf $(SONAME)$(SOVER1)$(SOVER2) $(SONAME)$(SOVER1)ln -sf $(SONAME)$(SOVER1) $(SONAME)

Now you can build and install:

make clean
make
make install

Test PDF files from pdf-tests.factor are generated in the test folder.