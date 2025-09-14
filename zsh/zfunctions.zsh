
function cosh () {
    git add -A;
    git commit -m "$@";
    git pull;
    git push;
}

function mkcd () {
    mkdir -p "$1" && cd "$1"
}

function psgrep () {
    if [ -z "$1" ]; then
        echo "Usage: psgrep <pattern>"
        return 1
    fi
    ps aux | grep "$1" | grep -v grep
}