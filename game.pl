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

% Definir las condiciones bajo las cual una jugada es valida

% Una jugada consiste en elegir las fichas del mismo color del centro de la mesa o
% de alguna factoria, y colocarlas en alguna fila del patron de linea
pick_from_factory(Color, FactoryNumber, Factories, Tokens, Remainder):- length(Factories, N),
                                                                   FactoryNumber =< N,
                                                                   nth1(FactoryNumber, Factories, F),
                                                                   get_colors(F, Color, Remainder),
                                                                   length(Remainder, K),
                                                                   K > 0,
                                                                   findall(Color, (Len is 4 - K, between(1, Len, _)), Tokens).

pick_from_center(Color, [initial_token| Center], Tokens, NewCenter):- get_colors(Center, Color, NewCenter),
                                                                      length(Center, N1),
                                                                      length(NewCenter, N2),
                                                                      findall(Color, (Len is N1-N2, between(1, Len, _)), Toks),
                                                                      append([initial_token], Toks, Tokens).

pick_from_center(Color, Center, Tokens, NewCenter):- get_colors(Center, Color, NewCenter),
                                                     length(Center, N1),
                                                     length(NewCenter, N2),
                                                     findall(Color, (Len is N1-N2, between(1, Len, _)), Tokens).



