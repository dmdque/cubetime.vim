" NOTE: vars are g: for debugging
" Exit when your app has already been loaded (or "compatible" mode set)
if exists("g:loaded_cubetime") || &cp
  finish
endif
let g:loaded_cubetime = 0.0 " your version number

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
    echo "time: " . g:endtime . ", mean of " . len(g:timesList) . ": " . printf('%f', g:ao5(g:timesList))

  endif
endfunction

function! g:ao5(timeList)
  " TODO:
    " tail 5
    " exclude best and worst
    " use vital's foldl
  let s:sum = 0.0
  for item in a:timeList
    let s:sum = s:sum + str2float(item)
  endfor
  return s:sum / len(a:timeList)
endfunction

nnoremap <Space><Space> :<C-u>call <SID>toggle_timer()<Cr>
