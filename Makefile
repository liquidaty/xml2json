#CXX = 

WIN=
EXE_SUFFIX=
ifeq ($(WIN),)
  WIN=0
  ifneq ($(findstring w64,$(CC)),) # e.g. mingw64
    WIN=1
    EXE_SUFFIX=.exe
  endif
endif

ifeq ($(WIN),1)
LINKOPTIONS = -Wl,--gc-sections -Wl,--strip-all -static
else
UNAME := $(shell uname -s)
ifeq ($(UNAME), Darwin)
LINKOPTIONS = -Wl,-search_paths_first -Wl,-dead_strip -v
else
LINKOPTIONS = -Wl,--gc-sections -Wl,--strip-all
endif
endif

INCLUDE += -I./include/
COMPILEOPTIONS  = -std=c++11 -O3 -fdata-sections -ffunction-sections
WARNINGS = -Wall -Wextra -Werror

MAIN 	= xml2json.o
OBJECTS = xml2json.gch
EXEC 	= xml2json

#############################################################

all : ${EXEC}

install: all
ifeq ($(PREFIX),)
	echo 1>&2 "Missing PREFIX variable"
	exit 1
else
	${SUDO} cp -p xml2json${EXE_SUFFIX} ${PREFIX}/bin/
endif

xml2json.gch : include/xml2json.hpp
	${CXX} ${COMPILEOPTIONS}  -c $< -o $@

${MAIN} : xml2json.cpp
	${CXX} ${COMPILEOPTIONS} $(INCLUDE) -c $< -o $@

${EXEC} : ${MAIN} ${OBJECTS}
	${CXX} ${LINKOPTIONS} ${MAIN} -o ${EXEC}

clean :
	rm -f *.gch *.o ${EXEC}
