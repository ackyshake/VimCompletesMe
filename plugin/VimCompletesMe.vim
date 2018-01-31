" VimCompletesMe.vim - Super simple tab completion
" Maintainer:          Akshay Hegde <http://github.com/ajh17>
" Version:             1.4
" Website:             <http://github.com/ajh17/VimCompletesMe>

" Vimscript Setup: {{{1
if exists("g:loaded_VimCompletesMe") || v:version < 703 || &compatible
  finish
endif
let g:loaded_VimCompletesMe = 1

" Options: {{{1
if !exists('g:vcm_s_tab_behavior')
  let g:vcm_s_tab_behavior = 0
endif
if !exists('g:vcm_direction_keyword')
  let g:vcm_direction_keyword = 'p'
endif
if !exists('g:vcm_direction_special')
  let g:vcm_direction_special = 'n'
endif
if !exists('g:vcm_default_maps')
  let g:vcm_default_maps = 1
endif
if !exists('g:vcm_omni_pattern')
  let g:vcm_omni_pattern = '\k\+\(\.\|->\|::\)\k*$'
endif

" Variables: {{{1
let b:special_completion = 1

" Functions: {{{1
function! s:vim_completes_me(shift_tab)
  let dirs = ["\<c-n>", "\<c-p>"]
  let dir_keyword = g:vcm_direction_keyword ==# 'p'
  let dir_special = g:vcm_direction_special ==# 'p'
  if g:vcm_direction_special ==# 'p'
    let suffix_special = "\<C-p>\<C-p>"
  else
    let suffix_special = ""
  endif

  " Navigate the popup menu
  if pumvisible()
    if b:special_completion
      return a:shift_tab ? dirs[!dir_special] : dirs[dir_special]
    else
      return a:shift_tab ? dirs[!dir_keyword] : dirs[dir_keyword]
    endif
  endif

  " Use the user's supplied shift-tab mapping
  if a:shift_tab && exists('g:vcm_shift_tab_mapping')
      return g:vcm_shift_tab_mapping
  endif

  " Indent/unindent if on whitespace
  let pos = getpos('.')
  let substr = matchstr(strpart(getline(pos[1]), 0, pos[2]-1), "[^ \t]*$")
  if empty(substr)
      let s_tab_deindent = pos[2] > 1 ? "\<C-h>" : ""
      return (a:shift_tab && !g:vcm_s_tab_behavior) ? l:s_tab_deindent : "\<Tab>"
  endif

  " Do the proper completion
  let completion_type = exists('b:vcm_tab_complete') ? b:vcm_tab_complete : ''
  let omni_pattern = get(b:, 'vcm_omni_pattern', get(g:, 'vcm_omni_pattern'))
  let is_omni_pattern = match(substr, omni_pattern) != -1
  let file_pattern = (has('win32') || has('win64')) ? '\\\|\/' : '\/'
  let is_file_pattern = match(substr, file_pattern) != -1

  if b:completion_tried
    if get(b:, 'tab_complete_pos', []) == pos
      " If there were no completion results
      let b:special_completion = 0
      " Fallback to keyword completion
      return "\<C-e>" . dirs[dir_keyword]
    else
      " If there was only one match and menuone is unset
      " (Possible to remain in ^X mode while typing)
      let b:tab_complete_pos = pos
      " (Direction doesn't matter bc there's only 1 result)
      return "\<C-n>"
    endif
  else
    let b:completion_tried = 1
    let b:tab_complete_pos = pos
    if empty(completion_type)
      if is_omni_pattern && !empty(&omnifunc)
        let b:special_completion = 1
        let exp = "\<C-x>\<C-o>" . suffix_special
      elseif is_file_pattern
        let b:special_completion = 1
        let exp = "\<C-x>\<C-f>" . suffix_special
      else
        let b:special_completion = 0
        let exp = dirs[dir_keyword]
      endif
    else
      if completion_type ==? "keyword"
        let b:special_completion = 0
        let exp = dirs[dir_keyword]
      else
        let b:special_completion = 1
        if completion_type ==? "omni" && !empty(&omnifunc)
          let exp = "\<C-x>\<C-o>" . suffix_special
        elseif completion_type ==? "user" && !empty(&completefunc)
          let exp = "\<C-x>\<C-u>" . suffix_special
        elseif completion_type ==? "file"
          let exp = "\<C-x>\<C-f>" . suffix_special
        elseif completion_type ==? "vim"
          let exp = "\<C-x>\<C-v>" . suffix_special
        elseif completion_type =~? "tags?"
          let exp = "\<C-x>\<C-[>" . suffix_special
        elseif completion_type ==? "dict" && !empty(&dictionary)
          let exp = "\<C-x>\<C-K>" . suffix_special
        endif
      endif
    endif
    return exp
  endif

endfunction

inoremap <expr> <plug>vim_completes_me_forward  <sid>vim_completes_me(0)
inoremap <expr> <plug>vim_completes_me_backward <sid>vim_completes_me(1)

" Maps: {{{1
if g:vcm_default_maps
  imap <Tab>   <plug>vim_completes_me_forward
  imap <S-Tab> <plug>vim_completes_me_backward
endif

" Autocmds {{{1
augroup VCM
  autocmd!
  autocmd InsertEnter * let b:completion_tried = 0
  if v:version > 703 || v:version == 703 && has('patch598')
    autocmd CompleteDone * let b:completion_tried = 0
  endif
augroup END
