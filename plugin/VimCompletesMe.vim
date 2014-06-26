" VimCompletesMe.vim - For super simple tab completion
" Maintainer:          Akshay Hegde <http://github.com/ajh17>
" Version:             0.3 and then some
" Website:             <http://github.com/ajh17/VimCompletesMe>

" Vimscript Setup: {{{1
if exists("g:loaded_VimCompletesMe") || v:version < 703 || &compatible
    finish
endif
let g:loaded_VimCompletesMe = 1

" Options: {{{1

" vcm_tab_indents : governs behaviour of tab on a blank-leading line.
" NOTE: This option is only valid if <tab> is being used for
"       <plug>vcm_complete_next
" options:
" 0 == initiates completion
" 1 == [de]indent like ctrl-d/<tab>   :help i_ctrl-d
if !exists('g:vcm_tab_indents')
    let g:vcm_tab_indents = 1
endif

" vcm_direction : governs the direction in which vim looks for completion
"                 candidates for <plug>vcm_complete_next and
"                 <plug>vcm_complete_prev
" options:
"   'n' : use ctrl-n
"   'p' : use ctrl-p
if !exists('g:vcm_direction')
    let g:vcm_direction = 'n'
endif

" vcm_complete : an ordered list of completion methods to try before
"                falling back on ctrl-n (which is goverened by &complete)
" NOTE: The plugin default is to not check for extra completion types
"       but rather use ctrl-n/p which is governed by &complete.
"       Read :help 'complete'   for configuration options.
" NOTE: An additional buffer-local variable, if present, called
"       b:vcm_complete will override this global variable.
" options:
"   user : ctrl-x ctrl-u (uses &completefunc)
"   omni : ctrl-x ctrl-o (uses &omnifunc)
"   vim  : ctrl-x xtrl-v (useful for developing viml)
if !exists('g:vcm_complete')
    let g:vcm_complete = ''
endif


" Functions: {{{1

" vcm_complete()
" returns: string of comma separated special completion types
"          for this buffer (or globally)
function! s:vcm_complete()
  return get(b:, 'vcm_complete', get(g:, 'vcm_complete', ''))
endfunction

" try_special_completes()
" returns: a special completion expression, or the provided default
"          if no specials are set for this buffer (or globally)
"          OR all specials have already been tried
function! s:try_special_completes(default, types)
    let default = a:default
    let exp     = "\<c-e>" . default
    for type in split(a:types, ',')
        if (type == 'user') && (index(b:vcm_tried, 'user') == -1) && (&completefunc != '')
            let exp = "\<c-x>\<c-u>"
            call add(b:vcm_tried, 'user')
            break
        elseif (type == 'omni') && (index(b:vcm_tried, 'omni') == -1) && (&omnifunc != '')
            let exp = "\<c-x>\<c-o>"
            call add(b:vcm_tried, 'omni')
            break
        elseif type == 'vim' && (index(b:vcm_tried, 'vim') == -1)
            let exp = "\<c-x>\<c-v>"
            call add(b:vcm_tried, 'vim')
            break
        endif
    endfor
    return exp
endfunction

" complete()
" returns: a completion expression, first trying from within
"          the provided types, or the given default
function! s:complete(pos, default, types)
    let pos     = a:pos
    let default = a:default
    let types   = a:types
    let exp     = default
    if get(b:, 'tab_complete_pos', []) == pos
        let exp = s:try_special_completes(default, types)
    else
        let b:tab_complete_pos = pos
        let b:vcm_tried = []
    endif
    return exp
endfunction

" vim_completes_me()
" returns: 1. cycling if pop-up menu is visible
"          2. indent control (if usinig <tab> key)
"          3. a completion expression
function! s:vim_completes_me(next_prev)
    let dirs     = ["\<c-p>", "\<c-n>"]
    let inverted = a:next_prev ==? 'prev'
    let dir      = xor(g:vcm_direction =~? '[nf]', inverted)

    if pumvisible()
        return dirs[dir]
    endif

    let exp    = ''
    let types  = s:vcm_complete()
    let pos    = getpos('.')
    let substr = matchstr(strpart(getline(pos[1]), 0, pos[2]-1), "[^ \t]*$")

    if (strlen(substr) == 0) && g:vcm_tab_indents && (mapcheck('<tab>', 'i') =~? 'vcm_complete')
        return inverted ? "\<c-d>" : "\<tab>"
    endif

    let period = match(substr, '\.') != -1
    if has('win32') || has('win64')
        let file_pattern = match(substr, '\\') != -1
    else
        let file_pattern = match(substr, '\/') != -1
    endif

    if file_pattern
        let exp = "\<C-x>\<C-f>"
    elseif period && types =~ 'omni'
        let exp = s:complete(pos, '', 'omni')
    endif

    return exp != '' ? exp : s:complete(pos, dirs[dir], types)
endfunction

" Maps: {{{1
inoremap <expr> <plug>vcm_complete_next <SID>vim_completes_me('next')
inoremap <expr> <plug>vcm_complete_prev <SID>vim_completes_me('prev')

if !hasmapto('<plug>vcm_complete_next')
    imap <tab> <plug>vcm_complete_next
endif

if !hasmapto('<plug>vcm_complete_prev')
    imap <s-tab> <plug>vcm_complete_prev
endif

augroup VCM
    au!
    au InsertEnter * let b:vcm_tried = []
augroup END

" vim: sw=4 sts=4
