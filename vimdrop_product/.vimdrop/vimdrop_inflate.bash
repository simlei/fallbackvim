_declare_dirvar() { local _dir="${BASH_SOURCE[0]}"; _dir="${_dir%/*}"; local varname="${1:-dir}"; local count="${2:-1}"; while [[ "$count" -gt 0 ]]; do _dir="${_dir%/*}"; let count-- || :; done; eval "$varname"'="$_dir"'; }
_declare_dirvar vimdropdir 0
vimroot="${1:-$PWD}"
cd "$vimroot"
tf="$vimdropdir/repo.tar.gz"; tar -xzf "$tf"
for file in "$vimdropdir"/part_*.tar.gz; do
    echo extracting $file
    tar -xzf "$file"
done
