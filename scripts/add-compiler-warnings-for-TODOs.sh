#!/bin/sh

if [ "${CONFIGURATION}" == "Debug" ]; then
    TAGS="TODO:|todo:"
    find "${SRCROOT}" \( -name "*.swift" -or -name "*.h" -or -name "*.m" \) -type f -not -path "${SRCROOT}/SourcePackages/*" -print0 \
    | xargs -0 egrep --with-filename --line-number --only-matching "($TAGS).*\$" \
    | perl -p -e "s/($TAGS)/ warning: \$1/"
fi
