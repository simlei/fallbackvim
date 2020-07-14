# local vimdrop:
# export tmpdir="$PWD"; export tarloc="file://$HOME/.vim/vimdrop_product/vimdrop.tar.gz"; cat /home/simon/.vim/vimdrop_product/.vimdrop/vimdrop_download_inflate.bash | bash

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
    vim ./project/bashrc-interim.bash && exec bash
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
    echo git archive --format=tar "@" "|" gzip ">" "$targetabs/.vimdrop/repo.tar.gz"
    git archive --format=tar "@" | gzip > "$targetabs/.vimdrop/repo.tar.gz"
    # echo tar --exclude-vcs -c "$packrel/start/" "|" gzip ">" "$targetabs/.vimdrop/part_essentialplugins.tar.gz"
    # tar --exclude-vcs -c "$packrel/start/" | gzip > "$targetabs/.vimdrop/part_essentialplugins.tar.gz"
    for startpack in "$packrel/start"/*; do
        if [[ ! -d "$startpack" ]]; then continue; fi
        local packname="$(basename "$startpack")"
        echo tar --exclude-vcs -c "$startpack/" "|" gzip ">" "$targetabs/.vimdrop/part_start_${packname}.tar.gz"
        tar --exclude-vcs -c "$startpack/" | gzip > "$targetabs/.vimdrop/part_start_${packname}.tar.gz"
    done
    # for optpack in "$packrel/opt"/*; do
    #     if [[ ! -d "$optpack" ]]; then continue; fi
    #     local packname="$(basename "$optpack")"
    #     echo tar --exclude-vcs -c "$optpack/" "|" gzip ">" "$targetabs/.vimdrop/part_opt_${packname}.tar.gz"
    #     tar --exclude-vcs -c "$optpack/" | gzip > "$targetabs/.vimdrop/part_opt_${packname}.tar.gz"
    # done
    cat > "$targetabs/.vimdrop/vimdrop_inflate.bash" <<-'EOF'
_declare_dirvar() { local _dir="${BASH_SOURCE[0]}"; _dir="${_dir%/*}"; local varname="${1:-dir}"; local count="${2:-1}"; while [[ "$count" -gt 0 ]]; do _dir="${_dir%/*}"; let count-- || :; done; eval "$varname"'="$_dir"'; }
_declare_dirvar vimdropdir 0
_declare_dirvar vimroot 1
cd "$vimroot"
tf="$vimdropdir/repo.tar.gz"; tar -xzf "$tf"
for file in "$vimdropdir"/part_*.tar.gz; do
    echo extracting $file
    tar -xzf "$file"
done
EOF
    cat > "$targetabs/.vimdrop/vimdrop_download_inflate.bash" <<-"EOF"
: ${tmpdir:="/tmp/simlei_vimdrop"} && \
: ${tarloc:="https://tinyurl.com/vimdroptar2"} && \
    mkdir -p "$tmpdir" && \
    ( cd "$tmpdir" && \
        echo downloading and extracting "$tarloc" && \
        curl -L "$tarloc" | tar -zxf - && \
        echo "downloaded and extracted (first stage)" && \
        bash "$tmpdir/.vimdrop/vimdrop_inflate.bash" && \
        ls -la $PWD 
    ) && \
    echo alias v="vim -u $tmpdir/vimrc" && \
    alias v="vim -u $tmpdir/vimrc"
EOF
    echo tar -C "$targetabs" -c "./.vimdrop/" "|" gzip ">" "$targetabs/vimdrop.tar.gz"
    tar -C "$targetabs" -c "./.vimdrop/" | gzip > "$targetabs/vimdrop.tar.gz"
    )
}

vimdrop_toDropbox() {
    local dbdir="/media/shared/dropboxUbuntu18/dbLocaltion/Dropbox"
    cp -r "$project__fbvim__Droot/vimdrop_product/vimdrop.tar.gz" "$dbdir"/
    cp -r "$project__fbvim__Droot/vimdrop_product/.vimdrop/vimdrop_download_inflate.bash" "$dbdir"/
}

vimdrop_build_deploy() (
    set -euo pipefail
    vimdrop_build
    vimdrop_toDropbox
    echo Success
)


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
