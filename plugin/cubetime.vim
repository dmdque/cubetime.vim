nnoremap <Space><Space> :<C-u>call cubetime#toggle_timer()<Cr>
nnoremap <Space>l :<C-u>echo g:timesList<Cr>

" QUESTION: is there a way to do this with s: instead of g:?
" <SID>
nnoremap <Space>s :<C-u>echo cubetime#scramble#getScramble()<Cr>
