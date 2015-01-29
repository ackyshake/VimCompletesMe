" VimCompletesMe.vim - For super simple tab completion
" Maintainer:          Akshay Hegde <http://github.com/ajh17>
" Version:             1.0
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

if !exists('g:vcm_direction')
  let g:vcm_direction = 'n'
endif

if !exists('g:vcm_default_maps')
  let g:vcm_default_maps = 1
endif

" Functions: {{{1
function! s:vim_completes_me(shift_tab)
  let dirs = ["\<c-p>", "\<c-n>"]
  let dir = g:vcm_direction =~? '[nf]'
  let map = exists('b:vcm_tab_complete') ? b:vcm_tab_complete : ''

  if pumvisible()
    if a:shift_tab
      return dirs[!dir]
    else
      return dirs[dir]
    endif
  endif

  " Figure out whether we should indent.
  let pos = getpos('.')
  let substr = matchstr(strpart(getline(pos[1]), 0, pos[2]-1), "[^ \t]*$")
  if strlen(substr) == 0
    return (a:shift_tab && !g:vcm_s_tab_behavior) ? "\<C-d>" : "\<Tab>"
  endif

  " Figure out if user has started typing a path or a period
  let period = match(substr, '\.') != -1
  let file_path = (has('win32') || has('win64')) ? '\\' : '\/'
  let file_pattern = match(substr, file_path) != -1

  if file_pattern
    return "\<C-x>\<C-f>"
  elseif period && (&omnifunc != '')
    if get(b:, 'tab_complete_pos', []) == pos
      let exp = "\<C-x>" . dirs[!dir]
    else
      let exp = "\<C-x>\<C-o>"
    endif
    let b:tab_complete_pos = pos
    return exp
  endif

  " First fallback to keyword completion if special completion was already tried.
  if b:completion_tried
    let b:completion_tried = 0
    return "\<C-e>" . dirs[!dir]
  endif

  " Fallback
  let b:completion_tried = 1
  if map ==? "user"
    return "\<C-x>\<C-u>"
  elseif map ==? "tags"
    return "\<C-x>\<C-]>"
  elseif map ==? "omni"
    return "\<C-x>\<C-o>"
  elseif map ==? "dict"
    return "\<C-x>\<C-k>"
  elseif map ==? "vim"
    return "\<C-x>\<C-v>"
  else
    return "\<C-x>" . dirs[!dir]
  endif
endfunction

" Maps: {{{1
if g:vcm_default_maps
  inoremap <expr> <Tab> <SID>vim_completes_me(0)
  inoremap <expr> <S-Tab> <SID>vim_completes_me(1)
endif

" Autocmds {{{1
augroup VCM
  autocmd!
  autocmd InsertEnter * let b:completion_tried = 0
augroup END
