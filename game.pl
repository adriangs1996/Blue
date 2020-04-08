%Include Section
:-["utilities.pl"].
:-["factories.pl"].
:-["tiled.pl"].

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

