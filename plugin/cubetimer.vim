" Exit when your app has already been loaded (or "compatible" mode set)
"if exists("g:loaded_cubetime") || &cp
  "finish
"endif
"let g:loaded_cubetime = 0.0 " your version number

" cube timer plugin
let s:timerRunFlag = 0
let g:timesList = []
function! s:toggle_timer()
  if s:timerRunFlag == 0
    let s:timerRunFlag = 1
    let s:starttime = reltime()
  else
    let g:endtime = split(reltimestr(reltime(s:starttime)))[0] " split used to remove leading space, as suggested by :h
    let s:timerRunFlag = 0
    let g:timesList += [g:endtime]
    echo "time: " . g:endtime
    if len(g:timesList) >= 5
      echo "average of last 5: " . printf('%f', g:mean(s:tailList(g:timesList, 5)))
    endif
    if len(g:timesList) >= 12
      echo "average of last 12: " . printf('%f', g:mean(s:tailList(g:timesList, 12)))
    endif
    if len(g:timesList) >= 2
      echo "session mean(" . len(g:timesList) . "): " . printf('%f', g:mean(g:timesList))
    endif
  endif
endfunction

function! g:mean(timeList)
  " TODO:
    " tail 5
    " exclude best and worst
    " use vital's foldl
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
    echo remove(sortedNumList, len(a:numList) - 1)
    echo remove(sortedNumList, 0)
    return sortedNumList
endfunction

" test example
" input = [1, 3, 2, 4, 5]
" removeMaxAndMin:[ 2, 3, 4]
" mean: 3.0

nnoremap <Space><Space> :<C-u>call <SID>toggle_timer()<Cr>
