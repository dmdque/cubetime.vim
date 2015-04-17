nnoremap <Space><Space> :<C-u>call cubetime#toggle_timer()<Cr>
nnoremap <Space>l :<C-u>echo g:cubetime#timesList<Cr>

" QUESTION: is there a way to do this with s: instead of g:?
" <SID>
nnoremap <Space>s :<C-u>echo cubetime#scramble#getScramble()<Cr>

augroup cubetime-timer
  autocmd!
  " hack for timer suggested by wiki
  autocmd CursorHold * call cubetime#timer()
augroup END
