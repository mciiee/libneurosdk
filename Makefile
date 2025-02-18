VERSION=v0.1.1

CC=cc

OPTIMIZATION_OPTIONS=-O0 -g -DDEBUG
OPTIMIZATION_OPTIONS_RELEASE=-O3

ifeq ($(shell uname), Darwin)
	SHARED_LIB="libneurosdk.dylib"
	SHARED_FLAGS="-dynamiclib"
else
	SHARED_LIB="libneurosdk.so"
	SHARED_FLAGS="-shared"
endif

MONGOOSE_SOURCE_URL=https://raw.githubusercontent.com/cesanta/mongoose/refs/heads/master/mongoose.c
MONGOOSE_HEADER_SOURCE_URL=https://raw.githubusercontent.com/cesanta/mongoose/refs/heads/master/mongoose.h

TINYCTHREAD_SOURCE_URL=https://raw.githubusercontent.com/tinycthread/tinycthread/refs/heads/master/source/tinycthread.c
TINYCTHREAD_HEADER_SOURCE_URL=https://raw.githubusercontent.com/tinycthread/tinycthread/refs/heads/master/source/tinycthread.h

JSONLIB_HEADER_SOURCE=https://raw.githubusercontent.com/sheredom/json.h/refs/heads/master/json.h

.PHONY: build

build-deps: src/mongoose.h src/mongoose.c src/tinycthread.h src/tinycthread.c src/json.h src/neurosdk.c

examples: libneurosdk.a
	echo Building examples.
	cc \
		-o examples/simple \
		-Wall -Wextra \
		$optimization_options \
		-Iinclude \
		examples/simple.c \
		libneurosdk.a
	cc \
		-o examples/tictactoe \
		-Wall -Wextra \
		$optimization_options \
		-Iinclude \
		examples/tictactoe.c \
		libneurosdk.a

libneurosdk.o: build-deps
	cc -c \
		-o libneurosdk.o \
		-Wall -Wextra -fPIC \
		$(OPTIMIZATION_OPTIONS_RELEASE) \
		"-DLIB_BUILD_HASH=$(shell git rev-parse HEAD)" \
		"-DLIB_VERSION=$(VERSION)" \
		-I include \
		src/neurosdk.c

libneurosdk.a: libneurosdk.o
	echo "Building static library"
	ar rcs libneurosdk.a libneurosdk.o

$(SHARED_LIB): libneurosdk.o
	echo "Building shared library"
	cc $(SHARED_FLAGS) -o $(SHARED_LIB) libneurosdk.o

src/mongoose.h:
	echo "Fetching mongoose header."
	curl -LO $(MONGOOSE_HEADER_SOURCE_URL) -o mongoose.h
	mv -v mongoose.h src/

src/mongoose.c:
	echo "Fetching mongoose source."
	curl -LO $(MONGOOSE_SOURCE_URL) -o mongoose.c
	mv -v mongoose.c src/

src/tinycthread.c:
	echo "Fetching tinycthread source."
	curl -LO $(TINYCTHREAD_SOURCE_URL) -o tinycthread.c
	mv -v tinycthread.c src/

src/tinycthread.h:
	echo "Fetching tinycthread header."
	curl -LO $(TINYCTHREAD_HEADER_SOURCE_URL) -o tinycthread.h
	mv -v tinycthread.h src/

src/json.h:
	echo "Fetching JSON library."
	curl -LO $(JSONLIB_HEADER_SOURCE) -o json.h
	mv -v json.h src/


