let locs = split(@v, "\n")
let qfl = []
for loc in locs
    let nr = substitute(loc, '^[^:]*:', '', '')
    let name = substitute(loc, ':.*', '', '')
    let qfl += [ {"filename": name, "lnum": nr} ]
endfor
call setqflist(qfl)

