
function! s:map(f, seq)
	let result = []
	for n in a:seq
		call add(result, a:f(n))
	endfor
	return result
endfunction


call s:map(reti#execute("echo a:1"), ["homu", "mami", "mado"])
" => homu
" => mami
" => mado

let s:sum = 0
call s:map(reti#execute("let sum += a:1", s:), range(10))
echo s:sum
" => 45




