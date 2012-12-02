function! s:make()
	let self = {}
	
	let value = 0
	let self.set = reti#execute("let value = a:1", l:)
	let self.get = reti#lambda("value", l:)

	return self
endfunction

let data = s:make()

let data2 = s:make()

" error
" let data.value = 10

call data.set(10)
call data2.set(42)

echo data.get()
" => 10
echo data2.get()
" => 42

