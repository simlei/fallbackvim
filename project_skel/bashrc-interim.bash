_declare_dirvar() { local _dir="${BASH_SOURCE[0]}"; _dir="${_dir%/*}"; local varname="${1:-dir}"; local count="${2:-1}"; while [[ "$count" -gt 0 ]]; do _dir="${_dir%/*}"; let count-- || :; done; eval "$varname"'="$_dir"'; }
_declare_dirvar _projdefdir 0
_declare_dirvar _projbasedir 1

# TODO: replace the project name to get sane aliases and variables
_projname=XXX; _projname="${_projname//[^0-9A-Za-z_-]/_}"

_declare_dirvar project__${_projname}__Droot 1
export project__${_projname}__Droot

XXX_ide() {
    "$project__currentproject__Droot/bin/markwin_vimide"
    "$project__currentproject__Droot/bin/mark_last_servername" XXX
    "$project__XXX__Droot/project/ide" --projname=XXX
}
