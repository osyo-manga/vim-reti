
function! _(...)
	return call(function("reti#lambda"), a:000)
endfunction


function! E(...)
	return call(function("reti#execute"), a:000)
endfunction


function! s:test_eval()
	Assert reti#eval("1 + 2")() == 3
	Assert reti#eval("a:1 + a:2")(1, 2) == 3
	Assert reti#eval("a:1 + 2")(1) == 3
	Assert reti#eval("a:2 / a:1")(2, 6) == 3
	Assert reti#eval("n + a:1", {"n" : 2})(1) == 3
	let n = 2
	Assert reti#eval("n + a:1", l:)(1) == 3
	Assert reti#eval("n + n2", l:, { "n2" : 1 })() == 3
endfunction


function! s:test_execute()
	let n = 2
	call reti#execute("Assert 1")()
	call reti#execute("Assert a:1 == 2")(2)
	call reti#execute("Assert a:1 == n", l:)(2)
	call reti#execute("let n += a:1", l:)(1)
	Assert n == 3
	
	call reti#execute("let n += n2", l:, {"n2" : 2})()
	Assert n == 3
	let s:x = 2
	let n = reti#lambda("a:1 + x", s:)(1)
	Assert n == 3
	call reti#execute("let x += a:1", s:)(2)
	let n = s:x
	Assert n == 4
	unlet s:x

	call E("Assert 1")()
endfunction


function! s:plus(a, b)
	return a:a + a:b
endfunction

function! s:test_script()
	let result = reti#script("s:plus")(1, 2)
	Assert result == 3
endfunction


function! s:test_operator()
	Assert  reti#operator("+")(1, 2) == 3
	Assert !reti#operator("==")(1, 2)
	Assert  reti#operator("!=")(1, 2)
	Assert  reti#operator("<")(1, 2)
	Assert  reti#operator("&&")(1, 1)
	Assert !reti#operator("&&")(1, 0)
	Assert  reti#operator("||")(1, 0)
	Assert !reti#operator("||")(0, 0)
endfunction


function! s:test_compose()
	Assert reti#compose(reti#lambda("a:1 + a:1"), reti#lambda("a:1 + a:1"))(2) == 8
	Assert reti#compose("a:1 + a:1", "a:1 + a:1")(2) == 8
	let Twice = reti#lambda("a:1 + a:1")
	Assert reti#compose(Twice, Twice, Twice)(2) == 16
	Assert reti#compose(Twice, Twice, "a:1 - 2")(4) == 8
	Assert reti#compose(Twice, "a:1 - a:2")(4, 2) == 4
endfunction


function! s:test_function()
	Assert  reti#function("sort") == function("sort")
	Assert  reti#function("s:test_function") == function("s:test_function")
	Assert  reti#function("s:plus")(1, 2) == 3
	Assert  reti#function("reti#lambda") == function("reti#lambda")
	Assert  reti#function("vimproc#system") == function("vimproc#system")
	Assert !reti#function("+")
	Assert !reti#function("a:1 + a:2")
	Assert !reti#function("sort(a:1)")
	Assert  reti#lambda("s:plus")(1, 2) == 3

	let Plus = _("+")
	Assert Plus(1, 2) == 3

	let regex = '^[a-zA-Z0-9#_:<>]\+$'
	Assert "aaaa" =~ regex
	Assert "aaa(" !~ regex
	Assert "(" !~ regex
	Assert "(aa" !~ regex
	Assert "aa11" =~ regex
	Assert "11" =~ regex
	Assert "_11" =~ regex
	Assert "aa_11" =~ regex
	Assert "aa_" =~ regex
	Assert "#_" =~ regex
	Assert "reti#sort" =~ regex
	Assert "<SNR>11_sort" =~ regex
" 	Assert "s:sort" =~ regex
" 	Assert "s:aaa" =~ '^[a-zA-Z0-9#_:]\+$'
endfunction


function! s:test_lambda()
	Assert reti#eval("1 + 2")() == 3
	Assert reti#eval("a:1 + a:2")(1, 2) == 3
	Assert reti#eval("a:1 + 2")(1) == 3

	Assert reti#lambda("+")(1, 2) == 3
	Assert reti#lambda("/")(4, 2) == 2
	Assert reti#lambda("a:1 + 2")(4) == 6

	let n = 10
	Assert reti#lambda("n + 2", l:)() == 12
	Assert reti#lambda(reti#lambda("a:1 + a:2"))(1, 2) == 3
	Assert reti#lambda(reti#script("s:plus"))(1, 2) == 3

	let Twice = reti#lambda("a:1 + a:1")
	Assert reti#lambda([Twice, Twice, Twice])(2) == 16
	call reti#function(Twice)

	Assert reti#lambda("+")(1, 2) == 3
	Assert reti#lambda("/")(4, 2) == 2
	Assert reti#lambda("a:1 + 2")(4) == 6
	Assert reti#lambda([Twice, Twice, "a:1 + 2"])(2) == 16

	Assert reti#lambda("sort")([3, 2, 1]) == [1, 2, 3]
	Assert reti#lambda(Twice)(3) == 6
	Assert reti#lambda("s:plus")(3, 2) == 5

	let sort = 10
	Assert reti#lambda("sort", l:)() == 10
	unlet sort

	Assert reti#lambda("sort(a:1)")([3, 2, 1]) == [1, 2, 3]

	Assert reti#lambda("s:plus")(3, 2) == 5
endfunction


function! s:test_Apply()
	let Assert = reti#execute("Assert a:1")
	let AssertNot = reti#execute("Assert !a:1")

	Apply "a:1 + a:2" @ 1, 2
	Apply Assert, "a:1 + a:2" @ 1, 2
	Apply AssertNot, "a:1 + a:2" @ 2, -2
	let x = 0
	let AssignX = reti#execute("let x = a:1", l:)
	Apply AssignX, "len(a:1)" @ [1, 2, 3]
	Assert x == 3

	C Assert, "a:1 + a:2" @ 1, 2
endfunction


function! s:test_map()
	Assert reti#map(reti#lambda("a:1 + 2"), [1, 2, 3]) == [3, 4, 5]
	Assert reti#map("a:1 + a:1", [1, 2, 3]) == [2, 4, 6]
	Assert reti#map(["a:1 + a:1", "a:1 - 1"], [1, 2, 3]) == [0, 2, 4]
endfunction


" call s:test_eval()
" call s:test_execute()
" call s:test_script()
" call s:test_operator()
" call s:test_compose()
" call s:test_function()
" call s:test_lambda()
" call s:test_map()
" call s:test_Apply()


function! g:test_lambda_all()
	call s:test_eval()
	call s:test_execute()
	call s:test_script()
	call s:test_operator()
	call s:test_compose()
	call s:test_function()
	call s:test_lambda()
" 	call s:test_map()
" 	call s:test_Apply()
endfunction
call g:test_lambda_all()



