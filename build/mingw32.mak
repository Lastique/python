# Usage:
#
#   Create a new empty directory anywhere (preferably not in the boost tree).
#   Copy this Makefile to that new directory and rename it to "Makefile"
#   Set the BOOST_* pathnames below.
#
#   The idea is that the build directory is on a Unix filesystem that
#   is mounted on a PC using SAMBA. Use this makefile under both Unix
#   and Windows:
#
#   Unix: make softlinks     Create softlinks to source code and tests
#   Win:  make               Compile all sources
#   Win:  make test          Run doctest tests
#   Unix: make clean         Remove all object files
#   Unix: make unlink        Remove softlinks

# To install mingw32, follow instructions at:
#   http://starship.python.net/crew/kernr/mingw32/Notes.html
# In particular, install:
#   ftp://ftp.xraylith.wisc.edu/pub/khan/gnu-win32/mingw32/gcc-2.95.2/gcc-2.95.2-msvcrt.exe
#   ftp://ftp.xraylith.wisc.edu/pub/khan/gnu-win32/mingw32/gcc-2.95.2/fixes/quote-fix-msvcrt.exe
#   http://starship.python.net/crew/kernr/mingw32/Python-1.5.2-mingw32.zip
# Unpack the first two archives in the default locations and update your PATH.
# Unpack the third archive in \usr.

# Note: comprehensive.cpp generates compiler errors and later crashes.
#   L:\boost\boost\python\detail\extension_class.hpp:643: warning:
#   alignment of `vtable for class
#   boost::python::detail::held_instance<bpl_test::Derived1>'
#   is greater than maximum object file alignment. Using 16.
# Could this be fixed with compiler options?
# -fhuge-objects looks interesting, but requires recompiling the C++ library.
#                (what exactly does that mean?)
# -fvtable-thunks eliminates the compiler warning,
# but "import boost_python_test" still causes a crash.

BOOST_UNIX= /net/cci/rwgk/boost
BOOST_WIN= "L:\boost"

PYEXE= "C:\Program files\Python\python.exe"
PYINC= -I"C:\usr\include\python1.5"
PYLIB= "C:\usr\lib\libpython15.a"

STDOPTS= -ftemplate-depth-21
WARNOPTS=

CPP= g++
CPPOPTS= $(STLPORTINC) $(STLPORTOPTS) -I$(BOOST_WIN) $(PYINC) \
         $(STDOPTS) $(WARNOPTS) -g

LD= g++
LDOPTS= -shared

BPL_SRC = $(BOOST_UNIX)/libs/python/src
BPL_TST = $(BOOST_UNIX)/libs/python/test
BPL_EXA = $(BOOST_UNIX)/libs/python/example
SOFTLINKS = \
$(BPL_SRC)/classes.cpp \
$(BPL_SRC)/conversions.cpp \
$(BPL_SRC)/extension_class.cpp \
$(BPL_SRC)/functions.cpp \
$(BPL_SRC)/init_function.cpp \
$(BPL_SRC)/module_builder.cpp \
$(BPL_SRC)/objects.cpp \
$(BPL_SRC)/types.cpp \
$(BPL_TST)/comprehensive.cpp \
$(BPL_TST)/comprehensive.hpp \
$(BPL_TST)/comprehensive.py \
$(BPL_TST)/doctest.py \
$(BPL_EXA)/abstract.cpp \
$(BPL_EXA)/getting_started1.cpp \
$(BPL_EXA)/getting_started2.cpp \
$(BPL_EXA)/getting_started3.cpp \
$(BPL_EXA)/getting_started4.cpp \
$(BPL_EXA)/getting_started5.cpp \
$(BPL_EXA)/passing_char.cpp \
$(BPL_EXA)/test_abstract.py \
$(BPL_EXA)/test_getting_started1.py \
$(BPL_EXA)/test_getting_started2.py \
$(BPL_EXA)/test_getting_started3.py \
$(BPL_EXA)/test_getting_started4.py \
$(BPL_EXA)/test_getting_started5.py

DEFS= \
boost_python_test \
abstract \
getting_started1 \
getting_started2 \
getting_started3 \
getting_started4 \
getting_started5

OBJ = classes.o conversions.o extension_class.o functions.o \
      init_function.o module_builder.o \
      objects.o types.o

.SUFFIXES: .o .cpp

all: libboost_python.a boost_python_test.pyd abstract.pyd \
     getting_started1.pyd getting_started2.pyd getting_started3.pyd \
     getting_started4.pyd getting_started5.pyd

softlinks: defs
	@ for pn in $(SOFTLINKS); \
	  do \
            bn=`basename "$$pn"`; \
	    if [ ! -e "$$bn" ]; then \
              echo "ln -s $$pn ."; \
	      ln -s "$$pn" .; \
            else \
              echo "info: no softlink created (file exists): $$bn"; \
	    fi; \
	  done

unlink: rmdefs
	@ for pn in $(SOFTLINKS); \
	  do \
            bn=`basename "$$pn"`; \
	    if [ -L "$$bn" ]; then \
              echo "rm $$bn"; \
              rm "$$bn"; \
            elif [ -e "$$bn" ]; then \
              echo "info: not a softlink: $$bn"; \
	    fi; \
	  done

defs:
	@ for def in $(DEFS); \
	  do \
            echo "EXPORTS\n\tinit$$def" > $$def.def; \
	  done

rmdefs:
	@ for def in $(DEFS); \
	  do \
            rm $$def.def; \
	  done

libboost_python.a: $(OBJ)
	del libboost_python.a
	ar r libboost_python.a $(OBJ)

DLLWRAPOPTS= -s --driver-name g++ -s
             --entry _DllMainCRTStartup@12 --target=i386-mingw32

boost_python_test.pyd: $(OBJ) comprehensive.o
	dllwrap $(DLLWRAPOPTS) \
          --dllname boost_python_test.pyd \
          --def boost_python_test.def \
          $(OBJ) comprehensive.o $(PYLIB)

abstract.pyd: $(OBJ) abstract.o
	dllwrap $(DLLWRAPOPTS) \
          --dllname abstract.pyd \
          --def abstract.def \
          $(OBJ) abstract.o $(PYLIB)

getting_started1.pyd: $(OBJ) getting_started1.o
	dllwrap $(DLLWRAPOPTS) \
          --dllname getting_started1.pyd \
          --def getting_started1.def \
          $(OBJ) getting_started1.o $(PYLIB)

getting_started2.pyd: $(OBJ) getting_started2.o
	dllwrap $(DLLWRAPOPTS) \
          --dllname getting_started2.pyd \
          --def getting_started2.def \
          $(OBJ) getting_started2.o $(PYLIB)

getting_started3.pyd: $(OBJ) getting_started3.o
	dllwrap $(DLLWRAPOPTS) \
          --dllname getting_started3.pyd \
          --def getting_started3.def \
          $(OBJ) getting_started3.o $(PYLIB)

getting_started4.pyd: $(OBJ) getting_started4.o
	dllwrap $(DLLWRAPOPTS) \
          --dllname getting_started4.pyd \
          --def getting_started4.def \
          $(OBJ) getting_started4.o $(PYLIB)

getting_started5.pyd: $(OBJ) getting_started5.o
	dllwrap $(DLLWRAPOPTS) \
          --dllname getting_started5.pyd \
          --def getting_started5.def \
          $(OBJ) getting_started5.o $(PYLIB)

.cpp.o:
	$(CPP) $(CPPOPTS) -c $*.cpp

test:
	$(PYEXE) comprehensive.py
	$(PYEXE) test_abstract.py
	$(PYEXE) test_getting_started1.py
	$(PYEXE) test_getting_started2.py
	$(PYEXE) test_getting_started3.py
	$(PYEXE) test_getting_started4.py
	$(PYEXE) test_getting_started5.py

clean:
	rm -f $(OBJ) libboost_python.a libboost_python.a.input
	rm -f comprehensive.o boost_python_test.pyd
	rm -f abstract.o abstract.pyd
	rm -f getting_started1.o getting_started1.pyd
	rm -f getting_started2.o getting_started2.pyd
	rm -f getting_started3.o getting_started3.pyd
	rm -f getting_started4.o getting_started4.pyd
	rm -f getting_started5.o getting_started5.pyd
	rm -f so_locations *.pyc
	rm -rf cxx_repository
