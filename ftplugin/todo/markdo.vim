function! markdo#fold()
  let l:cur_line = getline(v:lnum)

  if l:cur_line =~ '^## '
    return ">1"
  endif

  if l:cur_line =~ '^-\+$'
    return "<1"
  endif

  return -1
endfunction

function! markdo#foldtext()
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

function! markdo#week(...)
  if a:0 > 0
    let l:offset = str2nr(a:1)-1
  else
    let l:offset = -1 " Get's last Monday
  endif

  let l:fmt = "+%Y-%m-%d"
  let l:start_cmd = "date --date='monday ".l:offset." week' " . l:fmt
  let l:end_cmd = "date --date='friday ".(l:offset+1)." week' " . l:fmt

  let l:end = line("$")
  let l:week_start = trim(system(l:start_cmd))
  let l:week_end = trim(system(l:end_cmd))
  let l:days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']

  call append(line("$"), "## " . l:week_start . " - " . l:week_end)
  for day in l:days
    call append(line("$"), "### " . day)
    if day == 'Monday'
      let l:monday = line("$") - 1
    endif
  endfor
  call append(line("$"), repeat('-', 80))

  call cursor(l:monday, 0)
  normal zt
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
setlocal foldexpr=markdo#fold()
setlocal foldtext=markdo#foldtext()

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
nnoremap <buffer> <silent> - :call <SID>toggle("-")<CR>
nnoremap <buffer> <silent> <Leader>x :call <SID>toggle()<CR>
nnoremap <buffer> <silent> <Leader>n :call <SID>toggle("N")<CR>
nnoremap <buffer> <silent> <Leader>b :call <SID>toggle("B")<CR>
nnoremap <buffer> <silent> <Leader><CR> :call markdo#week()<CR>
inoremap <buffer> <expr> <cr> <SID>i_return()
