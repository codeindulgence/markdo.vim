setlocal buftype=nofile
setlocal bufhidden=wipe
setlocal noswapfile
setlocal nobuflisted
setlocal filetype=markdown
setlocal nonumber
setlocal norelativenumber
setlocal signcolumn=no
setlocal nospell

inoremap <buffer> <silent> <cr> <Esc>:call markdosearch#term()<CR>
vnoremap <buffer> <silent> j :call <SID>next()<CR>
vnoremap <buffer> <silent> k :call <SID>prev()<CR>
vnoremap <buffer> <silent> / :call markdosearch#prompt()<CR>
nnoremap <buffer> <silent> / :call markdosearch#prompt()<CR>

function! markdosearch#prompt()
  let searchline = getline(1)
  echom "Line: " . searchline
  call cursor(1, 9)
  if searchline == "Search: "
    startinsert!
  else
    normal v$
  endif
endfunction

function! markdosearch#term()
  let term = getline(1)[8:]
  echom "Term: " . term
  call s:results(term)
  return ""
endfunction

function! s:select(result)
  let s:selected = a:result
  call cursor(a:result+2, 1)
  normal V
endfunction

function! s:next()
  call s:select(s:selected+1)
endfunction

function! s:prev()
  call s:select(s:selected-1)
endfunction

function! s:results(term)
  if !exists('s:todolines')
    let s:todolines = getbufline(bufnr(b:markdosource), 1, "$")
  endif

  call deletebufline("markdosearch", 3, "$")
  let numresults = 0
  for line in s:todolines
    if line[:2] == "## "
      let l:date = line[3:]
    endif

    if line[:1] == "**"
      let l:day = line[2:4]
    endif

    if line[:2] == "- ["
      let mark = line[2:5]
      let entry = line[6:]
      if match(entry, a:term) > 0
        call append(line("$"), date.", ".day.": ".mark.entry)
        let numresults += 1
      endif
    endif
  endfor
  call append(line("$"), ["", "Results: " . numresults])

  if numresults > 0
    call s:select(1)
  endif
endfunction

call setline(1, "Search: ")
call append(1, repeat('-', 80))
call markdosearch#prompt()
