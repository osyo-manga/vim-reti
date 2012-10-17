
function! s:foldl(func, value, seq)
	let result = a:value
	for n in a:seq
		let result = a:func(result, n)
	endfor
	return result
endfunction


function! s:foldr(func, value, seq)
	let result = a:value
	for n in reverse(a:seq)
		let result = a:func(n, result)
	endfor
	return result
endfunction


echo s:foldl(reti#lambda("a:1 - a:2"), 0, range(10))
" => -45

echo s:foldl(reti#lambda("a:1 / a:2"), 64, [4, 2, 4])
" => 2

echo s:foldr(reti#lambda("a:1 / a:2"), 2, [8, 12, 24, 4])
" => 8

echo s:foldr(reti#lambda("a:1 + a:2"), 5, range(5))
" => 15


