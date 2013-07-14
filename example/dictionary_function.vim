
let s:dict = {
\	"value" : 0
\}

function! s:dict.count()
	let self.value += 1
endfunction

let s:Count = reti#lambda(s:dict, "count")
call s:Count()
call s:Count()
call s:Count()
call s:Count()
echo s:dict.value
" => 4

