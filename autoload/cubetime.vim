" TODO:
" - change functions to not use g: (capitalize instead)
" - function to update averages once modified in buffer (abstract logic)
" - change "cubetime" buffer to variable
" - limit times to two digits

" Exit when your app has already been loaded (or "compatible" mode set)
"if exists("g:loaded_cubetime") || &cp
  "finish
"endif
"let g:loaded_cubetime = 0.0 " your version number

let s:V = vital#of('cubetime')
let g:L = s:V.import('Data.List')

let s:line_scramble = 1
let s:line_time = 3
let s:line_ao5 = 5
let s:line_bao5 = 6
let s:line_ao12 = 7
let s:line_bao12 = 8
let s:line_mean = 9
let s:line_timesList = 10

"" vital example
"function g:thefunction(times)
  "let sum = s:L.foldl1('v:memo + str2float(v:val)', a:times)
  "echon 'sum: '
  "echo sum
"endfunction

" cube timer plugin
let s:timerRunFlag = 0
let g:timesList = []
function! cubetime#toggle_timer()
  if !exists("g:timerBufferFlag") || g:timerBufferFlag == 0 || @% !=? "cubetime"
      new cubetime
      execute "normal! 7o\<esc>gg"
      let g:timerBufferFlag = 1
  endif
  " TODO: switch to cubetime window if it's already open
  " bufferTimes are times yanked from cubetime buffer. there might be a better name for this
  let bufferTimes = split(getline(10), 'times: ')
  if len(bufferTimes) > 0
    let g:timesList = split(bufferTimes[0], ' ')
  else
    let g:timesList = []
  endif

  if s:timerRunFlag == 0
    let s:timerRunFlag = 1
    let s:starttime = reltime()
    " TODO: echon is temp fix to prevent having to "press any key to continue"
    " TODO: this gets flushed on first time
    echon "timer running..."
  else
    let g:endtime = split(reltimestr(reltime(s:starttime)))[0] " split used to remove leading space, as suggested by :h
    echon g:endtime
    let s:timerRunFlag = 0
    let g:timesList += [g:endtime]
    call setline(s:line_time, "time: " . g:endtime)
    if len(g:timesList) >= 5
      call setline(s:line_ao5, "average of last 5: " . printf('%f', g:averageOfN(g:timesList, 5)))
      call setline(s:line_bao5, "best average of 5: " . printf('%f', g:bestRollingAoN(g:timesList, 5)))
    else
      call setline(s:line_ao5, "")
      call setline(s:line_bao5, "")
    endif
    if len(g:timesList) >= 12
      call setline(s:line_ao12, "average of last 12: " . printf('%f', g:averageOfN(g:timesList, 12)))
      call setline(s:line_bao12, "best average of 12: " . printf('%f', g:bestRollingAoN(g:timesList, 12)))
    else
      call setline(s:line_ao12, "")
      call setline(s:line_bao12, "")
    endif
    if len(g:timesList) >= 2
      call setline(s:line_mean, "session mean (" . len(g:timesList) . "): " . printf('%f', g:mean(g:timesList)))
    else
      call setline(s:line_mean, "")
    endif
    call setline(s:line_scramble, "scramble: " . scramble#getScramble())

    " format output of times
    " TODO: trailing " "
    let timesStr = g:L.foldl("v:memo . v:val . ' '", "", g:timesList)
    "let timesStr = ""
    "for item in g:timesList
      "" consider using commas
      "let timesStr .= item . " "
    "endfor

    call setline(s:line_timesList, "times: " . timesStr)
  endif
endfunction

function! g:mean(timeList)
  let s:sum = g:L.foldl("v:memo + str2float(v:val)", 0, a:timeList)
  return s:sum / len(a:timeList)
endfunction

function! g:averageOfN(timeList, n)
  return g:mean(g:removeMaxAndMin(s:tailList(a:timeList, a:n)))
endfunction

" List, Number => List
" Returns the last n elements of the List
function! s:tailList(list, n)
  return a:list[len(a:list) - a:n : len(a:list)]
endfunction

" mutates numList
function! g:removeMaxAndMin(numList)
    let sortedNumList = copy(a:numList)
    let sortedNumList = sort(sortedNumList)
    call remove(sortedNumList, len(a:numList) - 1)
    call remove(sortedNumList, 0)
    return sortedNumList
endfunction

function! g:bestRollingAoN(timesList, n)
  let i = a:n - 1
  let s:minAvg = 1000 " TODO: change to non-arbitrary value
  while i < len(a:timesList)
    let s:avg = g:mean(g:removeMaxAndMin(a:timesList[i - (a:n - 1) : i]))
    if s:avg < s:minAvg
      let s:minAvg = s:avg
    endif
    let i += 1
  endwhile
  return s:minAvg
endfunction

" test example
" input = [1, 3, 2, 4, 5]
" removeMaxAndMin: [2, 3, 4]
" mean: 3.0

" hack for timer suggested by wiki
autocmd CursorHold * call Timer()
function! Timer()
  if s:timerRunFlag
    call feedkeys("f\e") " QUESTION: why this?
    if bufname('') == "cubetime"
      call setline(s:line_time, "time: " . split(reltimestr(reltime(s:starttime)))[0])
    endif
  endif
endfunction
