_declare_dirvar() { local _dir="${BASH_SOURCE[0]}"; _dir="${_dir%/*}"; local varname="${1:-dir}"; local count="${2:-1}"; while [[ "$count" -gt 0 ]]; do _dir="${_dir%/*}"; let count-- || :; done; eval "$varname"'="$_dir"'; }
_declare_dirvar _projdefdir 0
_declare_dirvar _projbasedir 1

# TODO: replace the project name to get sane aliases and variables
_projname=${_projbasedir##*/}; _projname="${_projname//[^A-Za-z]/}"

_declare_dirvar project_${_projname}_Droot 1
echo eval 'alias '$_projname'_ide="${project_'$_projname'_Droot}/project/ide --name='$_projname'"'
eval 'alias '$_projname'_ide="${project_'$_projname'_Droot}/project/ide --name='$_projname'"'

