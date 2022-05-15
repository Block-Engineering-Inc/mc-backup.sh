#!/bin/bash

exit=$( [[ $0 == -bash ]] && echo return || echo exit )

log () {
    # Echos text passed to function and appends to file at same time
    builtin echo -e "$@" | tee -a "$logFile"
}
