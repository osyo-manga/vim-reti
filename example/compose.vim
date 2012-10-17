" 関数合成


function! s:main()
	let Front  = reti#lambda("get(a:1, 0)")
	let Twice  = reti#lambda("a:1 + a:1")
	let Sort   = reti#lambda("sort")
	let Output = reti#execute("echo a:1")

	let Func = reti#lambda([Output, Twice, Front, Sort])
	call Func([8, 6, 4, 7])
endfunction
call s:main()


