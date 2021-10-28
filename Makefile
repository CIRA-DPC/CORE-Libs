# path macros
srcdir := src
prefix := $(abspath build)
exec_prefix := $(prefix)
bindir := $(exec_prefix)/bin
libdir := $(exec_prefix)/lib
includedir := $(prefix)/include

# tool macros
CC := icc
FCC := ifort
CXX := icpc

# complier and linker flags
CFLAGS := -I$(includedir) $(CFLAGS) -I/usr/local/include -I/usr/include
FFLAGS := -I$(includedir) $(FFLAGS) -I/usr/local/include -I/usr/include
CXXFLAGS := -I$(includedir) $(CXXFLAGS) -I/usr/local/include -I/usr/include
LDFLAGS := -L$(libdir) $(LDFLAGS) -L/usr/local/lib -L/usr/lib

BASE_LIBS := libfl.a libjpeg.a libsz.a liby.a libz.a
ALL_LIBS := $(BASE_LIBS) libhdf.a libhdfeos.a

ifeq ($(BUILD_LIBTIRPC),true)
    EXTRA_LIBS := libtirpc.a
    LIBS := ${LIBS} -ltirpc
endif

vpath %.tar.gz $(srcdir)
vpath %.a $(libdir)

# clean files list
CLEAN_LIST := $(TARGET)

# default rule
default: makedir all

.PHONY: all
all: $(ALL_LIBS)

.PHONY: base
base: $(BASE_LIBS)

libhdfeos.a: hdf-eos2-3.0-src.tar.gz base libhdf.a
	LD_LIBRARY_PATH="$(prefix)/lib:$LD_LIBRARY_PATH" PREFIX="$(prefix)" \
		   CONFIGFLAGS="--with-szlib=$(prefix) --enable-fortran" \
		   CC="$(prefix)/bin/h4cc" CFLAGS="$(CFLAGS)" \
		   FC="$(prefix)/bin/h4fc" F77="$(prefix)/bin/h4fc" FFLAGS="$(FFLAGS)" \
		   LDFLAGS="$(LDFLAGS)" LIBS="$(LIBS)" \
		   ./build_package.sh $<
	
libhdf.a: hdf-4.2.15.tar.gz base
	PREFIX="$(prefix)" CONFIGFLAGS="--with-szlib="$(prefix)" --disable-netcdf" \
		   CC="$(CC)" CFLAGS="$(CFLAGS)" \
		   F77="$(FCC)" FFLAGS="$(FFLAGS)" \
		   CXX="$(CXX)" CXXFLAGS="$(CXXFLAGS)" \
		   LDFLAGS="$(LDFLAGS)" LIBS="$(LIBS)" \
		   ./build_package.sh $<

libfl.a: flex-2.6.4.tar.gz liby.a

liby.a: bison-3.8.tar.gz $(EXTRA_LIBS)
libjpeg.a: jpegsrc.v9d.tar.gz $(EXTRA_LIBS)
libsz.a: szip-2.1.1.tar.gz $(EXTRA_LIBS)
libz.a: zlib-1.2.11.tar.gz $(EXTRA_LIBS)
libtirpc.a: libtirpc-1.3.1.tar.gz
	PREFIX="$(prefix)" CONFIGFLAGS="--disable-gssapi" \
		   CC="$(CC)" CFLAGS="$(CFLAGS)" \
		   F77="$(FCC)" FFLAGS="$(FFLAGS)" \
		   CXX="$(CXX)" CXXFLAGS="$(CXXFLAGS)" \
		   LDFLAGS="$(LDFLAGS)" LIBS="$(LIBS)" \
		   ./build_package.sh $<

test:
	touch test

%.a:
	PREFIX="$(prefix)" \
		   CC="$(CC)" $CFLAGS="$(CFLAGS)" \
		   FCC="$(FCC)" FFLAGS="$(FFLAGS)" \
		   CXX="$(CXX)" CXXFLAGS="$(CXXFLAGS)" \
		   LDFLAGS="$(LDFLAGS)" LIBS="$(LIBS)" \
		   ./build_package.sh $<

# phony rules
.PHONY: makedir
makedir:
	@mkdir -p $(prefix)

.PHONY: all
all: $(TARGET)

.PHONY: clean
clean:
	@rm -rf tmp
	@rm -rf $(prefix)
