setlocal buftype=nofile
setlocal bufhidden=wipe
setlocal noswapfile
setlocal nobuflisted
setlocal filetype=markdown
inoremap <buffer> <silent> <cr> <Esc>:call markdosearch#term()<CR>A

call setline(1, "Search: ")
startinsert!
call append(1, repeat('-', 80))

function! markdosearch#term()
  let term = getline(1)[8:]
  echom "Term: " . term
  call s:results(term)
  return ""
endfunction

function! s:results(term)
  if !exists('s:todolines')
    let s:todolines = getbufline(bufnr(b:markdosource), 1, "$")
  endif

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

