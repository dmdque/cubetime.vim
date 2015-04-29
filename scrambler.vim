let s:V = vital#of('vital')
let s:Random = s:V.import('Random')

let g:faces = ["U", "L", "F", "R", "B", "D"]
let g:modifiers = ["", "'", "2"]

" scratchpad
"U", "U'", "U2"
"L", "L'", "L2"
"F", "F'", "F2"
"R", "R'", "R2"
"B", "B'", "B2"
"D", "D'", "D2"

" don't allow repetitions or slices
function! ValidMoves(lastMove)
  if a:lastMove == "U" || a:lastMove == "D"
    return ["L", "F", "R", "B"]
  elseif a:lastMove == "L" || a:lastMove == "R"
    return ["U", "F", "B", "D"]
  elseif a:lastMove == "F" || a:lastMove == "B"
    return ["U", "L", "R", "D"]
  else
    return ["U", "L", "F", "R", "B", "D"]
  endif
endfunction

" returns a randomized valid move
function! GenerateMove(lastMove)
  if a:lastMove == ""
    let i = s:Random.sample(range(6))
    return ValidMoves(a:lastMove)[i]
  else
    let i = s:Random.sample(range(4))
    return ValidMoves(a:lastMove)[i]
  endif
endfunction

function! GenerateModifier()
    return s:Random.sample(g:modifiers)
endfunction

function! Main()
  let s:lastMove = ""
  let s:scramble = []
  for item in range(25)
    let s:lastMove = GenerateMove(s:lastMove)
    let s:scramble += [s:lastMove . GenerateModifier()]
  endfor
  return s:scramble
endfunction

" unused function
function! MapMoves(move)
    if a:move == "U"
        return 0
    elseif a:move == "L"
        return 1
    elseif a:move == "F"
        return 2
    elseif a:move == "R"
        return 3
    elseif a:move == "B"
        return 4
    elseif a:move == "D"
        return 5
    endif
endfunction

function! PrintScramble()
    let s:myscramble = Main()
    for item in s:myscramble
        echon item . " "
    endfor
endfunction

call PrintScramble()
