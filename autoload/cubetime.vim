" TODO:
" - change functions to not use g: (capitalize instead)
" - move code into autoload

" Exit when your app has already been loaded (or "compatible" mode set)
"if exists("g:loaded_cubetime") || &cp
  "finish
"endif
"let g:loaded_cubetime = 0.0 " your version number

"let s:V = vital#of('cubetime')
"let s:L = s:V.import('Data.List')

"function g:thefunction(times)
  "let sum = s:L.foldl1('v:memo + str2float(v:val)', a:times)
  "echo 'sum: ' . sum
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
    call setline(1, "scramble: " . g:getScramble())

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

" dummy scramble data
let g:scrambles = ["D2 L' B2 L2 D2 B' D B2 U' L2 U2 R L2 U F' D B F U' D2 B2 L' D L2 B", "R2 D F2 D U' R' D' R B D R' L2 B F' L2 F2 U2 F2 D2 B' L2 R2 F' B2 D", "B2 F R' D U' B2 F U2 F B2 L2 B2 U2 F2 B' U2 F U D2 R2 B' F D B' D'", "F2 D' B F R' L B L F2 B' L F' D2 R D F L2 D2 F2 D2 F' D R B' D", "U2 F2 L' U' D R' U B R' U B R' F B2 L U2 F' L' R D B R2 L2 B2 R'", "L R U B2 F2 R' D U2 B L' U B F' D' L' U' F' D' U' L2 R B' R L' D", "D F2 B2 L R2 F D2 U2 B' U R B R' L D2 R' B2 L F' D F2 D' L' F2 L'", "U2 F D' L2 F D B' R F2 U' L D' B L' R F' B U2 D' B R2 B' D R F2", "D L R B' D' L' R' F' L2 D2 R L2 F2 D B U' B U' B' D F U2 D2 L B2", "D' B U B' R2 B L2 F2 D B2 D2 U' F R' D B2 U' D2 L U B2 F2 L U2 D'", "R' B' D B' U B' R L2 U2 B' D' B' D' F2 D2 U R F R' U' D2 L' B2 F2 R2", "B' R' F' B2 D' B R' B' R' U' B2 L D2 F2 R' B' R2 B U' D2 B' D F2 B2 L", "D R F2 R2 F U' L' R' U' R B2 D' R' D R' U2 L D' B2 U2 R' D2 R U D2", "U2 L B2 F' L2 U D F' L' D' B2 L' U2 F' L U' R B U2 L' F' D2 F' R L'", "U D' L' R' F R' D F2 D L2 F R' D B U' R D2 L2 U2 D R' F D' U' R", "R2 U' D F2 U L2 B2 R2 B L2 D F2 B' D2 R' U' R2 L D2 U B F2 U B D2", "F L' F' D' B' U' R' U' F L' R2 B D' L2 D L D' R' D2 L2 R B' L U F", "F' L2 B' U' R F2 D' R B2 F L D2 B2 D2 L D R' F D2 F2 D' U' B2 R B2", "D2 R D F' D' R' D2 R2 F' L2 D2 R2 U' B D2 R F' D' U F R L2 F R D'", "F R B' U' L2 U2 F' B2 R B U R U' R B2 R B' F2 U R U2 B D' B' L", "F R2 L' B2 L2 D R' B R2 L' U B' D B2 D' R D2 L2 F R2 B' U R2 U' D2", "F2 U2 B' U D B D2 U' R U L' R' U2 F2 U B2 D B2 R2 D F D R' D2 B2", "L' D F' U R U' R B2 U L' B U R' D2 U2 F2 D' B2 R' B' D' L R U' B'", "B U L F R' L2 D2 B D' U B R' D' U B R2 D2 L F2 U' D2 F' B R D'", "U' F L B' U F R2 U2 L R2 U2 R' U' B D2 B U2 F2 R F' D2 L' R D' F", "R2 D R2 D' L2 B2 F' U2 R2 L2 F B' D' F L2 R' F D' R D' L D2 U L2 F'", "F2 L D2 B L2 U' R2 L U D F D F U2 L R D' L' U F2 D2 L U' F L", "B' D' R' F' B2 U2 D R2 U' R' L' B2 R F2 D' B' D L' F2 D2 B' U' L2 U R2", "U2 L D' B' L U2 L B' L2 U L F U' L2 F2 R B' L' B R F2 L' F' U' F2", "B R' L2 F2 B2 U2 B' U F' B D' U F' U2 L' B2 U B R2 U D R D2 F2 U'", "B2 D2 R2 F' D R2 L2 D2 R2 B' L D' L' U' R L' F' U' B' R2 B F R' U' D", "R' B R2 F' L D' U2 R2 L U' L' D2 L' F' U F' D L' R2 B2 D' U2 F2 D' B", "U2 F R' U' L B' R' D F2 U2 R2 L B' D2 L2 R U' B2 D' R' D' R' U2 F2 D'", "B2 L R2 B2 R L' U2 F2 U L2 D2 B U B' F U' F B2 U2 R' F' D2 L' U2 B'", "F' B U' L D' U R D B2 D' R B' F L F2 B' U' L D B' D F2 L' D' U", "L F2 R F2 B2 L' R2 F' B2 R2 L2 D F2 B L2 U2 L' B2 R2 L' D L2 D' L' R", "F D' F2 D L F' L' B2 R2 F' D F R' U F' R F2 U L R B' U L B U'", "D U R' D' U' L2 D' U R B2 U' L B R2 U R F' R2 L F2 D R2 B' L2 B'", "R' F' U' D R' B D' U' F R2 D2 L2 U R' U2 F L2 B' U' D' F' L2 F B2 D", "R' U2 R L' B U2 B2 L B R' F' L2 U2 B' F' D2 L B U' B' R L' U2 B' F'", "L' R2 B D' B' F D' B D' L' D2 F' D L' F B R2 F2 U' R' F2 U B2 R2 U2", "R' B' D2 U2 B' U2 D' R2 B' R B2 D2 R' L2 U' R D' F L R2 F R D L' B2", "L R' B U R L' D R B L' D B2 D' U2 F2 B D L2 R2 U R D U R L2", "B2 U F' B2 R' B' F' R B' L F' B2 R' F D2 L' F' B L2 U' L F B' D L", "B' F2 L' F U' B L' U2 F2 U2 B2 U' B2 R' U' B L' U2 R2 F2 U2 F2 U D B2", "F' L R' U2 D' L' R' U D2 F' U2 L F B2 D2 R L2 D L R B' R' B2 L' F", "D B2 D' B' L2 D' L' D2 R' L2 U D B2 L2 B' L2 F' U L' F2 U2 L' B2 F' R2", "F' D L2 U F' D' L2 D2 F L' F L2 U2 B2 L F D' L U2 L U2 B D2 B2 F'", "B' U F2 R B2 U2 R B F2 U' B' F2 U' B' F L' U F R U' L' R2 D' U' B2", "F' U2 B' D F' L' R' U B D2 U B2 F2 L' B U2 D B2 U' L2 R' F L2 F D'", "B2 F2 D' L F R2 U D2 B2 F R2 B2 L2 U2 F2 U2 B2 D' B L B' R B2 L2 U'", "F2 U D B R B D B F U2 F' D R D' F2 R F2 U' F' U D' F2 L' F U'", "B' R2 L U2 B2 L U' F' L' R F D2 L' D2 R2 D B2 L U2 D2 B2 R' B2 U' F'", "F L' B' U' F' B' L' R' F2 U' R' L2 F2 U2 L2 B' F' D' R F2 U2 F2 R' F' L'", "L' R F' D' F' D2 B' U2 D B F L U' R' D2 F L B2 U2 F' L R' D F B2", "B2 D B F R' B' U' R' L2 U R L2 F2 U' R' D B' F2 D' L2 D2 L2 U' D B'", "D' L2 R D2 U' L2 F2 R2 F L2 B' R2 D2 F R F U' D R U' D R2 L U2 B2", "R' L U2 L R2 F U2 R U F' L' F' D' R2 U R F2 D' L R2 D' B' F2 L D'", "D F' D2 B2 U R' F2 D2 L' F' R2 L U' F2 L' U D' L' U2 R' B2 L B2 R2 B", "D2 F' D2 L2 U2 R L2 D L B2 R' F2 L' U2 B R D2 L R F2 U2 B F2 R' B2", "D2 R2 D L U' D B D' U' L B' L F' B U' B D' F B' R' D R D B F2", "L R' D R U2 B F' L F' L F B' D2 B2 U F' L2 U2 R' L' U F' U B' R", "R' U' R F2 B2 U2 B' U B2 D F' B' D' L2 U B2 L F L' F' L' F2 B2 L F'", "B2 D2 U' F2 D2 L U2 B2 U2 L R B L2 R' U' R' F' L' U L R2 F' L2 F U", "B R' L D2 F R2 B' L R B' D' R' U F2 R2 D2 L F B2 L F D B' F' D", "F D2 R D L2 R' B' F2 U2 D' L' R2 F' R2 D2 R' F' R' L2 F U D' L2 B D2", "D R2 L U' B2 L B R' D2 F' U2 L2 U' F B D F' R' L F2 U2 B R L' D", "L F' D B' U2 L2 U F' D' R2 B U L F' B2 U F2 U D R' F' L F2 R2 D2", "L U B2 F2 L' B2 F L2 U' B D F L' U2 R2 L2 U' D' B2 R2 B' R L' D2 B2", "F R2 B' L' F2 D2 B' D2 L R' B D' F R F B U R2 B U B2 F' D' L2 U'", "D F' B' U' R B' R2 U D2 R2 B2 D2 R2 B D B R U' L' D' R' F' L2 U' B", "F R2 D R2 L D2 L' F' B D R' D F B2 U2 B' R2 F' U2 R U2 R' B F' R", "R' U' B2 U F R' F2 R' U B F2 D' R2 F' B2 D F R2 U L2 D' B2 D F L", "U L' R B F U' D F' R L2 F' R' F' D2 U R F B D U R' B U' L' D2", "D2 R2 D' L R B' L' B D R D L U' R B' U2 F R' U F2 L' D' F2 U D'", "R' B' D R2 U L' D2 F' U' B2 D' R B2 F' D2 L F' U R2 B R2 L U B2 L2", "D' F2 R2 U2 F' R2 D' F D U2 R' F U' F' D R F' L2 R' B2 F R' D' U2 F", "U D L2 D' R' D' F' B R' F2 L' R2 U2 B U D2 L' D' B' D L F' B2 U' F2", "F' L B2 R2 B' U R' D' R' D' F L2 D' B' U' L U2 L2 B L2 F' D2 B2 D2 L", "L2 D' U' R2 B' U F2 U' R U F' L' D B2 F2 R' U R B' D' B R L U2 L'", "B F2 D' U' L' D F2 L' B' U' R D2 B2 D2 F2 R2 B D R2 U B2 F' R2 D' F'", "R' B F' D' F D R B2 F' L R2 B D2 F2 B2 L D U2 L R2 D2 L' U' D R", "B F2 L' F2 D' R2 U R L U' F' R' B' R' U2 F2 U2 F U' F2 R F' D L2 B'", "B F L R U R2 U2 F' B R D' R' D U2 B L U2 R2 L F' B R' F2 L F'", "R2 U2 B' L D' B2 F2 R2 D2 B F R2 L U' D2 L2 R' F L2 R D' L' D' L' R", "U F' L B2 D F U2 D2 B2 D2 B U' R' U2 R B' D' L F2 U B R2 F U' D", "R' L F2 U B L' R2 D2 B L D' R' D B L2 B2 L' F' U2 R2 D U B' L U'", "B' U L R2 B' D' B F D F' R' L2 F B2 L2 B' L2 D' L2 B2 R2 F U' L B2", "U' B F2 U' R' U F' U' B2 D2 B F2 R D R2 L U B' R L' B2 U2 R2 B U", "R F2 R' L' U F2 U L B R' F' D2 F R' L2 U2 B2 R' B R' F' U2 L' R B", "F2 R U' B2 F2 R F U2 F' B2 D F' L' U2 D2 L F2 B R' U2 L F2 D2 L U'", "U2 D' F2 D2 R2 F' L U D2 L' U' F U2 B' U D' L D R2 L2 U' D' B U2 B2", "L2 R F' B' L' D2 B U' D' B2 R2 F' L R F D B2 U D B D2 R2 F2 U' B", "U D' F' U L2 F R2 U' R2 U2 D' B U' L F2 R' F' R' F2 R' D' B2 L2 D2 R", "B' L D' L' R' D' F D2 L F R' B' U' L2 F' L' F2 R2 B' D L2 R2 B U D'", "R' B2 R' U2 L2 F' L U2 L U L' F R2 F U2 D' L U2 F2 L R2 D B2 F' D2", "U' R2 U L' B2 D U L2 U B' U2 D R B2 U L R D' L D' R L2 D2 F L2", "L' B U2 R' F' B' R2 L' F' L F2 B2 U2 B2 L2 B2 R D' R' F L2 F' R2 B' D", "U' L2 D' R U2 R2 D F' U' D2 L' R2 D2 R L' U' F' U' B R' U' D' B2 F U'"]
let g:scrambleIndex = 0
function! g:getScramble()
  let temp = g:scrambles[g:scrambleIndex]
  let g:scrambleIndex = (g:scrambleIndex + 1) % 99
  return temp
endfunction
