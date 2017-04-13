call vimtest#StartTap()
call vimtap#Plan(6) " <== XXX  Keep plan number updated.  XXX

so user_complete.vim
let g:vcm_complete = 'user'

append
throat
.

call LineColPos(2, 6, "normal! oth", 'exe "normal a\<tab>"')
call LineMatch(2, 'throat')

call LineColPos(3, 3, "normal! oNo", 'exe "normal a\<tab>\<tab>"')
call LineMatch(3, 'Nov')

call vimtest#Quit()
