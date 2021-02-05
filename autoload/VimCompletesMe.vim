" VimCompletesMe.vim - Super simple tab completion
" Maintainer:          Akshay Hegde <http://github.com/ackyshake>
" Version:             1.5.2
" Website:             <http://github.com/ackyshake/VimCompletesMe>

function! VimCompletesMe#vim_completes_me(shift_tab)
  let dirs = ["\<c-n>", "\<c-p>"]
  let dir = g:vcm_direction =~? '[nf]'
  let map = exists('b:vcm_tab_complete') ? b:vcm_tab_complete : ''

  if pumvisible()
    return a:shift_tab ? dirs[dir] : dirs[!dir]
  endif

  " Figure out whether we should indent/de-indent.
  let pos = getpos('.')
  let substr = matchstr(strpart(getline(pos[1]), 0, pos[2]-1), "[^ \t]*$")
  if empty(substr)
    let s_tab_deindent = pos[2] > 1 ? "\<C-h>" : ""
    return (a:shift_tab && !g:vcm_s_tab_behavior) ? l:s_tab_deindent : "\<Tab>"
  endif

  if a:shift_tab && exists('g:vcm_s_tab_mapping')
    return g:vcm_s_tab_mapping
  endif

  let omni_pattern = get(b:, 'vcm_omni_pattern', get(g:, 'vcm_omni_pattern'))
  let file_pattern = (has('win32') || has('win64')) ? '\\\|\/' : '\/'
  let return_exp = &completeopt =~ 'noselect' ? "\<C-p>" : "\<C-p>\<C-p>"

	" Automatic fallback action
	let b:shift_tab = a:shift_tab
	if exists('b:fallback_tried') && b:fallback_tried
		let fallback_action = ""
	else
		let fallback_action = "\<C-r>=VimCompletesMe#check_completion()\<CR>"
	endif

  if !empty(&omnifunc) && match(substr, omni_pattern) != -1
    " Check position so that we can fallback if at the same pos.
    if get(b:, 'tab_complete_pos', []) == pos && b:completion_tried
      echo "Falling back to keyword"
			let b:fallback_tried = 1
      let exp = "\<C-x>" . dirs[!dir]
    else
      echo "Looking for members..."
      if !empty(&completefunc) && map ==? "user"
        let exp = dir ? "\<C-x>\<C-u>" . fallback_action : "\<C-x>\<C-u>" . return_exp . fallback_action
      else
        let exp = dir ? "\<C-x>\<C-o>" . fallback_action : "\<C-x>\<C-o>" . return_exp . fallback_action
      endif
      let b:completion_tried = 1
    endif
    let b:tab_complete_pos = pos
    return exp
  elseif match(substr, file_pattern) != -1
    return dir ? "\<C-x>\<C-f>" : "\<C-x>\<C-f>" . return_exp
  endif

  " If we already tried special completion, fallback to keyword completion
  if exists('b:completion_tried') && b:completion_tried
    let b:completion_tried = 0
		let b:fallback_tried = 1
    return "\<C-e>" . dirs[!dir]
  endif

  " Fallback to user's vcm_tab_complete or if not set, to keyword completion
  let b:completion_tried = 1
  if map ==? "user"
    return dir ? "\<C-x>\<C-u>" . fallback_action  : "\<C-x>\<C-u>" . return_exp . fallback_action
  elseif map ==? "omni"
    echo "Looking for members..."
    return dir ? "\<C-x>\<C-o>" . fallback_action : "\<C-x>\<C-o>" . return_exp . fallback_action
  elseif map ==? "vim"
    return dir ? "\<C-x>\<C-v>" . fallback_action  : "\<C-x>\<C-v>" . return_exp . fallback_action
  else
    return dirs[!dir]
  endif
endfunction

function! VimCompletesMe#check_completion()
	if !pumvisible()
		let b:fallback_tried = 1
		let exp = VimCompletesMe#vim_completes_me(b:shift_tab)
		let b:fallback_tried = 0
		return exp
	endif
endfunction
