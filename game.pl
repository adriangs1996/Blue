/*
Atoms section
*/

% Define color rules for every number
red.
blue.
gray.
yellow.
black.
% Initial token
initial_token.
ocupied.
empty.
/*
Definir un tablero. Tratar de generar siempre tableros validos.
Un tablero se compone de la pared de alicatado, una hilera de puntuacion,
las lineas de patrones y las lineas del suelo
*/

/*
Para definir un tablero valido primeramente hay que definir un muro valido
y una linea de patrn valida.
*/

% Un muro es valido si:
% -Cada azulejo aparece solo una vez en cada fila y cada columna.
% Esto permite que solo haya que revisar que los azulejos sean los mismos
% en la casilla i, j y en la casilla i+1, j + 1, i+2, j+2, .....

%///////////////        Utilities   /////////////////////////

replaceP(_, _, [], []).
replaceP(O, R, [O|T], [R|T2]):- replaceP(O, R, T, T2).
replaceP(O, R, [H|T], [H|T2]):- dif(H,O), replaceP(O, R, T, T2).

count([], _, 0).
count([X|Y], X, C):- count(Y, X, Z),
                     C is Z + 1.
count([X1|Y], X, C):- count(Y, X, C).

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

% Obtener cantidad de factorias en dependencia de la cantidad de jugadores
fnumber(Players, F):- (Players == 2, F = 5); (Players == 3, F = 7); (Players == 4, F = 9).
get_colors(Storage, Color, Remainder):- findall(B, (length(Storage, N), between(1, N, I), nth1(I, Storage, B), B \= Color), Remainder).

% ///  Comprobar si un muro es valido.
valid_wall(Wall):- length(Wall, W),
                   W==5,
                   forall(member(X,Wall), (length(X, K), K==5)),
                   diagonals(Wall, Diags),
                   forall(member(Y, Diags), test_equals(Y)).


% //////  Linea de patron valida //////////////
valid_pattern_line(PatternLine):- (length(PatternLine, L), L == 5),
                                  forall(between(1, 5, X), (nth1(X, PatternLine, Y) , length(Y, K), K == X)).

generate_valid_wall(OutWall):- random_permutation([1,2,3,4,5], X),
                               nth0(0, X, A),
                               nth0(1, X, B),
                               nth0(2, X, C),
                               nth0(3, X, D),
                               nth0(4, X, E),
                               OutWall=[X, [E, A, B, C, D], [D, E, A, B, C], [C, D, E, A, B], [B, C, D, E, A]].

% El orden es B(PatternLines, Wall, Floor, ScoreTrack)
% El tablero Inicial siempre es valido


/*
==================  Reglas del juego =====================
*/

% Regla bajo la cual una seleccion de fichas se puede agregar al tablero.
valid_patternLine_row(PLine, T):- member(empty, PLine),
                                  forall(member(X, PLine), (member(X, T); X==empty)).

fill_patternLine(PLine, T, NewP, R):- count(PLine, empty, Emptys),
                                      length(PLine, C),
                                      length(T, Colors),
                                      ToFill is min(Emptys, Colors) + C - Emptys,
                                      Others is C - ToFill,
                                      Rem is Colors - min(Emptys, Colors),
                                      member(Color, T),
                                      findall(Color, (between(1, ToFill, _)), Line),
                                      findall(empty, (between(1, Others, _)), EmptyLine),
                                      append(EmptyLine, Line, NewP),
                                      findall(Color, (between(1, Rem, _)), R).

fill_floor(Floor, Tokens, NewFloor):- length(Tokens, N1),
                                      count(Floor, empty, N2),
                                      N1 =< N2,
                                      count(Floor, ocupied, N3),
                                      N4 is N2 - N1,
                                      findall(ocupied, (between(1, N3, _)), OcupiedLine),
                                      findall(ocupied, between(1, N1, _), FilledLine),
                                      findall(empty, between(1, N4, _), Remainder),
                                      append(OcupiedLine, FilledLine, NewFloorTemp),
                                      append(NewFloorTemp, Remainder, NewFloor).


build_new_board(PatternLine, OldLine, OldFloor, NewFloor, NewLine, OldBoard, OutNewBoard):- replaceP(OldLine, NewLine, PatternLine, NewPatternLine),
                                                                                            replaceP(OldFloor, NewFloor, OldBoard, TempBoard),
                                                                                            replaceP(PatternLine, NewPatternLine, TempBoard, OutNewBoard).

add_selection(Board, Row, [initial_token|Tokens], NewBoard):- nth1(1, Board, PatterLine),
                                                              nth1(3, Board, Floor),
                                                              Row =< 5,
                                                              nth1(Row, PatternLine, LineToFill),
                                                              valid_patternLine_row(LineToFill, Tokens),
                                                              fill_patternLine(LineToFill, Tokens, NewP, R),
                                                              append([initial_token], R, Remainder),
                                                              fill_floor(Floor, Remainder, NewFloor),
                                                              build_new_board(PatternLine, LineToFill, Floor, NewFloor, NewP, Board, NewBoard).

add_selection(Board, Row, Tokens, NewBoard):- nth1(1, Board, PatternLine),
                                              nth1(3, Board, Floor),
                                              Row =< 5,
                                              nth1(Row, PatternLine, LineToFill),
                                              valid_patternLine_row(LineToFill, Tokens),
                                              fill_patternLine(LineToFill, Tokens, NewP, Remainder),
                                              fill_floor(Floor, Remainder, NewFloor),
                                              build_new_board(OldBoard, NewP, NewFloor, OutNewBoard).


/************************* Reglas que definen la fase de llenado de las factorias ****************************/

%Obtener 4 losas aleatorias de un pool de losas de 5 colores. El pool consiste en 1 lista, con los tokens que quedan en la bolsa.
delete_first(X,[X|T],T):-!.
delete_first(X,[Y|T],[Y|T1]):-delete_first(X,T,T1).
select4_from_pool(Pool, Selection, NewPool):- random_member(X, Pool),
                                              delete_first(X, Pool, PoolN1),
                                              random_member(Y, PoolN1),
                                              delete_first(Y, PoolN1, PoolN2),
                                              random_member(Z, PoolN2),
                                              delete_first(Z, PoolN2, Pool3),
                                              random_member(A, Pool3),
                                              delete_first(A, Pool3, NewPool),
                                              Selection = [X, Y, Z, A].

fill_factories(Pool, 5, NewFactories, NewPool):- select4_from_pool(Pool, Selection1, Pool1),
                                                 select4_from_pool(Pool1, Selection2, Pool2),
                                                 select4_from_pool(Pool2, Selection3, Pool3),
                                                 select4_from_pool(Pool3, Selection4, Pool4),
                                                 select4_from_pool(Pool4, Selection5, NewPool),
                                                 NewFactories = [Selection1, Selection2, Selection3, Selection4, Selection5].

fill_factories(Pool, 7, NewFactories, NewPool):-  select4_from_pool(Pool, Selection1, Pool1),
                                                  select4_from_pool(Pool1, Selection2, Pool2),
                                                  select4_from_pool(Pool2, Selection3, Pool3),
                                                  select4_from_pool(Pool3, Selection4, Pool4),
                                                  select4_from_pool(Pool4, Selection5, Pool5),
                                                  select4_from_pool(Pool5, Selection6, Pool6),
                                                  select4_from_pool(Pool6, Selection7, NewPool),
                                                  NewFactories = [Selection1, Selection2, Selection3, Selection4, Selection5, Selection6, Selection7].

fill_factories(Pool, 9, NewFactories, NewPool):- select4_from_pool(Pool, Selection1, Pool1),
                                                 select4_from_pool(Pool1, Selection2, Pool2),
                                                 select4_from_pool(Pool2, Selection3, Pool3),
                                                 select4_from_pool(Pool3, Selection4, Pool4),
                                                 select4_from_pool(Pool4, Selection5, Pool5),
                                                 select4_from_pool(Pool5, Selection6, Pool6),
                                                 select4_from_pool(Pool6, Selection7, Pool7),
                                                 select4_from_pool(Pool7, Selection8, Pool8),
                                                 select4_from_pool(Pool8, Selection9, NewPool),
                                                 NewFactories = [Selection1, Selection2, Selection3, Selection4, Selection5, Selection6, Selection7, Selection8, Selection9].

fill_factories(Pool, _, F, NewPool):- !, fail.


% Una jugada consiste en elegir las fichas del mismo color del centro de la mesa o
% de alguna factoria, y colocarlas en alguna fila del patron de linea
pick_from_factory(Color, FactoryNumber, Factories, Tokens, Remainder):- length(Factories, N),
                                                                        FactoryNumber =< N,
                                                                        nth1(FactoryNumber, Factories, F),
                                                                        get_colors(F, Color, Remainder),
                                                                        length(Remainder, K),
                                                                        K > 0,
                                                                        findall(Color, (Len is 4 - K, between(1, Len, _)), Tokens).

pick_from_center(Color, [initial_token | Center], Tokens, NewCenter):- get_colors(Center, Color, NewCenter),
                                                                      length(Center, N1),
                                                                      length(NewCenter, N2),
                                                                      findall(Color, (Len is N1-N2, between(1, Len, _)), Toks),
                                                                      append([initial_token], Toks, Tokens).

pick_from_center(Color, Center, Tokens, NewCenter):- get_colors(Center, Color, NewCenter),
                                                     length(Center, N1),
                                                     length(NewCenter, N2),
                                                     findall(Color, (Len is N1-N2, between(1, Len, _)), Tokens).

% Con los dos tipos de jugadas definidas, ver si una jugada es valida.
valid_play(Color, Row, FactoryNumber, Factories, Board, Center, NewCenter, NewBoard):- pick_from_factory(Color, Row, FactoryNumber, Factories, T, R),
                                                                                       add_selection(Board, T, NewBoard),
                                                                                       append(Center, R, NewCenter).

valid_play(Color, Row, Center, Board, NewCenter, NewBoard):- pick_from_center(Color, Row, Center, T, NewCenter),
                                                             add_selection(Board, T, NewBoard).

