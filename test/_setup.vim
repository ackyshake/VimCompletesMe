for path in [expand('<sfile>:p:h:h')]
  let &rtp = path . ',' . &rtp . ',' . path . '/after'
endfor

runtime plugin/VimCompletesMe.vim

let g:test_count = 0

function! LineColPos(line, col, ...)
  for cmd in a:000
    exec cmd
  endfor
  let g:test_count += 1
  let msg = join(a:000, '|') . '.'
  let l = line('.')
  let c = col('.')
  echom l . ' ' . c
  call vimtap#Is(l, a:line, l, 'LineColPos Line, Test ' . g:test_count . ': ' . msg)
  call vimtap#Is(c, a:col, c, 'LineColPos Column, Test ' . g:test_count . ': ' . msg)
endfunction

function! VisualMatch(expected)
  call vimtap#Is(@", a:expected, @", 'VisualMatch. Test ' . g:test_count)
endfunction

function! LineMatch(line, expected)
  let line = getline(a:line)
  call vimtap#Is(line, a:expected, line, 'LineMatch. Test ' . g:test_count)
endfunction
