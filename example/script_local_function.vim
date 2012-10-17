" スクリプトローカル関数の処理

function! s:plus(a, b)
	return a:a + a:b
endfunction

" 関数以外のスコープでは使用できない
" let s:Plus = reti#lambda("s:plus")
" echo s:Plus(1, 2)

function! s:main()
	let Plus = reti#lambda("s:plus")
	echo Plus
	" => <SNR>319_plus
	echo Plus(1, 2)
	" => 3
endfunction
call s:main()


