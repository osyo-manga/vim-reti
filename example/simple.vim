
" 式を渡して、それを評価する関数の参照を返す
let s:Func = reti#lambda("1 + 2")
echo s:Func()
" => 3


" 引数を評価する場合は a:N を使用する
let s:Plus = reti#lambda("a:1 + 2")
echo s:Plus(1)
" => 3


" 二項演算子を受け取った場合はそれを評価する関数を返す
let s:Minus = reti#lambda("-")
echo s:Minus(3, 2)
" => 1


" キャプチャする場合は辞書を渡す
let s:PlusN = reti#lambda("a:1 + n", {"n" : 3})
echo s:PlusN(2)
" => 5


" s: や l: を渡すことで直接キャプチャ出来る
let s:n = 4
let s:PlusN = reti#lambda("a:1 + n", s:)
echo s:PlusN(6)
" => 10

function! s:func()
	let n = 1
	let m = 2
	let Func = reti#lambda("n + m", l:)
	echo Func()
	" => 3
endfunction
call s:func()


" コマンドを呼び出す場合は先頭に : を付ける
let s:Func = reti#lambda(":echo a:1")
call s:Func("homu")
" => "homu"

" 代入
let s:n = 2
let s:Func = reti#lambda(":let n += a:1", s:)
call s:Func(4)
echo s:n
" => 6



