" quick sort
echo reti#lambda('a:1 == [] ? [] : Self(filter(copy(a:1), "v:val < a:1[0]")) + [a:1[0]] + Self(filter(copy(a:1), "a:1[0] < v:val"))')([3, 2, 7, 1, 9, 8, 4, 6, 5])
" => [1, 2, 3, 4, 5, 6, 7, 8, 9]

