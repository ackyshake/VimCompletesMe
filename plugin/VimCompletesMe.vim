" Vimscript Setup
if exists("g:loaded_VimCompletesMe") || v:version < 703 || &compatible
  finish
endif
let g:loaded_VimCompletesMe = 1

let g:vcm_completions = {
  \ 'file':  {'rank': 10,
  \           'keys': "\<C-x>\<C-f>",
  \           'pattern': '\v' . (has('win32') ? '\f\\' : '\/') . '\f*$' },
  \ 'omni':  {'rank': 20,
  \           'keys': "\<C-x>\<C-o>",
  \           'pattern': '\v\k+(\.|->|::)\k*$' },
  \ 'user':  {'rank': 30,
  \           'keys': "\<C-x>\<C-u>",
  \           'pattern': 0 },
  \ 'line':  {'rank': 40,
  \           'keys': "\<C-x>\<C-l>",
  \           'pattern': '\v^\s*\k+$' },
  \ 'spell': {'rank': 50,
  \           'keys': "\<C-x>\<C-s>",
  \           'pattern': 0 },
  \ 'vim':   {'rank': 60,
  \           'keys': "\<C-x>\<C-v>",
  \           'pattern': 0 },
  \ 'gen':   {'rank': 99,
  \           'keys': "\<C-n>",
  \           'pattern': '\v\k+$' },
  \ }

function! s:rank(i1, i2)
  let rank1 = b:completions[a:i1].rank
  let rank2 = b:completions[a:i2].rank
	return rank1 == rank2 ? 0 : rank1 > rank2 ? 1 : -1
endfunction

function! s:complete(shift)
  let Ctrl_PN = a:shift ? "\<C-p>" : "\<C-n>"

  if pumvisible()
    return Ctrl_PN
  endif
  
  " Cursor after whitespace => indent
  let pos = getpos('.')
  let textBeforeCursor = strpart(getline(pos[1]), 0, pos[2]-1)
  if textBeforeCursor =~ '\v(\s+|^)$'
    return a:shift ? "\<C-W>" : "\<tab>"
  endif

  " Completion failed => Vim's generic keyword completion
  if get(b:,'completion_tried') && (get(b:, 'tab_complete_pos', []) == pos)
    let b:completion_tried = 0
    return "\<C-e>" . Ctrl_PN
  endif

  " Start completing => keep record for fallback
  let b:tab_complete_pos = pos
  let b:completion_tried = 1

  " User is typing a path or omnicomplete or tabcomplete pattern?
  for c in sort(keys(b:completions), 's:rank')
    let is_pattern = ( (b:completions[c].pattern isnot 0)  && match(textBeforeCursor, b:completions[c].pattern) >= 0)
    if is_pattern
      return b:completions[c].keys
    endif
  endfor
endfunction

function! s:vcm_init()
  if !exists('b:completions')
    let b:completions = deepcopy(g:vcm_completions)
  endif
  if empty(&l:omnifunc) && exists('b:completions.omni')
    let b:completions.omni.pattern = 0
  elseif empty(&l:completefunc) && exists('b:completions.user')
    let b:completions.user.pattern = 0
  elseif !&l:spell && exists('b:completions.spell')
    let b:completions.spell.pattern = 0
  endif
endfunction

augroup VCM
  autocmd!
  autocmd InsertEnter * call s:vcm_init()
  autocmd InsertEnter * let b:completion_tried = 0
  if v:version > 703 || v:version == 703 && has('patch598')
    autocmd CompleteDone * let b:completion_tried = 0
  endif
augroup END

inoremap <expr> <plug>vim_completes_me_forward  <sid>complete(0)
inoremap <expr> <plug>vim_completes_me_backward <sid>complete(1)

function! <SID>cursorBehindPath()
  let pos = getpos('.')
  let textBeforeCursor = strpart(getline(pos[1]), 0, pos[2]-1)
  return  textBeforeCursor =~ '\v\f+' . (has('win32') ? '\\' : '\/')
endfunction

if !(exists('g:vcm_no_default_maps') && g:vcm_no_default_maps)
  imap              <Tab>     <plug>vim_completes_me_forward
  imap              <S-Tab>   <plug>vim_completes_me_backward
  execute   'inoremap <expr> ' . (has('win32') ? '\' : '/') . ' '
        \ . '(pumvisible() && <SID>cursorBehindPath()) ?'
        \ . '"\<C-y>\<C-x><C-f>" : "' . (has('win32') ? '\' : '/') . '"'
endif
