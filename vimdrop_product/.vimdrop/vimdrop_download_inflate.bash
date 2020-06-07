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
