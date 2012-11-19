
function! s:make_counter()
	let n = 0
	return reti#execute("let n += 1 | return n", l:)
endfunction

let s:counter = s:make_counter()
echo s:counter()
" => 1
echo s:counter()
" => 2
echo s:counter()
" => 3
echo s:counter()
" => 4


