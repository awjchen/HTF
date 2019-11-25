#!/bin/bash

cd "$(dirname $0)"

lineno=7
function check()
{
    test="$1"
    command -v grep >/dev/null 2>&1 || \
        { echo >&2 "Test $0 requires ``grep'' but it's not installed.  Aborting."; exit 1; }
    stack $HTF_TRAVIS_STACK_ARGS build
    ecode="$?"
    if [ $ecode -ne 0 ]; then
        echo "stack build failed, exiting!"
        exit 1
    fi
    compile_cmd="stack $HTF_TRAVIS_STACK_ARGS ghc --package HTF -- -XPackageImports $test"
    $compile_cmd 2>&1 | grep "$test":$lineno > /dev/null
    grep_ecode=${PIPESTATUS[1]}
    if [ "$grep_ecode" != "0" ]
    then
        echo "Compile error for $test did not occur in line $lineno, exit code of grep: ${grep_ecode}"
        echo "Compile command: $compile_cmd"
        echo "Stack version: $(stack --version)"
        echo "GHC version: $(stack $HTF_TRAVIS_STACK_ARGS ghc -- --version)"
        echo "Here is the output of the compiler:"
        $compile_cmd
        exit 1
    fi
}

check Test1.hs
check Test2.hs
check Test3.hs
check Test4.hs
