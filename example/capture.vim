" 関数外の変数をキャプチャします


" 変数名をキーに持った辞書を渡す
let s:Func = reti#lambda("x", { "x" : 3 })
echo s:Func()
" => 3

" スクリプトローカル変数を参照
let s:n = 10
let s:Func = reti#lambda(" n + 2 ", s:)
echo s:Func()
" => 12

" 値を変更することも出来る
let s:Func = reti#execute("let n = a:1", s:)
call s:Func(-4)
echo s:n
" => -4

" ローカル変数をキャプチャ
function! s:func()
	let m = 3
	let Func = reti#execute("let m += a:1", l:)
	call Func(2)
	echo m
	" => 5
	
	" 複数の辞書をキャプチャ出来る
	let s:n = 5
	let m = 3
	let Func = reti#lambda("n + m", s:, l:)
	echo Func()
	" => 8
	
	" ただし、複数の辞書をキャプチャする場合、値を変更することは出来ない
	let result = 0
	let Func = reti#execute("let result = n + m", s:, l:)
	call Func()
	echo result
	" => 0

endfunction
call s:func()

