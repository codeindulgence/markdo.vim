nnoremap <Leader>[ a -     <Esc>hhhR[ ]<Esc>A
nnoremap <Leader>] o<Backspace> -     <Esc>hhhR[ ]<Esc>A
nnoremap <silent> <Return> :call MarkDoNewEntry()<CR>
nnoremap <silent> <Leader>x :call MarkDoToggleMark()<CR>
nnoremap <silent> <Leader>n :call MarkDoToggleMark("N")<CR>
nnoremap <silent> <Leader>b :call MarkDoToggleMark("B")<CR>
nnoremap <silent> <Leader>- :call MarkDoToggleMark("-")<CR>
nnoremap <silent> <Leader><Return> :call MarkDoNewWeek()<CR>

function! MarkDoFolds()
  let l:cur_line = getline(v:lnum)
  let l:next_line = getline(v:lnum+1)

  if l:cur_line =~ '^## '
    return ">1"
  else
    if l:next_line =~ "^## "
      return "<1"
    endif
  endif

  return -1
endfunction

function! MarkDoFoldText()
  let line = getline(v:foldstart)
  let line_text = substitute(line, '^## ', '', 'g')
  return line_text
endfunction

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

function! MarkDoNewEntry()
  let l:line_no = line(".")
  call append(l:line_no, "")
  if getline(l:line_no) != ""
    call cursor(l:line_no + 1, 0)
    let l:line_no = line(".")
  endif
  call setline(l:line_no, "- [ ] ")
  startinsert!
endfunction

function! MarkDoNewWeek()
  let l:end = line("$")
  let l:week_start = trim(system("date --date='last monday' +%Y-%m-%d"))
  let l:week_end = trim(system("date --date='next friday' +%Y-%m-%d"))

  if getline(l:end) != ""
    call append(l:end, "")
  endif

  call append(line("$"), [
    \"## " . l:week_start . " - " . l:week_end,
    \"**Monday**", "",
    \"**Tuesday**", "",
    \"**Wednesday**", "",
    \"**Thursday**", "",
    \"**Friday**", ""
  \])
  call cursor(line("$"), 0)
endfunction

set foldmethod=expr
set foldexpr=MarkDoFolds()
set foldtext=MarkDoFoldText()
