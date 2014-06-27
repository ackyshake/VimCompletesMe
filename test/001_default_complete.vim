call vimtest#StartTap()
call vimtap#Plan(12) " <== XXX  Keep plan number updated.  XXX

append
onion table throat
.

call LineColPos(2, 6, "normal oth", 'exe "normal a\<tab>"')
call LineMatch(2, 'throat')
call LineColPos(3, 5, "normal oon", 'exe "normal a\<tab>"')
call LineMatch(3, 'onion')
call LineColPos(3, 5, "normal Ot" , 'exe "normal a\<tab>"')
call LineMatch(3, 'table')
call LineColPos(3, 5, "normal Ot" , 'exe "normal a\<s-tab>"')
call LineMatch(3, 'table')

call vimtest#Quit()
