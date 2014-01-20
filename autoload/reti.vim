let s:save_cpo = &cpo
set cpo&vim
scriptencoding utf-8


function! s:SID()
	return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfunction


let s:lambda_template = join(readfile(expand("<sfile>:p:h") . "/reti/lambda_template.txt"), "\n")


function! s:gen_lambda(name, expr)
	return printf(s:lambda_template, a:name, a:name, a:name, a:name, a:expr, a:name, a:name, a:name)
endfunction



let s:lambda_counter = 0
let s:lambda_capture = {}
let s:lambda_cache = {}
let s:lambda_expr_cache = {}


function! s:capture(l, captures)
	for list in a:captures
		call extend(a:l.local, list)
	endfor
endfunction



function! reti#execute(expr, ...)
	let expr = chained#script_function_to_function_symbol(a:expr, chained#to_SNR(chained#latest_called_script_function()))
	if has_key(s:lambda_cache, expr) && !a:0
		return s:lambda_cache[expr]
	endif
	let name = "<SNR>" . s:SID() . "_lambda_".s:lambda_counter
	let name_str = string(name)
	let s:lambda_capture[name] = a:000
	execute s:gen_lambda(name, expr)
	let s:lambda_counter += 1
	if a:0
		return function(name)
	else
		let s:lambda_cache[expr] = function(name)
		let s:lambda_expr_cache[name] = expr
		return s:lambda_cache[expr]
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
" 			echo reverse(split(v:throwpoint, '\.\.')[ : -2])
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

function! s:to_script_function(name, prev)
	return substitute(a:name, "s:", matchstr(s:SCaller(a:prev), '\zs<SNR>\d*_\ze.*'), "g")
endfunction


function! reti#script(expr)
	return function(s:to_script_function(a:expr, "reti#script"))
endfunction


let s:operator_list = [
\	"+", "-", "*", "/", "%", ".",
\	"==", "==#", "==?",
\	"!=", "!=#", "!=?",
\	">",  ">#",  ">?",
\	">=", ">=#", ">=?",
\	"<",  "<#",  "<?",
\	"<=", "<=#", "<=?",
\	"=~", "=~#", "=~?",
\	"!~", "!~#", "!~?",
\	"is", "is#", "is?",
\	"isnot", "isnot#", "isnot?",
\	"||", "&&",
\]

" let s:operator_list = [
" \   '^\s*\(+\)\(.*\)',
" \   '^\s*\(-\)\(.*\)',
" \   '^\s*\(*\)\(.*\)',
" \   '^\s*\(/\)\(.*\)',
" \   '^\s*\(%\)\(.*\)',
" \   '^\s*\(\.\)\(.*\)',
" \   '^\s*\(==#\)\(.*\)',
" \   '^\s*\(==?\)\(.*\)',
" \   '^\s*\(==\)\(.*\)',
" \   '^\s*\(!=#\)\(.*\)',
" \   '^\s*\(!=?\)\(.*\)',
" \   '^\s*\(!=\)\(.*\)',
" \   '^\s*\(>=#\)\(.*\)',
" \   '^\s*\(>=?\)\(.*\)',
" \   '^\s*\(>=\)\(.*\)',
" \   '^\s*\(>#\)\(.*\)',
" \   '^\s*\(>?\)\(.*\)',
" \   '^\s*\(>\)\(.*\)',
" \   '^\s*\(<\)\(.*\)',
" \   '^\s*\(<#\)\(.*\)',
" \   '^\s*\(<?\)\(.*\)',
" \   '^\s*\(<=\)\(.*\)',
" \   '^\s*\(<=#\)\(.*\)',
" \   '^\s*\(<=?\)\(.*\)',
" \   '^\s*\(=\~#\)\(.*\)',
" \   '^\s*\(=\~?\)\(.*\)',
" \   '^\s*\(=\~\)\(.*\)',
" \   '^\s*\(\!\~\)\(.*\)',
" \   '^\s*\(\!\~#\)\(.*\)',
" \   '^\s*\(\!\~?\)\(.*\)',
" \   '^\s*\(is#\)\(.*\)',
" \   '^\s*\(is?\)\(.*\)',
" \   '^\s*\(is\)\(.*\)',
" \   '^\s*\(isnot#\)\(.*\)',
" \   '^\s*\(isnot?\)\(.*\)',
" \   '^\s*\(isnot\)\(.*\)',
" \   '^\s*\(||\)\(.*\)',
" \   '^\s*\(&&\)\(.*\)'
" \]


function! s:is_operator(str)
	return index(s:operator_list, a:str) != -1
endfunction


function! s:to_operator(str)
	let regex = '\(\a\|\d\|_\|""\|''*\)\([+-/*%.=~!?|&#<>]\+\)\(.*\)'
	return substitute(a:str, regex, '\=(empty(submatch(1)) && empty(submatch(3)) ? ("a:1".submatch(2)."a:2") : ((empty(submatch(1)) ? "a:1" : submatch(1)) . submatch(2) . (empty(submatch(3)) ? "a:1" : submatch(3)))) ', "g")
endfunction


function! reti#operator(op)
" 	return reti#eval(s:to_operator_expr(a:op))
	return reti#eval("a:1 ".a:op." a:2")
endfunction


function! reti#compose(expr1, expr2, ...)
	let F1 = reti#lambda(a:expr1)
	let F2 = a:0 ? call (function("reti#compose"), [a:expr2] + a:000) : reti#lambda(a:expr2)
	return reti#eval("F1(call(F2, a:000))", l:)
endfunction


function! reti#function(name, ...)
	try
		if type(a:name) == type(function("tr"))
			return a:name
		endif
		let name = chained#to_function_symbol(a:name, chained#to_SID(chained#latest_called_script_function()))
		return name =~ '^[a-zA-Z0-9#_:<>]\+$' && exists("*".name) ? function(name) : 0
	catch
		return 0
	endtry
endfunction


function! reti#lambda(expr, ...)
	if type(a:expr) == type("") && has_key(s:lambda_cache, a:expr) && !a:0
		return s:lambda_cache[a:expr]
	endif
	let Reti_lambda_func = a:0 ? 0 : reti#function(a:expr, "reti#lambda")
	return type(Reti_lambda_func) == type(function("tr")) ? Reti_lambda_func
\		 : type(a:expr) == type({}) ? call("reti#dict_func", [a:expr] + a:000)
\		 : type(a:expr) == type([]) && len(a:expr) == 1 ? call(function("reti#lambda"), a:expr + a:000)
\		 : type(a:expr) == type([]) ? call(function("reti#compose"), a:expr)
\		 : s:is_operator(a:expr) ? reti#operator(a:expr)
\		 : type(a:expr) == type("") && a:expr[0] ==# ':' ? call(function("reti#execute"), [a:expr] + a:000)
\		 : call(function("reti#eval"), [a:expr] + a:000)
endfunction


function! reti#curry(func)
	return reti#lambda('reti#lambda("call('.string(a:func).', [".string(a:1)."] + a:000)")')
endfunction


function! reti#dict_func(dict, ...)
	let method = get(a:, 1, "apply")
" 	return reti#eval("self.".method."()", {"self" : a:dict})
" 	return reti#eval("call(self.apply, [], self)", {"self" : a:dict})
	return reti#eval("call(self.".method.", a:000, self)", {"self" : a:dict})
endfunction



function! reti#max(a, b)
	return a:a > a:b ? a:a : a:b
endfunction


function! reti#min(a, b)
	return a:a > a:b ? a:b : a:a
endfunction




function! reti#foldl(func, value, seq)
	let Reti_foldl_func = reti#lambda(a:func)
	let result = a:value
	for n in a:seq
		let result = Reti_foldl_func(result, n)
	endfor
	return result
endfunction



function! reti#fold(...)
	return call("reti#foldl", a:000)
endfunction



function! reti#foldr(func, value, seq)
	let Reti_foldr_func = reti#lambda(a:func)
	let result = a:value
	for n in reverse(a:seq)
		let result = Reti_foldr_func(n, result)
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


function! reti#delete_lambda(f, ...)
	let f = matchstr(string(a:f), 'function(''\zs.\{-}\ze'')')
	if has_key(s:lambda_expr_cache, f)
		unlet! s:lambda_cache[s:lambda_expr_cache[f]]
		unlet! s:lambda_capture[f]
		unlet! s:lambda_expr_cache[f]
	endif
	if get(a:, 1, 1)
		execute printf("delfunction %s", f)
	else
		let name = matchstr(f, '<SNR>\zs.*')
		let map = printf("<Plug>(reti-del-func%s)", name)
		execute "nnoremap <silent>" map printf(":delfunction %s <bar> :nunmap %s<CR>", f, map)
		call feedkeys(printf("\<Plug>(reti-del-func%s)", name))
" 		call feedkeys(printf(":delfunction %s\<CR>", f), "n")
	endif
endfunction


function! reti#once(f, ...)
	let F = type(a:f) == type(function("tr")) ? a:f : call("reti#lambda", [a:f] + a:000)
	let f = matchstr(string(F), 'function(''\zs.\{-}\ze'')')
	return reti#execute(printf("let result = call('%s', a:000) | call reti#delete_lambda(function('%s')) | call reti#delete_lambda(Self, 0) | return result", f, f))
endfunction



let cpo = s:save_cpo
unlet s:save_cpo
