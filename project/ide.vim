let s:_loc=expand("<sfile>:p")
call _SetupIDEProject(s:_loc)

" cd
exec printf("cd %s", project.loc.Droot)


