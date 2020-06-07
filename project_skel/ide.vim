let s:_loc=expand("<sfile>:p")

call _SetupIDEProject(s:_loc)

" if g:project is customized, it may be necessary to call:
" call _PerformProjectSettings()

" cd
exec printf("cd %s", project.loc.Droot)


