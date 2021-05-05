function! MarkdoFold()
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

function! MarkFoldText()
  let line = getline(v:foldstart)
  let line_text = substitute(line, '^## ', '', 'g')
  return line_text
endfunction

function! s:toggle(...)
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

function! s:new()
  let l:line_no = line(".")
  call append(l:line_no, "")
  if getline(l:line_no) != ""
    call cursor(l:line_no + 1, 0)
    let l:line_no = line(".")
  endif
  call setline(l:line_no, "- [ ] ")
  startinsert!
endfunction

function! s:week()
  let l:end = line("$")
  let l:week_start = trim(system("date --date='last monday' +%Y-%m-%d"))
  let l:week_end = trim(system("date --date='next friday' +%Y-%m-%d"))

  if getline(l:end) != ""
    call append(l:end, "")
  endif

  call append(line("$"), [
    \"## " . l:week_start . " - " . l:week_end,
    \"**Monday**", ""
  \])

  let l:monday = line("$") - 1

  call append(line("$"), [
    \"**Tuesday**", "",
    \"**Wednesday**", "",
    \"**Thursday**", "",
    \"**Friday**", ""
  \])

  echo "monday at " . l:monday
  call cursor(l:monday, 0)
endfunction

function! s:i_return()
  let l:line = getline(".")

  if l:line[-1:] == ':'
    return "\n    | "
  elseif l:line[:2] == '- ['
    return "\n- [ ] "
  else
    return "\n"
  endif
endfunction

setlocal foldmethod=expr
setlocal foldexpr=MarkdoFold()
setlocal foldtext=MarkFoldText()

setlocal comments=:\|
setlocal formatoptions=jtcqlnroaw

syntax match todoRef /@[a-z]\+/
syntax match todoTime /\d\d:\d\d-\d\d:\d\d/
syntax region todoStarted start=/- \[-\]/ end=/$/
syntax region todoDone start=/- \[x\]/ end=/$/ contains=todoRef,todoTime
syntax region todoNew start=/- \[N\]/ end=/$/ contains=todoRef,todoTime
syntax region todoBlocked start=/- \[B\]/ end=/$/ contains=todoRef,todoTime
syntax region todoExtra start=/^    |/ end=/$/ contains=todoRef,todoTime

highlight default link todoRef Keyword
highlight default link todoTime Number
highlight default link todoStarted Tag
highlight default link todoDone Comment
highlight default link todoNew String
highlight default link todoBlocked Exception
highlight default link todoExtra Special

nnoremap <buffer> <silent> o :call <SID>new()<CR>
nnoremap <buffer> <silent> <CR> :call <SID>toggle()<CR>
nnoremap <buffer> <silent> <Leader>x :call <SID>toggle()<CR>
nnoremap <buffer> <silent> <Leader>n :call <SID>toggle("N")<CR>
nnoremap <buffer> <silent> <Leader>b :call <SID>toggle("B")<CR>
nnoremap <buffer> <silent> <Leader>- :call <SID>toggle("-")<CR>
nnoremap <buffer> <silent> <Leader><CR> :call <SID>week()<CR>
inoremap <buffer> <expr> <cr> <SID>i_return()
