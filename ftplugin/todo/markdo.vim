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
  return '> ' . line_text
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

function! markdo#opensearch()
  let s:todobufname = bufname()
  let s:todolines = getbufline(bufnr(s:todobufname), 1, "$")

  exe "edit markdosearch"
  call setline(1, "Search: ")
  startinsert!
  call append(1, repeat('-', 80))
endfunction

function! markdo#results(term)
  call deletebufline("markdosearch", 3, "$")
  for line in s:todolines
    if line[:2] == "## "
      let l:date = line[3:]
    endif

    if line[:1] == "**"
      let l:day = line[2:4]
    endif

    if line[:2] == "- ["
      let entry = line[2:]
      if match(entry, a:term) > 0
        call append(line("$"), date.", ".day.": ".entry)
      endif
    endif
  endfor
endfunction

function! markdo#search()
  let term = getline(1)[8:]
  echom "Term: " . term
  call markdo#results(term)
  return ""
endfunction

function! s:setscratch()
  setlocal buftype=nofile
  " setlocal bufhidden=wipe
  setlocal noswapfile
  setlocal nobuflisted
  setlocal filetype=markdown
  inoremap <buffer> <silent> <cr> <Esc>:call markdo#search()<CR>A
endfunction

autocmd BufNewFile markdosearch call s:setscratch()

function! markdo#week(...)
  let l:dowcmd = "date +%u" " Day Of Week
  let l:dow = str2nr(trim(system(l:dowcmd)))

  if a:0 > 0
    let l:offset = str2nr(a:1)-1
  else " Get current week
    if l:dow == 1
      let l:offset = 0
    else
      let l:offset = -1
    endif
  endif

  let l:fmt = "+%d %b %Y"
  let l:end = line("$")
  let l:days = [
    \[1, 'Mon'],
    \[2, 'Tue'],
    \[3, 'Wed'],
    \[4, 'Thu'],
    \[5, 'Fri']
  \]

  for [i, day] in l:days
    if i == l:dow
      let l:offset += 1
    endif
    let l:datecmd = "date --date='".day." ".l:offset." week' '" . l:fmt . "'"
    let l:date = trim(system(l:datecmd))

    if day == 'Mon'
      let l:startdate = l:date
      let l:weektop = line("$")
    endif

    if day == 'Fri'
      call append(l:weektop, "## " . l:startdate . " - " . l:date)
    endif

    call append(line("$"), ["**" . day . ", " . l:date[:1] . "**", ""])
  endfor
  call append(line("$"), repeat('-', 80))

  call cursor(l:weektop+1, 0)
  normal zz
endfunction

function! s:entry()
  let l:line = getline(".")

  if l:line[-1:] == ':'
    return "\n    > "
  elseif l:line[:2] == '- ['
    return "\n- [ ] "
  else
    return "\n"
  endif
endfunction

setlocal foldmethod=expr
setlocal foldexpr=markdo#fold()
setlocal foldtext=markdo#foldtext()

setlocal comments=:>
setlocal formatoptions=jtcqlnroaw
setlocal nonumber
setlocal norelativenumber
setlocal signcolumn=no
setlocal iskeyword+=#

syntax match todoRef /@[a-z]\+/
syntax match todoTime /\d\d:\d\d-\d\d:\d\d/
syntax match todoTag /#[a-z-]\+/
syntax region todoStarted start=/- \[-\]/ end=/$/
syntax region todoDone start=/- \[x\]/ end=/$/ contains=todoRef,todoTime,todoTag
syntax region todoNew start=/- \[N\]/ end=/$/ contains=todoRef,todoTime,todoTag
syntax region todoBlocked start=/- \[B\]/ end=/$/ contains=todoRef,todoTime,todoTag
syntax region todoExtra start=/^    >/ end=/$/ contains=todoRef,todoTime,todoTag

highlight default link todoRef Keyword
highlight default link todoTime Number
highlight default link todoTag Function
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
inoremap <buffer> <expr> <cr> <SID>entry()
