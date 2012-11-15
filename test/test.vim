
function! _(...)
	return call(function("reti#lambda"), a:000)
endfunction


function! E(...)
	return call(function("reti#execute"), a:000)
endfunction


function! s:plus(a, b)
	return a:a + a:b
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
	Assert reti#eval("s:plus(1, 2)")() == 3
	Assert reti#lambda("s:plus(1, 2)")() == 3
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

	call reti#execute("Assert s:plus(2, -1)")()
endfunction

function! s:test_script()
	let result = reti#script("s:plus")(1, 2)
	Assert result == 3
" 	let result = _("s:plus")(1, 2)
" 	Assert result == 3
" 	let result = reti#lambda(["s:plus"])(1, 2)
" 	Assert result == 3
endfunction


function! s:test_operator()
	Assert  reti#operator("+")(1, 2) == 3
	Assert  reti#operator("-")(1, 2) == -1
	Assert !reti#operator("==")(1, 2)
	Assert  reti#operator("!=")(1, 2)
	Assert  reti#operator("<")(1, 2)
	Assert  reti#operator("&&")(1, 1)
	Assert !reti#operator("&&")(1, 0)
	Assert  reti#operator("||")(1, 0)
	Assert !reti#operator("||")(0, 0)
" 	Assert  reti#operator("+1")(2) == 3
	Assert  reti#operator("=~")('homu', 'ho.*')
	Assert !reti#operator("=~")('mado', 'ho.*')
" 	Assert  reti#operator("=~'ho.*'")('homu')
" 	Assert !reti#operator("=~'ho.*'")('mado')
	Assert  reti#lambda("+")(1, 2) == 3
	Assert !reti#lambda("==")(1, 2)
	Assert  reti#lambda("!=")(1, 2)
	Assert  reti#lambda("<")(1, 2)
	Assert  reti#lambda("&&")(1, 1)
	Assert !reti#lambda("&&")(1, 0)
	Assert  reti#lambda("||")(1, 0)
	Assert !reti#lambda("||")(0, 0)
" 	Assert  reti#lambda("+1")(2) == 3
" 	Assert  reti#lambda("-1")(2) == 1
	Assert  reti#lambda("=~")('homu', 'ho.*')
	Assert !reti#lambda("=~")('mado', 'ho.*')
" 	Assert  reti#lambda("=~'ho.*'")('homu')
" 	Assert !reti#lambda("=~'ho.*'")('mado')
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
	Assert reti#function("sort") == function("sort")
" 	echo reti#function("s:test_function") == function("s:test_function")
" 	Assert  reti#function("s:test_function") == function("s:test_function")
	Assert  reti#function("s:plus")(1, 2) == 3
	Assert  reti#function("reti#lambda") == function("reti#lambda")
	Assert  reti#function("vimproc#system") == function("vimproc#system")
	Assert !reti#function("+")
	Assert !reti#function("a:1 + a:2")
	Assert !reti#function("sort(a:1)")
	Assert  reti#lambda("s:plus")(1, 2) == 3
	Assert  reti#lambda(["s:plus"])(1, 2) == 3

" 	let Plus = _("+")
" 	Assert Plus(1, 2) == 3

" 	let regex = '^[a-zA-Z0-9#_:<>]\+$'
" 	Assert "aaaa" =~ regex
" 	Assert "aaa(" !~ regex
" 	Assert "(" !~ regex
" 	Assert "(aa" !~ regex
" 	Assert "aa11" =~ regex
" 	Assert "11" =~ regex
" 	Assert "_11" =~ regex
" 	Assert "aa_11" =~ regex
" 	Assert "aa_" =~ regex
" 	Assert "#_" =~ regex
" 	Assert "reti#sort" =~ regex
" 	Assert "<SNR>11_sort" =~ regex
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

" 	Assert reti#lambda("s:plus")(3, 2) == 5
" 	Assert reti#lambda("s:plus(3, 2)") == 5
	Assert reti#lambda("s:plus(3, a:1)")(2) == 5
	Assert reti#lambda("s:plus(a:1, a:1)")(2) == 4
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


function! s:test_max()
	Assert reti#max(1, 2) == 2
	Assert reti#max(2, 2) == 2
	Assert reti#max(-2, 2) == 2
endfunction


function! s:test_min()
	Assert reti#min(1, 2) == 1
	Assert reti#min(2, 2) == 2
	Assert reti#min(-2, 2) == -2
endfunction


function! s:test_foldl()
	Assert reti#foldl(_("/"), 64, [4, 2, 4]) == 2.0
	Assert reti#foldl(_("/"), 3, []) == 3.0
	Assert reti#foldl(_("reti#max"), 5, [1, 2, 3, 4, 5, 6]) == 6
	Assert reti#foldl(_("2 * a:1 + a:2"), 4, [1, 2, 3]) == 43
	Assert reti#foldl("/", 64, [4, 2, 4]) == 2.0
	Assert reti#foldl("/", 3, []) == 3.0
	Assert reti#foldl("reti#max", 5, [1, 2, 3, 4, 5, 6]) == 6
	Assert reti#foldl("2 * a:1 + a:2", 4, [1, 2, 3]) == 43

endfunction


function! s:test_foldl1()
	Assert reti#foldl1(_("+"), [1, 2, 3, 4]) == 10
	Assert reti#foldl1(_("/"), [64, 4, 2, 8]) == 1.0
	Assert reti#foldl1(_("/"), []) == 0
endfunction


function! s:test_fold()
	Assert reti#fold(_("/"), 64, [4, 2, 4]) == 2.0
	Assert reti#fold(_("/"), 3, []) == 3.0
	Assert reti#fold(_("reti#max"), 5, [1, 2, 3, 4, 5, 6]) == 6
	Assert reti#fold(_("2 * a:1 + a:2"), 4, [1, 2, 3]) == 43
endfunction


function! s:test_foldr()
	Assert reti#foldr(_("+"), 5, [1, 2, 3, 4]) == 15
	Assert reti#foldr(_("/"), 2, [8, 12, 24, 4]) == 8.0
	Assert reti#foldr(_("&&"), 1, [1 > 2, 3 > 2, 5 == 5]) == 0
	Assert reti#foldr(_("reti#max"), 18, [3, 6, 12, 4, 55, 11]) == 55
	Assert reti#foldr(_("reti#max"), 111, [3, 6, 12, 4, 55, 11]) == 111
	Assert reti#foldr(_("(a:1 + a:2) / 2"), 54, [12, 4, 10, 6]) == 12.0
endfunction


function! s:test_foldr1()
	Assert reti#foldr1("+", [1, 2, 3, 4]) == 10
	Assert reti#foldr1("/", [8, 12, 24, 4]) == 4.0
	Assert reti#foldr1("(a:1 + a:2) / 2", [12, 4, 10, 6]) == 9.0
	Assert reti#foldr1("0", []) == 0
endfunction


function! s:test_lambda_cache()
	Assert reti#lambda("+") is reti#lambda("+")
	Assert reti#lambda("+") isnot reti#lambda("-")
	Assert reti#lambda("a:1+a:2") is reti#lambda("+")
	Assert reti#lambda("a:1 + a:2") isnot reti#lambda("+")
	Assert reti#lambda("+", l:) is reti#lambda("+")
	Assert reti#lambda("n", l:) isnot reti#lambda("n", l:)
endfunction


function! s:test_dict_func()
	let dict = {}
	function! dict.apply()
		return "homu"
	endfunction

	Assert reti#dict_func(dict)() == "homu"
	Assert reti#lambda(dict)() == "homu"

	function! dict.func2(...)
		return a:1
	endfunction
	Assert reti#dict_func(dict, "func2")("saya") == "saya"
endfunction


function! g:test_lambda_all()
	call s:test_eval()
	call s:test_execute()
	call s:test_script()
	call s:test_operator()
	call s:test_compose()
	call s:test_function()
	call s:test_lambda()
" 	call s:test_Apply()
	call s:test_max()
	call s:test_min()
	call s:test_foldl()
	call s:test_fold()
	call s:test_foldr()
	call s:test_foldl1()
	call s:test_foldr1()
	call s:test_map()
	call s:test_lambda_cache()
	call s:test_dict_func()
endfunction
" call g:test_lambda_all()


