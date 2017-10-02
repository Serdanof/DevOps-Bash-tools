#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2016-09-23 09:16:45 +0200 (Fri, 23 Sep 2016)
#
#  https://github.com/harisekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir2="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$srcdir2/utils.sh"

srcdir="$srcdir2"

if [ -z "${PROJECT:-}" ]; then
    export PROJECT=bash-tools
fi

section "PyTools Checks"

export PATH="$PATH:$srcdir/pytools_checks:$srcdir/../pytools"

start_time="$(start_timer)"

echo -n "running on branch:  "
git branch | grep ^*
echo

get_pytools(){
    if ! [ -d "$srcdir/pytools_checks" ]; then
        pushd "$srcdir"
        git clone https://github.com/harisekhon/pytools pytools_checks
        pushd pytools_checks
        make
        popd
        popd
    fi
}

# Ensure we have these at the minimum, these validate_*.py will cover
# most configuration files as we dynamically find and call any validation programs further down
if which dockerfiles_check_git_branches.py &>/dev/null &&
   which git_check_branches_upstream.py &>/dev/null &&
   which validate_ini.py &>/dev/null
   which validate_json.py &>/dev/null
   which validate_yaml.py &>/dev/null
   which validate_xml.py &>/dev/null
    then
    if [ -d "$srcdir/pytools_checks" ]; then
        pushd "$srcdir/pytools_checks"
        make update
        popd
    fi
else
    get_pytools
fi

skip_checks=0
if [ "$PROJECT" = "pytools" ]; then
    echo "detected running in pytools repo, skipping checks here as will be called in bash-tools/all.sh..."
    skip_checks=1
elif [ "$PROJECT" = "Dockerfiles" ]; then
    echo "detected running in Dockerfiles repo, skipping checks here as will be called in bash-tools/all.sh..."
    skip_checks=1
fi

if [ $skip_checks = 0 ]; then
echo
echo "Running validation programs:"
echo
for x in "$(dirname "$(which validate_ini.py)")"/validate_*.py; do
    [[ "$x" =~ validate_multimedia.py ]] && continue
    [ -L "$x" ] && continue
    echo "$x: "
    $x .
    echo
done

time_taken "$start_time"
section2 "PyTools validations SUCCEEDED"
echo
fi
