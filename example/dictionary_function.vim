
let s:dict = {
\	"value" : 0
\}

function! s:dict.count()
	let self.value += 1
endfunction

let s:Count = reti#lambda("self.count()", { "self" : s:dict })
call s:Count()
call s:Count()
call s:Count()
call s:Count()
echo s:dict.value
" => 4

