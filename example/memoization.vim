
function! s:memoize(func)
	let Func = a:func
	let cache = {}
	return reti#execute(join([
\		"if !has_key(cache, string(a:000))",
\		"	let cache[string(a:000)] = call(Func, a:000)",
\		"endif",
\		"return cache[string(a:000)]",
\	], "|"), l:)
endfunction


let s:memoizer_cache = {}

function! s:memoizer(func)
	if !has_key(s:memoizer_cache, string(a:func))
		let s:memoizer_cache[string(a:func)] = s:memoize(reti#function(a:func))
	endif
	return s:memoizer_cache[string(a:func)]
endfunction


function! s:fib(n)
	let F = s:memoizer("s:fib")
	return a:n < 2 ? a:n
\		 : F(a:n - 1) + F(a:n - 2)
endfunction

for s:n in range(1, 40)
	echo s:fib(s:n)
endfor

finish
output:
1
1
2
3
5
8
13
21
34
55
89
144
233
377
610
987
1597
2584
4181
6765
10946
17711
28657
46368
75025
121393
196418
317811
514229
832040
1346269
2178309
3524578
5702887
9227465
14930352
24157817
39088169
63245986
102334155


