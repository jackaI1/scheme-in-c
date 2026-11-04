# scheme-in-c

A small program that reads and runs Scheme code.

## Overview

I built a small Scheme interpreter in C because I wanted to understand how the languages I write actually run. I could write a recursive function, but I wanted to see how its names get values, how a function remembers a value after returning, and how the program frees memory it no longer needs.

I can type an expression and see its answer, or run a file of Scheme functions. I use it to work through list and recursion exercises, change the interpreter, and check that the same programs still work. This is a personal project, with a deliberately small language so I can follow the whole path from text to result.

## Try it

I use a C compiler, Make, and Python 3 for the tests. On macOS, `xcode-select --install` provides the compiler and Make. On Ubuntu, install `build-essential` and `python3`.

```sh
git clone https://github.com/jackaI1/scheme-in-c.git
cd scheme-in-c
make
./build/scheme
```

I can enter several lines for one expression. Press Ctrl-D to exit.

```scheme
scheme> (define (square x) (* x x))
scheme> (square 12)
144
scheme> (let ((numbers '(1 2 3))) (reverse numbers))
(3 2 1)
```

To run one of my examples:

```sh
./build/scheme examples/grades.scm
# Total: 365
# At least 75: (81 94 75)
./build/scheme examples/counter.scm
# 1
# 2
```

Files print only what I ask them to print with `display` or `write`. Piped input prints expression results, which makes quick checks easy: `printf '(+ 2 3)\n' | ./build/scheme`. I can pass several files to load their definitions into the same session.

## What I can write

I can define functions, pass them to other functions, build lists, and use `if`, `let`, `cond`, and quoted data. A closure is a function that keeps the variables from where I created it. The counter example uses one to keep a private count.

The interpreter reuses its current work slot for a tail call, a function call whose result is returned directly. That lets an accumulating loop run hundreds of thousands of calls without growing the C call stack. A garbage collector finds values that are still reachable and frees the rest, including old function-call environments.

This is a Scheme subset, not a replacement for a complete Scheme implementation. Numbers are signed 64-bit integers; division truncates toward zero. I have not added macros, continuations exposed to Scheme, floating-point numbers, or the standard library. [The language reference](docs/language.md) explains the supported forms and limits.

## Check my changes

```sh
make test
make sanitize
./build/scheme --gc-stats tests/programs/tail.scm
```

My tests run Scheme programs for recursion, functions passed as values, list processing, and captured variables. They also check invalid input, arithmetic overflow, and memory reclamation. Sanitizers check memory access and undefined C behavior. GitHub Actions runs both commands on Linux and macOS; Linux also checks for memory leaks.

I explain the evaluation loop, memory roots, and test measurements in [the design notes](docs/design.md).
