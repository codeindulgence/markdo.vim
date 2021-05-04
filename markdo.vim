nnoremap <Leader>[ a -     <Esc>hhhR[ ]<Esc>A
nnoremap <Leader>] o<Backspace> -     <Esc>hhhR[ ]<Esc>A
nnoremap <silent> <Return><Return> :call MarkDoToggleMark()<CR>
nnoremap <silent> <Return>n :call MarkDoToggleMark("N")<CR>
nnoremap <silent> <Return>b :call MarkDoToggleMark("B")<CR>
nnoremap <silent> <Return>- :call MarkDoToggleMark("-")<CR>

function! MarkDoToggleMark(...)
  let l:line_no = line(".")
  let l:cur_line = getline(line("."))

  let l:pattern = "- \\[\\(.\\)\\] \\(.*\\)"
  let l:matches = matchlist(l:cur_line, l:pattern)

  if a:0 > 0
    let l:mark = a:1
  else
    let l:mark = "x"
  endif

  if len(l:matches) > 0
    let l:cur_mark = l:matches[1]
    let l:text = l:matches[2]

    if l:cur_mark == l:mark
      let l:mark = " "
    endif

    let l:new_line = "- [" . l:mark . "] " . l:text
    call setline(l:line_no, l:new_line)
  endif
endfunction

function! MarkDoFolds(lnum)
  let l:cur_line = getline(a:lnum)
  let l:next_line = getline(a:lnum+1)

  if l:cur_line =~ '^## '
    return 1
  else
    if l:next_line =~ "^## "
      return "<1"
    endif
  endif

  return "="
endfunction

function! MarkDoFoldText()
  let line = getline(v:foldstart)
  let line_text = substitute(line, '^## ', '', 'g')
  return line_text
endfunction

set foldmethod=expr
set foldexpr=MarkDoFolds(v:lnum)
set foldtext=MarkDoFoldText()
