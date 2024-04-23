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

COMPILER_SET ?= gnu
ifeq ($(COMPILER_SET),gnu)
    CC = gcc
    CXX = g++
    FC = gfortran
else ifeq ($(COMPILER_SET),intel)
    CC = icc
    CXX = icpc
    FC = ifort
else
	$(error COMPILER_SET must be one of [gnu, intel]. Received: $(COMPILER_SET))
endif

UNAME_S := $(shell uname -s)
CLI_TOOLS=/Library/Developer/CommandLinetools/SDKs/MacOSX.sdk
BUILD_LIBTIRPC := true
ifeq ($(UNAME_S), Darwin)
    BUILD_LIBTIRPC := false
    ifeq ($(wildcard $(CLI_TOOLS)),)
        $(error Command Line Tools not found: Install using `xcode-select --install`)
	endif
	ifeq ($(COMPLER_SET), gnu)
		COMMON_FLAGS += --sysroot $(CLI_TOOLS)
	else ifeq ($(COMPILER_SET), intel)
        COMMON_FLAGS += -isysroot $(CLI_TOOLS)
	endif
	CFLAGS += $(COMMON_FLAGS)
	CXXFLAGS += $(COMMON_FLAGS)
	FFLAGS += $(COMMON_FLAGS)
endif


# complier and linker flags
override CPPFLAGS := -I$(includedir) $(CPPFLAGS) -I/usr/local/include -I/usr/include
override LDFLAGS := -L$(libdir) $(LDFLAGS) -L/usr/local/lib -L/usr/lib
override LD_LIBRARY_PATH := $(libdir):$(LD_LIBRARY_PATH):/usr/local/lib:/usr/lib
override PATH := $(bindir):$(PATH)

BASE_LIBS := libfl.a libjpeg.a libsz.a liby.a libz.a
ALL_LIBS := $(BASE_LIBS) libmfhdf.a libhdfeos.a
LINK_LIBS := $(patsubst lib%.a,-l%,$(BASE_LIBS))

PACK_NAME := core_libs
PACK_VER := $(shell git describe --tags)
PACK_FNAME := $(packdir)/$(shell ./create_package_fname.sh ${PACK_NAME} ${PACK_VER} ${COMPILER_SET})

ifeq ($(BUILD_LIBTIRPC),true)
    EXTRA_LIBS := libtirpc.a
    LIBS := ${LIBS} -ltirpc
    CPPFLAGS += -I$(includedir)/tirpc
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
	@echo "CPPFLAGS $(CPPFLAGS)"
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
	PATH="$(PATH)" \
	PREFIX="$(prefix)" \
	COMPLIER_SET="$(COMPLER_SET)" \
	CC="$(prefix)/bin/h4cc" \
	FC="$(prefix)/bin/h4fc" \
	F77="$(prefix)/bin/h4fc" \
	CONFIGFLAGS="--with-szlib=$(prefix) --enable-fortran" \
	CPPFLAGS="$(CPPFLAGS)" \
	CFLAGS="$(CFLAGS)" \
	FFLAGS="$(FFLAGS)" \
	LD_LIBRARY_PATH="$(prefix)/lib:$LD_LIBRARY_PATH" \
	LDFLAGS="$(LDFLAGS)" \
	LIBS="$(LINK_LIBS) $(libdir)/libmfhdf.a" \
	ONEAPI_PATH="$(ONEAPI_PATH)" \
	./build_package.sh $<
	
libmfhdf.a: hdf-4.2.15.tar.gz | base
	PATH="$(PATH)" \
	PREFIX="$(prefix)" \
    COMPLIER_SET="$(COMPLER_SET)" \
	CC="$(CC)" \
	CXX="$(CXX)" \
	F77="$(FC)" \
	CONFIGFLAGS="--with-szlib="$(prefix)" --with-jpeg="$(prefix)" --with-zlib="$(prefix)" --disable-netcdf" \
	CPPFLAGS="$(CPPFLAGS)" \
	CFLAGS="$(CFLAGS)" \
	FFLAGS="$(FFLAGS)" \
	CXXFLAGS="$(CXXFLAGS)" \
	LD_LIBRARY_PATH="$(LD_LIBRARY_PATH)" \
	LDFLAGS="$(LDFLAGS)" \
	LIBS="$(LINK_LIBS)" \
	ONEAPI_PATH="$(ONEAPI_PATH)" \
	./build_package.sh $<

libfl.a: flex-2.6.4.tar.gz liby.a

liby.a: bison-3.8.tar.gz $(EXTRA_LIBS)
libjpeg.a: jpegsrc.v9d.tar.gz $(EXTRA_LIBS)
libsz.a: szip-2.1.1.tar.gz $(EXTRA_LIBS)
libz.a: zlib-1.2.11.tar.gz $(EXTRA_LIBS)
libtirpc.a: libtirpc-1.3.1.tar.gz
	@echo "Building libtirpc"
    COMPLIER_SET="$(COMPLER_SET)" \
	PREFIX="$(prefix)" \
	COMPILER_SET="$(COMPLER_SET)" \
	CC="$(CC)" \
	F77="$(FC)" \
	CXX="$(CXX)" \
	CONFIGFLAGS="--disable-gssapi" \
	CPPFLAGS="$(CPPFLAGS)"
	CFLAGS="$(CFLAGS)" \
	FFLAGS="$(FFLAGS)" \
	CXXFLAGS="$(CXXFLAGS)" \
	LD_LIBRARY_PATH="$(LD_LIBRARY_PATH)" \
	LDFLAGS="$(LDFLAGS)" \
	ONEAPI_PATH="$(ONEAPI_PATH)" \
	./build_package.sh $<

%.a:
	@echo "Building $<"
	COMPLIER_SET="$(COMPLER_SET)"
	PREFIX="$(prefix)" \
	COMPILER_SET="$(COMPLER_SET)" \
	CC="$(CC)" \
	FC="$(FC)" \
	CXX="$(CXX)" \
	CPPFLAGS="$(CPPFLAGS)" \
	CFLAGS="$(CFLAGS)" \
	FFLAGS="$(FFLAGS)" \
	CXXFLAGS="$(CXXFLAGS)" \
	LD_LIBRARY_PATH="$(LD_LIBRARY_PATH)" \
	LDFLAGS="$(LDFLAGS)" \
	LIBS="$(LIBS)" \
	ONEAPI_PATH="$(ONEAPI_PATH)" \
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
