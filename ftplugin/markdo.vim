setlocal foldmethod=expr
setlocal foldexpr=markdo#fold()
setlocal foldtext=markdo#foldtext()
setlocal comments=:>
setlocal formatoptions=jtcqlnroaw
setlocal nonumber
setlocal norelativenumber
setlocal signcolumn=no
setlocal iskeyword+=#,@-@
setlocal fillchars=fold:\ 
setlocal colorcolumn=0

syntax match todoRef /\s@[a-z.]\+/
syntax match todoTime /\d\d:\d\d-\d\d:\d\d/
syntax match todoDate /\d\d\d\d-\d\d-\d\d/
syntax match todoTag /#[a-z-]\+/
syntax region todoStarted start=/- \[-\]/ end=/$/
syntax region todoDone start=/- \[x\]/ end=/$/ contains=todoRef,todoTime,todoTag
syntax region todoNew start=/- \[N\]/ end=/$/ contains=todoRef,todoTime,todoTag
syntax region todoBlocked start=/- \[B\]/ end=/$/ contains=todoRef,todoTime,todoTag
syntax region todoExtra start=/^    >/ end=/$/ contains=todoRef,todoTime,todoTag

highlight default link todoRef Keyword
highlight default link todoTime Number
highlight default link todoDate Number
highlight default link todoTag Function
highlight default link todoStarted Tag
highlight default link todoDone Comment
highlight default link todoNew String
highlight default link todoBlocked Exception
highlight default link todoExtra Special
highlight Folded ctermbg=NONE

nnoremap <buffer> <silent> o :call <SID>new()<CR>
nnoremap <buffer> <silent> <CR> :call <SID>toggle()<CR>
nnoremap <buffer> <silent> - :call <SID>toggle("-")<CR>
nnoremap <buffer> <silent> <Leader>x :call <SID>toggle()<CR>
nnoremap <buffer> <silent> <Leader>n :call <SID>toggle("N")<CR>
nnoremap <buffer> <silent> <Leader>b :call <SID>toggle("B")<CR>
nnoremap <buffer> <silent> <Leader><CR> :call markdo#week()<CR>
nnoremap <buffer> <silent> g/ :MDSearch<CR>
nnoremap <buffer> <silent> g<Tab> :MDSearchLine<CR>
nnoremap <buffer> <silent> g<CR> :MDSearchWord<CR>
nnoremap <buffer> <silent> g! :MDIncomplete<CR>
nnoremap <buffer> <silent> gt :MDJump today<CR>
nnoremap <buffer> <silent> K ddkP
nnoremap <buffer> <silent> J ddp
inoremap <buffer> <expr> <cr> <SID>entry()

command! -nargs=1 MDJump call markdo#jump(<f-args>)
command! MDSearch call markdo#opensearch()
command! MDSearchWord call markdo#searchterm('word')
command! MDSearchLine call markdo#searchterm('line')
command! MDIncomplete call markdo#searchterm('!')

function! markdo#fold()
  let cur_line = getline(v:lnum)

  if cur_line =~ '^## '
    return ">1"
  endif

  if cur_line =~ '^-\+$'
    return "<1"
  endif

  return -1
endfunction

function! markdo#foldtext()
  let line = getline(v:foldstart)
  let line_text = substitute(line, '^## ', '', 'g')
  return '## '.line_text
endfunction

function! s:toggle(...)
  let line_no = line(".")
  let cur_line = getline(line("."))

  let pattern = "- \\[\\(.\\)\\] \\(.*\\)"
  let matches = matchlist(cur_line, pattern)

  if a:0 > 0
    let mark = a:1
  else
    let mark = "x"
  endif

  if len(matches) > 0
    let cur_mark = matches[1]
    let text = matches[2]

    if cur_mark == mark
      let mark = " "
    endif

    let new_line = "- [".mark."] ".text
    call setline(line_no, new_line)
  endif
endfunction

function! s:new()
  let line_no = line(".")
  call append(line_no, "")
  if getline(line_no) != ""
    call cursor(line_no + 1, 0)
    let line_no = line(".")
  endif
  call setline(line_no, "- [ ] ")
  startinsert!
endfunction

function! markdo#jump(date)
  let fmt = "+%b/%a, %d"
  let datecmd = "date --date='".a:date."' '".fmt."'"
  let [mon, day] = split(trim(system(datecmd)), '/')
  normal gg
  let @/ = mon
  normal n
  let @/ = day
  normal n
endfunction

function! markdo#searchterm(expr)
  if a:expr == 'word'
    let term = expand('<cword>')
  elseif a:expr == 'line'
    let term = '^'.split(getline(line('.')), '\[.\] ')[1].'$'
  else
    let term = a:expr
  endif
  call markdo#opensearch(term)
endfunction

function! markdo#opensearch(...)
  let term = ''
  if a:0 > 0
    let term = a:1
  endif

  let todobufname = bufname()
  let g:markdoterm = term
  let g:markdosource = todobufname
  exe "new markdosearch"
endfunction

function! markdo#week(...)
  let dowcmd = "date +%u" " Day Of Week
  let dow = str2nr(trim(system(dowcmd)))

  if a:0 > 0
    let offset = str2nr(a:1)-1
  else " Get current week
    if dow == 1
      let offset = 0
    else
      let offset = -1
    endif
  endif

  let fmt = "+%d %b %Y"
  let end = line("$")
  let days = [
    \[1, 'Mon'],
    \[2, 'Tue'],
    \[3, 'Wed'],
    \[4, 'Thu'],
    \[5, 'Fri']
  \]

  for [i, day] in days
    if i == dow
      let offset += 1
    endif
    let datecmd = "date --date='".day." ".offset." week' '".fmt."'"
    let date = trim(system(datecmd))

    if day == 'Mon'
      let startdate = date
      let weektop = line("$")
    endif

    if day == 'Fri'
      call append(weektop, "## ".startdate." - ".date)
    endif

    call append(line("$"), ["**".day.", ".date[:1]."**", ""])
  endfor
  call append(line("$"), repeat('-', &columns))

  call cursor(weektop+1, 0)
  normal zz
endfunction

function! s:entry()
  let line = getline(".")

  if line[-1:] == ':'
    return "\n    > "
  elseif line[:2] == '- ['
    return "\n- [ ] "
  else
    return "\n"
  endif
endfunction
