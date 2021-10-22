# path macros
PREFIX := $(abspath build)
BIN := $(PREFIX)/bin
OBJ := $(PREFIX)/obj
LIB := $(PREFIX)/lib
INC := $(PREFIX)/include
SRC := src
TMP := tmp

# tool macros
CC := icc
FCC := ifort
CXX := icpc

# complier and linker flags
CFLAGS := -I$(INC)
FFLAGS := -I$(INC)
CXXFLAGS := -I$(INC)
LDFLAGS := -L$(LIB)

BASE_LIBS := libfl.a libjpeg.a libsz.a liby.a libz.a
LIBS := $(BASE_LIBS) libhdf.a libhdfeos.a

vpath %.tar.gz $(SRC)
vpath %.a $(LIB)

# clean files list
CLEAN_LIST := $(TARGET)

# default rule
default: makedir all

.PHONY: all
all: $(LIBS)

.PHONY: base
base: $(BASE_LIBS)

libhdfeos.a: hdf-eos2-3.0-src.tar.gz base libhdf.a
	LD_LIBRARY_PATH="$(PREFIX)/lib:$LD_LIBRARY_PATH" PREFIX=$(PREFIX) \
		   CONFIGFLAGS="--with-szlib=$(PREFIX) --enable-fortran" \
		   CC=${PREFIX}/bin/h4cc CFLAGS=$(CFLAGS) \
		   FC=${PREFIX}/bin/h4fc F77=${PREFIX}/bin/h4fc FFLAGS=$(FFLAGS) \
		   LDFLAGS=$(LDFLAGS) \
		   ./build_package.sh $<
	
libhdf.a: hdf-4.2.15.tar.gz base
	PREFIX=$(PREFIX) CONFIGFLAGS="--with-szlib=$(PREFIX) --disable-netcdf" \
		   CC=$(CC) $CFLAGS=$(CFLAGS) \
		   F77=$(FCC) FFLAGS=$(FFLAGS) \
		   CXX=$(CXX) CXXFLAGS=$(CXXFLAGS) \
		   LDFLAGS=$(LDFLAGS) \
		   ./build_package.sh $<

libfl.a: flex-2.6.4.tar.gz liby.a

liby.a: bison-3.8.tar.gz
libjpeg.a: jpegsrc.v9d.tar.gz
libsz.a: szip-2.1.1.tar.gz
libz.a: zlib-1.2.11.tar.gz

test:
	touch test

%.a:
	PREFIX=$(PREFIX) \
		   CC=$(CC) $CFLAGS=$(CFLAGS) \
		   FCC=$(FCC) FFLAGS=$(FFLAGS) \
		   CXX=$(CXX) CXXFLAGS=$(CXXFLAGS) \
		   LDFLAGS=$(LDFLAGS) \
		   ./build_package.sh $<

# phony rules
.PHONY: makedir
makedir:
	@mkdir -p $(PREFIX)

.PHONY: all
all: $(TARGET)

.PHONY: clean
clean:
	@rm -rf $(TMP)
	@rm -rf $(PREFIX)
