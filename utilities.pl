%///////////////        Utilities   /////////////////////////
empty_list(N, L):- findall(empty, between(1, N, _), L).

replace_rows(M, [], [], M).
replace_rows(M, [Old], [New], NewM):- replaceP(Old, New, M, NewM).
replace_rows(M, [O|T1], [N|T2], NewM):- replace_rows(M, T1, T2, TempM),
                                        replaceP(O, N, TempM, NewM).

list_reverse([], []).
list_reverse([T|H], L):- list_reverse(H, R),
                         append(R, [T], L).

replaceP(_, _, [], []).
replaceP(O, R, [O|T], [R|T2]):- replaceP(O, R, T, T2).
replaceP(O, R, [H|T], [H|T2]):- dif(H,O), replaceP(O, R, T, T2).

count([], X, 0).
count([X|Y], X, C):- count(Y, X, Z),
                     C is Z + 1.
count([X1|Y], X, C):- dif(X1, X), count(Y, X, C).

% Obtener el valor de la casilla [i,j] de una matriz
cell_value(I, J, Matrix, X):- nth0(I, Matrix, Row), nth0(J, Row, X).

% Obtener los valores en las diagonal
diagonals(Matrix, [D1, D2, D3, D4, D5]):- findall(B, (between(0, 4, I), nth0(I, Matrix, Row), nth0(I, Row, B)), D1),
                                          findall(B, (between(0, 4, I), J is (I + 1) mod 5, cell_value(I, J, Matrix, B)), D2),
                                          findall(B, (between(0, 4, I), J is (I + 2) mod 5, cell_value(I, J, Matrix, B)), D3),
                                          findall(B, (between(0, 4, I), J is (I + 3) mod 5, cell_value(I, J, Matrix, B)), D4),
                                          findall(B, (between(0, 4, I), J is (I + 4) mod 5, cell_value(I, J, Matrix, B)), D5).

% Comprobar que los elementos de una lista sean iguales.
test_equals([]).
test_equals([_|[]]).
test_equals([X|Y]):- member(X,Y), !, test_equals(Y).

sum([], 0).
sum([X|Y], C):- sum(Y, Z), C is Z + X.

delete_first(X,[X|T],T):-!.
delete_first(X,[Y|T],[Y|T1]):-delete_first(X,T,T1).

