setlocal buftype=nofile
setlocal bufhidden=wipe
setlocal noswapfile
setlocal nobuflisted
setlocal filetype=markdown
setlocal nonumber
setlocal norelativenumber
setlocal signcolumn=no
setlocal nospell
setlocal colorcolumn=0

syntax match todoResIdx /\d\+)/
syntax match todoSelect /^>/
syntax match todoRef /@[a-z]\+/
syntax match todoTime /\d\d:\d\d-\d\d:\d\d/
syntax match todoTag /#[a-z-]\+/
syntax match todoItem /\[ \].*/ contains=todoTag,todoRef,todoTime
syntax match todoNew /\[N\].*/ contains=todoTag,todoRef,todoTime
syntax match todoDone /\[x\].*/ contains=todoTag,todoRef,todoTime
syntax match todoStarted /\[-\].*/ contains=todoTag,todoRef,todoTime
syntax match todoBlocked /\[B\].*/ contains=todoTag,todoRef,todoTime
syntax region todoResult start=/\d)/ end=/$/ contains=todoResIdx,todoNew,todoDone,todoStarted,todoBlocked,todoItem

highlight default link todoResIdx Keyword
highlight default link todoSelect String
highlight default link todoResult Comment
highlight default link todoItem Normal
highlight default link todoStarted Tag
highlight default link todoDone Comment
highlight default link todoNew String
highlight default link todoBlocked Exception
highlight default link todoTag Function

inoremap <buffer> <silent> <CR> <Esc>:call markdosearch#term()<CR>
nnoremap <buffer> <silent> j :call <SID>next()<CR>
nnoremap <buffer> <silent> k :call <SID>prev()<CR>
nnoremap <buffer> <silent> / :call markdosearch#prompt()<CR>
nnoremap <buffer> <silent> <CR> :call markdosearch#go()<CR>
nnoremap <buffer> q :q<CR>
nnoremap <buffer> <Esc> :q<CR>
nnoremap <buffer> <C-c> :q<CR>

function! markdosearch#prompt()
  let searchline = getline(2)
  call cursor(2, 9)
  if searchline == "Search: "
    startinsert!
  elseif searchline == "Incomplete Tasks"
    call setline(2, 'Search: ')
    startinsert!
  else
    normal v$
  endif
endfunction

function! markdosearch#term()
  let term = getline(2)[8:]
  call s:results(term)
endfunction

function! markdosearch#go()
  unlet s:showing
  quit
  match
  call cursor(s:resultline, 7)
  return
endfunction

function! s:show()
  let s:resultline = s:resultsmap[s:selected]
  let s:showing = s:selected
  wincmd k
  call cursor(s:resultline, 7)
  execute 'match Search /\%'.s:resultline.'l/'
  normal zo
  wincmd j
endfunction

function! s:select(result)
  let s:selected = a:result
  call s:show()
  for x in range(1, s:count)
    let lnum = x+6
    if x == a:result
      call setline(lnum, '>'.getline(lnum)[1:])
    else
      call setline(lnum, ' '.getline(lnum)[1:])
    endif
  endfor
  if a:result+9 > getpos(".")[1]+winheight(".")
    normal 
  endif
  if a:result+7 < getpos(".")[1]
    normal 
  endif
endfunction

function! s:next()
  if s:selected < s:count
    call s:select(s:selected+1)
  endif
endfunction

function! s:prev()
  if s:selected > 1
    call s:select(s:selected-1)
  endif
endfunction

function! s:incomplete(lines)
  let sourceline = 0
  let entries = {}

  call setline(2, "Incomplete Tasks")

  for line in a:lines
    let sourceline += 1
    if line[:2] == '- ['
      let entry = line[6:]
      let mark = line[3]
      if mark == 'x'
        if has_key(entries, entry)
          unlet entries[entry]
        endif
      else
        let entries[entry] = [mark, sourceline]
      endif
    endif
  endfor

  let s:count = 0
  let s:resultsmap = {}
  for entry in keys(entries)
    let s:count += 1
    let [_, sourceline] = entries[entry]
    let s:resultsmap[s:count] = sourceline
    let result = printf("  %02d) %s", s:count, entry)

    call append(line("$"), result)
  endfor

  call append(3, ["", "Results: ".s:count])

  if s:count > 0
    call s:select(1)
  endif
endfunction

function! s:results(term)
  call cursor(2, 1)
  let s:todolines = getbufline(bufnr(g:markdosource), 1, "$")

  call deletebufline("markdosearch", 5, "$")

  if a:term == '!'
    return s:incomplete(s:todolines)
  endif

  let s:count = 0
  let s:sourceline = 0
  let s:resultsmap = {}
  let terms = split(a:term)

  for line in s:todolines
    let s:sourceline += 1

    if line[:2] == "## "
      let dates = split(line[3:], ' - ')
      let from_d = split(dates[0])[0]
      let to_d = split(dates[1])[0]
      let from_m = split(dates[0])[1]
      let to_m = split(dates[1])[1]
      let from_y = split(dates[0])[2]
      let to_y = split(dates[1])[2]
    endif

    if line[:1] == "**"
      let day = line[2:4]
      let date = line[7:8]
    endif

    if line[:2] == "- ["
      let mark = line[2:5]
      let entry = line[6:]
      let matches = []

      for term in terms
        if len(term) == 2 && term[0] == "="
          let markterm = term[1]
          if mark[1] == markterm
            call add(matches, v:true)
          else
            call add(matches, v:false)
          endif
          continue
        endif

        if match(entry, term) >= 0
          call add(matches, v:true)
        else
          call add(matches, v:false)
        endif
      endfor

      if uniq(sort(matches)) == [v:true]
        let s:count += 1
        let s:resultsmap[s:count] = s:sourceline

        if date < from_d
          let full_date = date." ".to_m." ".to_y
        else
          let full_date = date." ".from_m." ".from_y
        endif

        let result = printf("  %02d) %s: %s", s:count, full_date, mark.entry)

        call append(line("$"), result)
      endif
    endif
  endfor
  call append(3, ["", "Results: ".s:count])

  if s:count > 0
    call s:select(1)
  endif
endfunction

call append(0, [
  \repeat('-', &columns),
  \"Search: ".g:markdoterm,
  \repeat('-', &columns)
\])

if g:markdoterm == ''
  call markdosearch#prompt()
else
  call s:results(g:markdoterm)
end
