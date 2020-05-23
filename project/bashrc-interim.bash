_declare_dirvar() { local _dir="${BASH_SOURCE[0]}"; _dir="${_dir%/*}"; local varname="${1:-dir}"; local count="${2:-1}"; while [[ "$count" -gt 0 ]]; do _dir="${_dir%/*}"; let count-- || :; done; eval "$varname"'="$_dir"'; }
_declare_dirvar _projdefdir 0
_declare_dirvar _projbasedir 1

# TODO: replace the project name to get sane aliases and variables
_projname=fbvim; _projname="${_projname//[^A-Za-z]/}"

_declare_dirvar project__${_projname}__Droot 1
eval 'alias '$_projname'_ide="${project__'$_projname'__Droot}/project/ide --name='$_projname'"'





vim_projectdrop() {
    mkdir ./project && cp -r "$project__fbvim__Droot/project_skel"/* ./project/
    echo "source $PWD/project/bashrc-interim.bash" >> "$HOME/.bashrc"
}

# tar plugins into .vimdrop
# git zip everything into .vimdrop
# upon extraction: extract everything into .vimdrop at the target loc (tar does this as that relpath is saved)
# then, next to .vimdrop, extract as seen in heredoc
vimdrop_build() {
    local targetabs="$project__fbvim__Droot/vimdrop_product"
    local targetrel="./vimdrop_product"
    local packrel="pack/standalone"
    rm -rf "$targetabs" >/dev/null 2>&1 || :

    ( cd "$project__fbvim__Droot"; mkdir -p $targetabs/.vimdrop;
    git archive --format=tar "@" | gzip > "$targetabs/.vimdrop/repo.tar.gz"
    tar --exclude-vcs -I pigz -cf "$targetabs/.vimdrop/part_essentialplugins.tar.gz" "$packrel/start/"
    # tar --exclude-vcs -I pigz -cf "$targetabs/.vimdrop/part_opt.tar.gz" "$packrel/opt/"
    cat > "$targetabs/.vimdrop/vimdrop_inflate.bash" <<-'EOF'
_declare_dirvar() { local _dir="${BASH_SOURCE[0]}"; _dir="${_dir%/*}"; local varname="${1:-dir}"; local count="${2:-1}"; while [[ "$count" -gt 0 ]]; do _dir="${_dir%/*}"; let count-- || :; done; eval "$varname"'="$_dir"'; }
_declare_dirvar vimdropdir 0
_declare_dirvar vimroot 1
cd "$vimroot"
tf="$vimdropdir/repo.tar.gz"; tar -xzf "$tf"
for file in "$vimdropdir"/part_*.tar.gz; do
    tar -xzf "$file"
done
EOF
    cat > "$targetabs/.vimdrop/vimdrop_download_inflate.bash" <<-"EOF"
: ${tmpdir:="/tmp/simlei_vimdrop"} && \
    mkdir -p "$tmpdir" && \
    ( cd "$tmpdir" && \
        curl -L https://tinyurl.com/vimdroptar | tar -zxf - && \
        bash "$tmpdir/.vimdrop/vimdrop_inflate.bash" && \
        ls -la $PWD 
    ) && \
    echo alias v="vim -u $tmpdir/vimrc" && \
    alias v="vim -u $tmpdir/vimrc"
EOF
    echo tar -C "$targetabs" -czf "$targetabs/vimdrop.tar.gz" "./.vimdrop/"
    tar -C "$targetabs" -czf "$targetabs/vimdrop.tar.gz" "./.vimdrop/"
    )
}

vimdrop_toDropbox() {
    local dbdir="/media/shared/dropboxUbuntu18/dbLocaltion/Dropbox"
    cp -r "$project__fbvim__Droot/vimdrop_product/vimdrop.tar.gz" "$dbdir"/
    cp -r "$project__fbvim__Droot/vimdrop_product/.vimdrop/vimdrop_download_inflate.bash" "$dbdir"/
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
