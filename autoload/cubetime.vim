" TODO:
" - change functions to not use g: (capitalize instead)
" - move code into autoload

" Exit when your app has already been loaded (or "compatible" mode set)
"if exists("g:loaded_cubetime") || &cp
  "finish
"endif
"let g:loaded_cubetime = 0.0 " your version number

let s:V = vital#of('cubetime')
let s:L = s:V.import('Data.List')

" vital example
function g:thefunction(times)
  let sum = s:L.foldl1('v:memo + str2float(v:val)', a:times)
  echon 'sum: '
  echo sum
endfunction

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
  let bufferTimes = split(getline(8), 'times: ')
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
    echo g:endtime
    let s:timerRunFlag = 0
    let g:timesList += [g:endtime]
    call setline(3, "time: " . g:endtime)
    if len(g:timesList) >= 5
      call setline(5, "average of last 5: " . printf('%f', g:mean(g:removeMaxAndMin(s:tailList(g:timesList, 5)))))
    else
      call setline(5, "")
    endif
    if len(g:timesList) >= 12
      call setline(6, "average of last 12: " . printf('%f', g:mean(g:removeMaxAndMin(s:tailList(g:timesList, 12)))))
    else
      call setline(6, "")
    endif
    if len(g:timesList) >= 2
      call setline(7, "session mean (" . len(g:timesList) . "): " . printf('%f', g:mean(g:timesList)))
    else
      call setline(7, "")
    endif
    call setline(1, "scramble: " . scramble#getScramble())

    " format output of times
    " TODO: replace this with vital.vim fold
    let timesStr = ""
    for item in g:timesList
      " consider using commas
      let timesStr .= item . " "
    endfor

    call setline(8, "times: " . timesStr)
  endif
endfunction

function! g:mean(timeList)
  " TODO: use vital's foldl
  let s:sum = 0
  for item in a:timeList
    let s:sum = s:sum + str2float(item)
  endfor
  return s:sum / len(a:timeList)
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


function! s:bestRollingAo5(timesList)
endfunction

" test example
" input = [1, 3, 2, 4, 5]
" removeMaxAndMin:[ 2, 3, 4]
" mean: 3.0
