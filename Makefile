CC = cc
CPPFLAGS = -Isrc
CFLAGS = -std=c11 -O2 -g -Wall -Wextra -Wpedantic -Werror
SOURCES = src/main.c src/runtime.c src/reader.c src/eval.c src/primitives.c
HEADERS = src/scheme.h
# Apple clang does not ship LeakSanitizer; Linux CI enables it.
LEAKS = $(if $(filter Darwin,$(shell uname -s)),0,1)

.PHONY: all test sanitize clean
all: build/scheme
build:
	mkdir -p build
build/scheme: $(SOURCES) $(HEADERS) | build
	$(CC) $(CPPFLAGS) $(CFLAGS) $(SOURCES) -o $@
build/scheme-sanitize: $(SOURCES) $(HEADERS) | build
	$(CC) $(CPPFLAGS) $(CFLAGS) -O1 -fno-omit-frame-pointer -fsanitize=address,undefined -fno-sanitize-recover=all $(SOURCES) -o $@
test: build/scheme
	python3 tests/run.py build/scheme
sanitize: build/scheme-sanitize
	ASAN_OPTIONS=detect_leaks=$(LEAKS) UBSAN_OPTIONS=halt_on_error=1 python3 tests/run.py build/scheme-sanitize
clean:
	rm -rf build
