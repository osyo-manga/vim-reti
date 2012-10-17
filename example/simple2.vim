" example http://yuroyoro.hatenablog.com/entry/20120203/1328248662

function! s:main()
	let Unlines = reti#lambda('join(a:1, "\n")')
	echo Unlines([1, 2, 3])

	let Lines = reti#lambda('split(a:1, "\n")')
	echo Lines("1\n2\n3\n")
	
	let PutStr = reti#execute("echo a:1")
	call PutStr("homu")
	
	let src = join([
\		"mado",
\		"homu",
\		"mami",
\		"saya",
\		"an",
\	], "\n")

" 	call PutStr( Unlines( sort( Lines(src) ) ) )
	call reti#lambda([PutStr, Unlines, "sort", Lines])(src)

endfunction
call s:main()


