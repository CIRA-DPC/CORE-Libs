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
CC ?= icc
FC ?= ifort
CXX ?= icpc

UNAME_S := $(shell uname -s)
CLI_TOOLS=/Library/Developer/CommandLinetools/SDKs/MacOSX.sdk
BUILD_LIBTIRPC := true
CFLAGS :=
FFLAGS := -std=legacy
CXXFLAGS :=
ifeq ($(UNAME_S), Darwin)
    BUILD_LIBTIRPC := false
    ifeq ($(wildcard $(CLI_TOOLS)),)
        $(error Command Line Tools not found: Install using `xcode-select --install`)
	endif
	ifeq ($(CC), icc)
        CFLAGS := -isysroot $(CLI_TOOLS)
	else
		CFLAGS := --sysroot $(CLI_TOOLS)
	endif
	ifeq ($(FC), ifort)
        FFLAGS := -isysroot $(CLI_TOOLS)
	else
		FFLAGS := --sysroot $(CLI_TOOLS)
	endif
	ifeq ($(CXX), icpc)
        CXXFLAGS := -isysroot $(CLI_TOOLS)
	else
		CXXFLAGS := --sysroot $(CLI_TOOLS)
	endif
endif


# complier and linker flags
override CFLAGS := -I$(includedir) $(CFLAGS) -I/usr/local/include -I/usr/include
override FFLAGS := -I$(includedir) $(FFLAGS) -I/usr/local/include -I/usr/include
override CXXFLAGS := -I$(includedir) $(CXXFLAGS) -I/usr/local/include -I/usr/include
override LDFLAGS := -L$(libdir) $(LDFLAGS) -L/usr/local/lib -L/usr/lib
override LD_LIBRARY_PATH := $(libdir):$(LD_LIBRARY_PATH):/usr/local/lib:/usr/lib
override PATH := $(bindir):$(PATH)

BASE_LIBS := libfl.a libjpeg.a libsz.a liby.a libz.a
ALL_LIBS := $(BASE_LIBS) libmfhdf.a libhdfeos.a
LINK_LIBS := $(patsubst lib%.a,-l%,$(BASE_LIBS))

PACK_NAME := core_libs
PACK_VER := $(shell git describe --tags)
PACK_FNAME := $(packdir)/$(shell ./create_package_fname.sh ${PACK_NAME} ${PACK_VER})

ifeq ($(BUILD_LIBTIRPC),true)
    EXTRA_LIBS := libtirpc.a
    LIBS := ${LIBS} -ltirpc
    CFLAGS += -I$(includedir)/tirpc
    CXXFLAGS += -I$(includedir)/tirpc
    FFLAGS += -I$(includedir)/tirpc
    LINK_LIBS += -ltirpc
endif

VPATH := $(srcdir) $(libdir)

# clean files list
CLEAN_LIST := $(TARGET)

.PHONY: debug
debug:
	@echo "CC $(CC)"
	@echo "FC $(FC)"
	@echo "CXX $(CXX)"
	@echo "basedir $(basedir)"
	@echo "srcdir $(srcdir)"
	@echo "prefix $(prefix)"
	@echo "exec_prefix $(exec_prefix)"
	@echo "bindir $(bindir)"
	@echo "libdir $(libdir)"
	@echo "includedir $(includedir)"
	@echo "packdir $(packdir)"
	@echo "CFLAGS $(CFLAGS)"
	@echo "CXXFLAGS $(CXXFLAGS)"
	@echo "FFLAGS $(FFLAGS)"
	@echo "LDFLAGS $(LDFLAGS)"
	@echo "LD_LIBRARY_PATH $(LD_LIBRARY_PATH)"
	@echo "LINK_LIBS $(LINK_LIBS)"
	@echo "BASE_LIBS $(BASE_LIBS)"
	@echo "EXTRA_LIBS $(EXTRA_LIBS)"
	@echo "ALL_LIBS $(ALL_LIBS)"

.PHONY: package
package: all
	mkdir -p $(packdir)
	cd $(prefix); tar -czf $(PACK_FNAME) lib/*.a include

.PHONY: all
all: $(ALL_LIBS)

.PHONY: base
base: $(BASE_LIBS)

libhdfeos.a: hdf-eos2-3.0-src.tar.gz libmfhdf.a | base
	PATH="$(PATH)" LD_LIBRARY_PATH="$(prefix)/lib:$LD_LIBRARY_PATH" PREFIX="$(prefix)" \
		   CONFIGFLAGS="--with-szlib=$(prefix) --enable-fortran" \
		   CC="$(prefix)/bin/h4cc" CFLAGS="$(CFLAGS)" \
		   FC="$(prefix)/bin/h4fc" F77="$(prefix)/bin/h4fc" FFLAGS="$(FFLAGS)" \
		   LDFLAGS="$(LDFLAGS)" LIBS="$(LINK_LIBS) $(libdir)/libmfhdf.a" ONEAPI_PATH="$(ONEAPI_PATH)" \
		   ./build_package.sh $<
	
libmfhdf.a: hdf-4.2.15.tar.gz | base
	PATH="$(PATH)" PREFIX="$(prefix)" \
	       CONFIGFLAGS="--with-szlib="$(prefix)" --with-jpeg="$(prefix)" --with-zlib="$(prefix)" --disable-netcdf" \
		   LD_LIBRARY_PATH="$(LD_LIBRARY_PATH)" \
		   CC="$(CC)" CFLAGS="$(CFLAGS)" \
		   F77="$(FC)" FFLAGS="$(FFLAGS)" \
		   CXX="$(CXX)" CXXFLAGS="$(CXXFLAGS)" \
		   LDFLAGS="$(LDFLAGS)" LIBS="$(LINK_LIBS)" ONEAPI_PATH="$(ONEAPI_PATH)" \
		   ./build_package.sh $<

libfl.a: flex-2.6.4.tar.gz liby.a

liby.a: bison-3.8.tar.gz $(EXTRA_LIBS)
libjpeg.a: jpegsrc.v9d.tar.gz $(EXTRA_LIBS)
libsz.a: szip-2.1.1.tar.gz $(EXTRA_LIBS)
libz.a: zlib-1.2.11.tar.gz $(EXTRA_LIBS)
libtirpc.a: libtirpc-1.3.1.tar.gz
	@echo "Building libtirpc"
	PREFIX="$(prefix)" CONFIGFLAGS="--disable-gssapi" \
		   LD_LIBRARY_PATH="$(LD_LIBRARY_PATH)" \
		   CC="$(CC)" CFLAGS="$(CFLAGS)" \
		   F77="$(FC)" FFLAGS="$(FFLAGS)" \
		   CXX="$(CXX)" CXXFLAGS="$(CXXFLAGS)" \
		   LDFLAGS="$(LDFLAGS)" ONEAPI_PATH="$(ONEAPI_PATH)" \
		   ./build_package.sh $<

%.a:
	@echo "Building $<"
	PREFIX="$(prefix)" \
		   LD_LIBRARY_PATH="$(LD_LIBRARY_PATH)" \
		   CC="$(CC)" $CFLAGS="$(CFLAGS)" \
		   FC="$(FC)" FFLAGS="$(FFLAGS)" \
		   CXX="$(CXX)" CXXFLAGS="$(CXXFLAGS)" \
		   LDFLAGS="$(LDFLAGS)" LIBS="$(LIBS)" ONEAPI_PATH="$(ONEAPI_PATH)" \
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
