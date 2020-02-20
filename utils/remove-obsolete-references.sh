#!/bin/bash
# Remove obsolete references to child rulesets which
# has been renamed/ deleted

# Check whether we're on macOS, and therefore need to
# use brew-installed utils
if type brew >/dev/null 2>&1; then
    SED=$(brew --prefix gnu-sed)/bin/gsed
else
    SED=sed
fi

# Change directory to git root; taken from ../test/test.sh
if [ -n "$GIT_DIR" ]
then
    # $GIT_DIR is set, so we're running as a hook.
    cd $GIT_DIR
else
    # Git command exists? Cool, let's CD to the right place.
    git rev-parse && cd "$(git rev-parse --show-toplevel)"
fi

# Run from ruleset folder to simplify the output
cd src/chrome/content/rules

# Default exit status
EXIT_CODE=0

# List of file(s) which contain at least one reference
FILES=`find . -name '*.xml' -print0 | xargs -0 egrep -l '^\s*[-|+]\s*([^ ]*\.xml)\s*$' | xargs -n 1 basename --`

while read FILE; do
    # List of referenced rulesets
    REFS=`$SED -n 's/^\s*[-|+]\s*\([^ ]*\.xml\)\s*$/\1/gp' "$FILE" | xargs -n 1 basename --`

    while read REF; do
        if [ ! -f "$REF" ]; then
            echo >&2 "ERROR src/chrome/content/rules/$FILE: Dangling reference to $REF"
            $SED -i "/^\s*[-|+]\s*$REF$/d" "$FILE"
            EXIT_CODE=1
        fi
    done <<< "$REFS"
done <<< "$FILES"

# Exit with errors, if any
exit "$EXIT_CODE"
