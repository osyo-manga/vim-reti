
let s:just = 1
let s:nothing = { "tag" : !s:just }
function! s:nothing.bind(func)
	return self
endfunction


function! s:return(value)
	let maybe = { "value" : a:value, "tag" : s:just }
	function! maybe.bind(func)
		return s:bind(self, a:func)
	endfunction
	return maybe
endfunction


function! s:bind(m, func)
	return a:m.tag == s:just ? reti#lambda(a:func)(a:m.value) : s:nothing
endfunction


" Maybeモナドを返す関数
function! s:div(a, b)
	return a:b ? s:return(a:a / a:b) : s:nothing
endfunction


function! s:sqrt(x)
	if a:x < 0
		return s:nothing
	endif
	let i = 0
	while i * i <= a:x
		let i += 1
	endwhile
	return s:return(i - 1)
endfunction


function! s:find_if(cond, seq)
	let Cond = reti#lambda(a:cond)
	for n in a:seq
		if Cond(n)
			return s:return(n)
		endif
	endfor
	return s:nothing
endfunction


" Maybeモナドの出力
function! s:print(m)
	if a:m.tag == s:just
		echo a:m.value
	else
		echo "Nothing"
	endif
endfunction


function! s:main()
	call s:print( s:find_if("a:1>=4", [1, 2, 3, 4]) )
	" => 4

	call s:print( s:find_if("a:1>=4", [0, 1, 2, 3]) )
	" => Nothing

	call s:print( s:bind(s:find_if("a:1>=4", [1, 2, 3, 4]), "s:sqrt") )
	" => 2

	call s:print( s:find_if("a:1>=4", [1, 2, 3, 4]).bind("s:div(24, a:1)") )
	" => 6

	call s:print( s:find_if("a:1>=4", [1, 2, 3, 4]).bind("s:div(100, a:1)").bind("s:sqrt") )
	" => 5

	call s:print( s:find_if("a:1>=5", [1, 2, 3, 4]).bind("s:div(100, a:1)").bind("s:sqrt") )
	" => Nothing

	call s:print( s:find_if("a:1>=4", [1, 2, 3, 4]).bind(["s:return", "a:1 + a:1"]) )
	" => 8

	call s:print( s:find_if("a:1>=5", [1, 2, 3, 4]).bind(["s:return", "a:1 + a:1"]) )
	" => Nothing
	
endfunction
call s:main()


