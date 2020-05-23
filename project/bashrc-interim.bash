_declare_dirvar() { local _dir="${BASH_SOURCE[0]}"; _dir="${_dir%/*}"; local varname="${1:-dir}"; local count="${2:-1}"; while [[ "$count" -gt 0 ]]; do _dir="${_dir%/*}"; let count-- || :; done; eval "$varname"'="$_dir"'; }
_declare_dirvar _projdefdir 0
_declare_dirvar _projbasedir 1

# TODO: replace the project name to get sane aliases and variables
_projname=${_projbasedir##*/}; _projname="${_projname//[^A-Za-z]/}"

_declare_dirvar project_${_projname}_Droot 1
echo eval 'alias '$_projname'_ide="${project_'$_projname'_Droot}/project/ide --name='$_projname'"'
eval 'alias '$_projname'_ide="${project_'$_projname'_Droot}/project/ide --name='$_projname'"'

vim_projectdrop() {
    local vimloc="$HOME/.vim" # TODO: not safe to assume in the future
    mkdir ./project && cp -r "$vimloc/project_skel"/* ./project/
}

histvim() {
    vim -c "set filetype=sh" -c "normal gcaeG" "$@"
}
alias vhist='histvimtmp="$(mktemp -u)"; history | tail -n ${vhist__n:-30} | cut -d " " -f '4-' > "$histvimtmp"; histvim "$histvimtmp" && source "$histvimtmp"'
vGrep() {
    local flags=()
    while [[ -n $2 ]]; do
        flags+=("$1")
        shift;
    done
    local query="$1"
    if [[ ! -n "$query" ]]; then
        return 1;
    fi
    flags="${flags[@]@Q}"
    vim -c "Grepper -dir cwd -query ${flags[*]} ${query@Q}"
}
vGit() {
    (cd "${1:-$PWD}"; vim "$PWD" -c 'G')
}
