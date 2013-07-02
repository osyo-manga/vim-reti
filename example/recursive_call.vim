" factorial

" Use 'Self' variable.
let s:fact = reti#lambda("a:1 <= 1 ? a:1 : Self(a:1 - 1) * a:1")
echo s:fact(3)
" => 6

echo s:fact(5)
" => 120

echo s:fact(10)
" => 3628800

