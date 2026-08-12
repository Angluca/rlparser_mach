EXTENSION?=mach
FORMAT?=CODE

.PHONY: all mach parse clean

# Determine PLATFORM_OS
# No uname.exe on MinGW!, but OS=Windows_NT on Windows!
# ifeq ($(UNAME),Msys) -> Windows
ifeq ($(OS),Windows_NT)
    PLATFORM_OS = WINDOWS
else
    UNAMEOS = $(shell uname)
    ifeq ($(UNAMEOS),Linux)
        PLATFORM_OS = LINUX
    endif
    ifeq ($(UNAMEOS),FreeBSD)
        PLATFORM_OS = BSD
    endif
    ifeq ($(UNAMEOS),OpenBSD)
        PLATFORM_OS = BSD
    endif
    ifeq ($(UNAMEOS),NetBSD)
        PLATFORM_OS = BSD
    endif
    ifeq ($(UNAMEOS),DragonFly)
        PLATFORM_OS = BSD
    endif
    ifeq ($(UNAMEOS),Darwin)
        PLATFORM_OS = OSX
    endif
endif

# Define default C compiler: CC
#------------------------------------------------------------------------------------------------
CC = gcc
ifeq ($(PLATFORM_OS),OSX)
    # OSX default compiler
    CC = clang
endif
ifeq ($(PLATFORM_OS),BSD)
    # FreeBSD, OpenBSD, NetBSD, DragonFly default compiler
    CC = clang
endif

# Define default make program: MAKE
#------------------------------------------------------------------------------------------------
MAKE ?= make
ifeq ($(PLATFORM_OS),WINDOWS)
    MAKE = mingw32-make
endif

# Define compiler flags: CFLAGS
#------------------------------------------------------------------------------------------------
CFLAGS = -Wall -std=c99
#CFLAGS += -Wextra -Wmissing-prototypes -Wstrict-prototypes

ifeq ($(BUILD_MODE),DEBUG)
    CFLAGS += -g -D_DEBUG
else
    ifeq ($(PLATFORM_OS),OSX)
        CFLAGS += -O2
    else
        CFLAGS += -s -O2
    endif
endif
ifeq ($(PLATFORM_OS),WINDOWS)
    # NOTE: The resource .rc file contains windows executable icon and properties
    CFLAGS += rlparser.rc.data
endif

# Define processes to execute
#------------------------------------------------------------------------------------------------

mach: clean rlparser
	./rlparser -i ./h/raylib.h -o ./output/raylib.$(EXTENSION) -f $(FORMAT) -d RLAPI
	./rlparser -i ./h/raymath.h -o ./output/raymath.$(EXTENSION) -f $(FORMAT) -d RMAPI
	./rlparser -i ./h/rlgl.h -o ./output/rlgl.$(EXTENSION) -f $(FORMAT) -d RLAPI -t "RLGL IMPLEMENTATION"
	./rlparser -i ./h/rcamera.h -o ./output/rcamera.$(EXTENSION) -f $(FORMAT) -d RLAPI -t "RLGL IMPLEMENTATION"
	./rlparser -i ./h/raygui.h -o ./output/raygui.$(EXTENSION) -f $(FORMAT) -d RAYGUIAPI -t "RAYGUI IMPLEMENTATION"
	@rm -rf *.dSYM

# rlparser compilation
rlparser: rlparser.c
	$(CC) -g -fsanitize=address rlparser.c -o rlparser $(CFLAGS)

# "make parse" (and therefore "make all") requires
# raygui.h and reasings_api.h to exist in the correct directory
# API files for individual headers can be created likeso, provided the relevant header exists:
# FORMAT=JSON EXTENSION=json make raygui_api.json
all: mach
	FORMAT=CODE EXTENSION=mach $(MAKE) mach
	#FORMAT=DEFAULT EXTENSION=txt $(MAKE) parse
	#FORMAT=JSON EXTENSION=json $(MAKE) parse
	#FORMAT=XML EXTENSION=xml $(MAKE) parse
	#FORMAT=LUA EXTENSION=lua $(MAKE) parse
	#FORMAT=SEXPR EXTENSION=sexpr $(MAKE) parse

# Clean rlparser and generated output files 
#rm -f rlparser *.json *.txt *.xml *.lua *.sexpr 
clean:
	rm -f ./output/*.mach
	rm -f rlparser
	rm -rf *.dSYM

