let s:save_cpo = &cpo
set cpo&vim
scriptencoding utf-8


function! s:SID()
	return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfunction


let s:lambda_counter = 0
let s:lambda_capture = {}
let s:lambda_cache = {}


function! s:capture(l, captures)
	for list in a:captures
		call extend(a:l, list)
	endfor
endfunction



function! reti#execute(expr, ...)
	if has_key(s:lambda_cache, a:expr) && !a:0
		return s:lambda_cache[a:expr]
	endif
	let name = "s:lambda_".s:lambda_counter
	let s:lambda_capture[name] = a:000
	execute join([
\		"function! ".name."(...)",
\			"call s:capture(l:, s:lambda_capture[".string(name)."])",
\			"execute ".string(a:expr),
\			"if len(s:lambda_capture[".string(name)."]) == 1",
\			"	call extend(s:lambda_capture[".string(name)."][0], l:)",
\			"endif",
\		"endfunction",
\	], "\n")
	let s:lambda_counter += 1
	if a:0
		return function(substitute(name, "s:", "<SNR>" . s:SID() . "_", "g"))
	else
		let s:lambda_cache[a:expr] = function(substitute(name, "s:", "<SNR>" . s:SID() . "_", "g"))
		return s:lambda_cache[a:expr]
	endif
endfunction


function! reti#eval(expr, ...)
	return call(function("reti#execute"), ["return ".a:expr] + a:000)
endfunction


function! s:SCaller(...)
	try
		throw 'abc'
	catch /^abc$/
		if a:0
			let prefunc = a:1
			let result = matchstr(v:throwpoint, '^.*\.\.\zs.*\ze\.\.'.prefunc)
			if empty(result)
				let result = matchstr(v:throwpoint, '^function \zs.*\ze\.\.'.prefunc)
			endif
			return result
		else
			return matchstr(v:throwpoint, '^function \zs.\{-}\ze\.\.')
		endif
	endtry
endfunction


function! reti#script(expr)
	let SID = matchstr(s:SCaller("reti#script"), '\zs<SNR>\d*_\ze.*')
	let expr = substitute(a:expr, "s:", SID, "g")
	return function(expr)
endfunction


" let s:operator_list = [
" \	"+", "-", "*", "/", "%", ".",
" \	"==", "==#", "==?",
" \	"!=", "!=#", "!=?",
" \	">",  ">#",  ">?",
" \	">=", ">=#", ">=?",
" \	"<",  "<#",  "<?",
" \	"<=", "<=#", "<=?",
" \	"=~", "=~#", "=~?",
" \	"!~", "!~#", "!~?",
" \	"is", "is#", "is?",
" \	"isnot", "isnot#", "isnot?",
" \	"||", "&&",
" \]

let s:operator_list = [
\   '^\s*\(+\)\(.*\)',
\   '^\s*\(-\)\(.*\)',
\   '^\s*\(*\)\(.*\)',
\   '^\s*\(/\)\(.*\)',
\   '^\s*\(%\)\(.*\)',
\   '^\s*\(\.\)\(.*\)',
\   '^\s*\(==#\)\(.*\)',
\   '^\s*\(==?\)\(.*\)',
\   '^\s*\(==\)\(.*\)',
\   '^\s*\(!=#\)\(.*\)',
\   '^\s*\(!=?\)\(.*\)',
\   '^\s*\(!=\)\(.*\)',
\   '^\s*\(>=#\)\(.*\)',
\   '^\s*\(>=?\)\(.*\)',
\   '^\s*\(>=\)\(.*\)',
\   '^\s*\(>#\)\(.*\)',
\   '^\s*\(>?\)\(.*\)',
\   '^\s*\(>\)\(.*\)',
\   '^\s*\(<\)\(.*\)',
\   '^\s*\(<#\)\(.*\)',
\   '^\s*\(<?\)\(.*\)',
\   '^\s*\(<=\)\(.*\)',
\   '^\s*\(<=#\)\(.*\)',
\   '^\s*\(<=?\)\(.*\)',
\   '^\s*\(=\~#\)\(.*\)',
\   '^\s*\(=\~?\)\(.*\)',
\   '^\s*\(=\~\)\(.*\)',
\   '^\s*\(\!\~\)\(.*\)',
\   '^\s*\(\!\~#\)\(.*\)',
\   '^\s*\(\!\~?\)\(.*\)',
\   '^\s*\(is#\)\(.*\)',
\   '^\s*\(is?\)\(.*\)',
\   '^\s*\(is\)\(.*\)',
\   '^\s*\(isnot#\)\(.*\)',
\   '^\s*\(isnot?\)\(.*\)',
\   '^\s*\(isnot\)\(.*\)',
\   '^\s*\(||\)\(.*\)',
\   '^\s*\(&&\)\(.*\)'
\]


function! s:is_operator(str)
	for op in reverse(s:operator_list)
		if a:str =~ op
			return 1
		endif
	endfor
	return 0
endfunction

function! s:test_is_operator()
	Assert  s:is_operator("+")
	Assert  s:is_operator("==")
	Assert  s:is_operator(".")
	Assert !s:is_operator("$")
	Assert !s:is_operator("#")
	Assert  s:is_operator("!~")
	Assert  s:is_operator("=~")
	Assert !s:is_operator("i")
	Assert !s:is_operator("homu")
	Assert  s:is_operator("+1")
	Assert  s:is_operator("++")
	Assert  s:is_operator("+homu")
	Assert !s:is_operator("homu+homu")
endfunction


function! s:to_operator_expr(str)
	let regex = '\([+-/*%.=~!?|&#<>\(is\)\(isnot\)]\+\)\(.*\)'
	return substitute(a:str, regex, '\=empty(submatch(2)) ? "a:1".submatch(1)."a:2" : "a:1".submatch(1).submatch(2)', "g")
endfunction

function! s:test_to_operator_expr()
	Assert s:to_operator_expr("+1") == "a:1+1"
	Assert s:to_operator_expr("+'homu'") == "a:1+'homu'"
	Assert s:to_operator_expr("+") == "a:1+a:2"
	Assert s:to_operator_expr("=~") == "a:1=~a:2"
	Assert s:to_operator_expr("isnot") == "a:1isnota:2"
	Assert s:to_operator_expr("isnot#") == "a:1isnot#a:2"
	Assert s:to_operator_expr("isnot?") == "a:1isnot?a:2"
	Assert s:to_operator_expr("isnot'is'") == "a:1isnot'is'"
	Assert s:to_operator_expr("isnot is") == "a:1isnot is"
endfunction


function! reti#operator(op)
	return reti#eval(s:to_operator_expr(a:op))
endfunction


function! reti#compose(expr1, expr2, ...)
	let F1 = reti#lambda(a:expr1)
	let F2 = a:0 ? call (function("reti#compose"), [a:expr2] + a:000) : reti#lambda(a:expr2)
	return reti#eval("F1(call(F2, a:000))", l:)
endfunction


function! reti#function(name, ...)
	let prev = a:0 ? a:1 : "reti#function"
	try
		if type(a:name) == type(function("tr"))
			return a:name
		endif
		let SID = matchstr(s:SCaller(prev), '\zs<SNR>\d*_\ze.*')
		let name = substitute(a:name, "s:", SID, "g")
		return name =~ '^[a-zA-Z0-9#_:<>]\+$' && exists("*".name) ? function(name) : 0
	catch
		return 0
	endtry
endfunction


function! reti#lambda(expr, ...)
	if type(a:expr) == type("") && has_key(s:lambda_cache, a:expr) && !a:0
		return s:lambda_cache[a:expr]
	endif
	let Func = a:0 ? 0 : reti#function(a:expr, "reti#lambda")
	return type(Func) == type(function("tr")) ? Func
\		 : type(a:expr) == type([]) && len(a:expr) == 1 ? call(function("reti#lambda"), a:expr + a:000)
\		 : type(a:expr) == type([]) ? call(function("reti#compose"), a:expr)
\		 : s:is_operator(a:expr) ? reti#operator(a:expr)
\		 : call(function("reti#eval"), [a:expr] + a:000)
endfunction


function! reti#curry(func)
	return reti#lambda('reti#lambda("call('.string(a:func).', [".string(a:1)."] + a:000)")')
endfunction



function! reti#max(a, b)
	return a:a > a:b ? a:a : a:b
endfunction


function! reti#min(a, b)
	return a:a > a:b ? a:b : a:a
endfunction




function! reti#foldl(func, value, seq)
	let Func = reti#lambda(a:func)
	let result = a:value
	for n in a:seq
		let result = Func(result, n)
	endfor
	return result
endfunction



function! reti#fold(...)
	return call("reti#foldl", a:000)
endfunction



function! reti#foldr(func, value, seq)
	let Func = reti#lambda(a:func)
	let result = a:value
	for n in reverse(a:seq)
		let result = Func(n, result)
	endfor
	return result
endfunction


function! s:default_constructor(type)
	return a:type == type(0)   ? 0
\		 : a:type == type("")  ? ""
\		 : a:type == type([])  ? []
\		 : a:type == type({})  ? {}
\		 : a:type == type(0.0) ? 0.0
\		 : -1
endfunction

function! s:test_default_constructor()
	Assert s:default_constructor(type(12)) == 0
	Assert s:default_constructor(type("homu")) == ""
	Assert s:default_constructor(type(range(3))) == []
	Assert s:default_constructor(type(range(3)[0])) == 0
	Assert s:default_constructor(type({"homu" : 1})) == {}
	Assert s:default_constructor(type(function("s:test_default_constructor"))) == -1
endfunction


function! reti#foldl1(func, seq)
	return reti#foldl(a:func, get(a:seq, 0), a:seq[1:])
endfunction


function! reti#foldr1(func, seq)
	return reti#foldr(a:func, get(a:seq, -1), a:seq[0:-2])
endfunction


function! reti#map(f, seq)
	let F = reti#lambda(a:f)
	return reti#fold(reti#lambda("add(a:1, F(a:2))", l:), [], a:seq)
" 	let result = []
" 	for n in a:seq
" 		call add(result, a:f(n))
" 	endfor
" 	return result
endfunction





let cpo = s:save_cpo
unlet s:save_cpo
