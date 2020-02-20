#!/bin/bash -ex
# Perform validations on rulesets.

# Check whether we're on macOS, and therefore need to
# use brew-installed utils
if type brew >/dev/null 2>&1; then
    PYTHON=$(brew --prefix python)/bin/python3
else
    PYTHON=python3.6
fi

utils/remove-obsolete-references.sh
test/validations/path/run.sh
test/validations/test-coverage/run.sh
$PYTHON test/validations/securecookie/run.py
$PYTHON test/validations/filename/run.py
$PYTHON test/validations/relaxng/run.py
$PYTHON test/validations/special/run.py --quiet
