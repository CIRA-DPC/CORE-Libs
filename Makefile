.DEFAULT_GOAL = all

# path macros
basedir := $(abspath .)
srcdir := src
prefix := $(abspath build)
exec_prefix := $(prefix)
bindir := $(exec_prefix)/bin
libdir := $(exec_prefix)/lib
includedir := $(exec_prefix)/include
packdir := $(basedir)/packages

# tool macros
CC := icc
FCC := ifort
CXX := icpc

# complier and linker flags
CFLAGS := -I$(includedir) $(CFLAGS) -I/usr/local/include -I/usr/include
FFLAGS := -I$(includedir) $(FFLAGS) -I/usr/local/include -I/usr/include
CXXFLAGS := -I$(includedir) $(CXXFLAGS) -I/usr/local/include -I/usr/include
LDFLAGS := -L$(libdir) $(LDFLAGS) -L/usr/local/lib -L/usr/lib
LD_LIBRARY_PATH := $(libdir):$(LD_LIBRARY_PATH):/usr/local/lib:/usr/lib
# CFLAGS := -I$(includedir) $(CFLAGS)
# FFLAGS := -I$(includedir) $(FFLAGS)
# CXXFLAGS := -I$(includedir) $(CXXFLAGS)
# LDFLAGS := -L$(libdir) $(LDFLAGS)

BASE_LIBS := libfl.a libjpeg.a libsz.a liby.a libz.a
ALL_LIBS := $(BASE_LIBS) libmfhdf.a libhdfeos.a

PACK_NAME := core_libs
PACK_VER := $(shell git describe --tags)
PACK_FNAME := $(packdir)/$(shell ./create_package_fname.sh ${PACK_NAME} ${PACK_VER})

ifeq ($(BUILD_LIBTIRPC),true)
    EXTRA_LIBS := libtirpc.a
    LIBS := ${LIBS} -ltirpc
    CFLAGS += -I$(includedir)/tirpc
    CXXFLAGS += -I$(includedir)/tirpc
    FFLAGS += -I$(includedir)/tirpc
endif
# LIBS := ${LIBS} -ltirpc

VPATH := $(srcdir) $(libdir)

# clean files list
CLEAN_LIST := $(TARGET)

.PHONY: debug
debug:
	echo "basedir $(basedir)"
	echo "srcdir $(srcdir)"
	echo "prefix $(prefix)"
	echo "exec_prefix $(exec_prefix)"
	echo "bindir $(bindir)"
	echo "libdir $(libdir)"
	echo "includedir $(includedir)"
	echo "packdir $(packdir)"
	echo "CFLAGS $(CFLAGS)"
	echo "CXXFLAGS $(CXXFLAGS)"
	echo "FFLAGS $(FFLAGS)"
	echo "LDFLAGS $(LDFLAGS)"
	echo "LD_LIBRARY_PATH $(LD_LIBRARY_PATH)"

.PHONY: package
package: all
	mkdir -p $(packdir)
	cd $(prefix); tar -czf $(PACK_FNAME) lib/*.a include

.PHONY: all
all: $(ALL_LIBS)

.PHONY: base
base: $(BASE_LIBS)

libhdfeos.a: hdf-eos2-3.0-src.tar.gz libmfhdf.a | base
	LD_LIBRARY_PATH="$(prefix)/lib:$LD_LIBRARY_PATH" PREFIX="$(prefix)" \
		   CONFIGFLAGS="--with-szlib=$(prefix) --enable-fortran" \
		   CC="$(prefix)/bin/h4cc" CFLAGS="$(CFLAGS)" \
		   FC="$(prefix)/bin/h4fc" F77="$(prefix)/bin/h4fc" FFLAGS="$(FFLAGS)" \
		   LDFLAGS="$(LDFLAGS)" LIBS="$(LIBS)" \
		   ./build_package.sh $<
	
libmfhdf.a: hdf-4.2.15.tar.gz | base
	PREFIX="$(prefix)" CONFIGFLAGS="--with-szlib="$(prefix)" --disable-netcdf" \
		   LD_LIBRARY_PATH="$(LD_LIBRARY_PATH)" \
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
		   LD_LIBRARY_PATH="$(LD_LIBRARY_PATH)" \
		   CC="$(CC)" CFLAGS="$(CFLAGS)" \
		   F77="$(FCC)" FFLAGS="$(FFLAGS)" \
		   CXX="$(CXX)" CXXFLAGS="$(CXXFLAGS)" \
		   LDFLAGS="$(LDFLAGS)" \
		   ./build_package.sh $<

%.a:
	PREFIX="$(prefix)" \
		   LD_LIBRARY_PATH="$(LD_LIBRARY_PATH)" \
		   CC="$(CC)" $CFLAGS="$(CFLAGS)" \
		   FCC="$(FCC)" FFLAGS="$(FFLAGS)" \
		   CXX="$(CXX)" CXXFLAGS="$(CXXFLAGS)" \
		   LDFLAGS="$(LDFLAGS)" LIBS="$(LIBS)" \
		   ./build_package.sh $<

# phony rules
.PHONY: makedir
makedir:
	@mkdir -p $(prefix)

.PHONY: clean
clean:
	- @rm -rf tmp
	- @rm $(bindir)/*
	- @rmdir $(bindir)
	- @rm $(libdir)/*
	- @rmdir $(libdir)
	- @rm $(includedir)/*
	- @rmdir $(includedir)
	- @rmdir $(prefix)
