scan_best_row_in_wall(Wall, Row, P):- member(X, Wall),
                                      nth1(Row, Wall, X),
                                      nth1(Row, P, Line),
                                      count(Line, empty, N),
                                      N > 0,
                                      forall(member(Y, Wall), (dif(Y, X), count(Y, ocupied, N1), count(X, ocupied, N2), N1 =< N2)).

scan_best_row_in_wall(Wall, Row, P):-  member(X, Wall),
                                       nth1(Row, Wall, X),
                                       nth1(Row, P, Line),
                                       count(Line, empty, N),
                                       N > 0.



% Regla bajo la cual una seleccion de fichas se puede agregar al tablero.
valid_patternLine_row(PLine, []).

valid_patternLine_row(PLine, T):- count(PLine, empty, N1), length(PLine, N2), N1 == N2.

valid_patternLine_row(PLine, T):- member(empty, PLine),
                                  member(Color, T),
                                  member(Color, PLine).

fill_patternLine(PLine, [], PLine, []).

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

add_selection(Board, Row, [initial_token|Tokens], NewBoard):- nth1(1, Board, PatternLine),
                                                              nth1(3, Board, Floor),
                                                              nth1(Row, PatternLine, LineToFill),
                                                              valid_patternLine_row(LineToFill, Tokens),
                                                              fill_patternLine(LineToFill, Tokens, NewP, R),
                                                              append([initial_token], R, Remainder),
                                                              fill_floor(Floor, Remainder, NewFloor),
                                                              build_new_board(PatternLine, LineToFill, Floor, NewFloor, NewP, Board, NewBoard).

add_selection(Board, Row, Tokens, NewBoard):- nth1(1, Board, PatternLine),
                                              nth1(3, Board, Floor),
                                              nth1(Row, PatternLine, LineToFill),
                                              valid_patternLine_row(LineToFill, Tokens),
                                              fill_patternLine(LineToFill, Tokens, NewP, Remainder),
                                              fill_floor(Floor, Remainder, NewFloor),
                                              build_new_board(PatternLine,LineToFill, Floor, NewFloor, NewP, Board, NewBoard).


% Una jugada consiste en elegir las fichas del mismo color del centro de la mesa o
% de alguna factoria, y colocarlas en alguna fila del patron de linea
pick_from_factory(Color, FactoryNumber, Factories, Tokens, Remainder):- nth1(FactoryNumber, Factories, F),
                                                                        member(Color, F),
                                                                        get_colors(F, Color, Remainder),
                                                                        length(Remainder, K),
                                                                        findall(Color, (Len is 4 - K, between(1, Len, _)), Tokens).

pick_from_center(Color, [initial_token | Center], Tokens, NewCenter, P, P):- get_colors(Center, Color, NewCenter),
                                                                             length(Center, N1),
                                                                             length(NewCenter, N2),
                                                                             findall(Color, (Len is N1-N2, between(1, Len, _)), Toks),
                                                                             append([initial_token], Toks, Tokens).

pick_from_center(Color, Center, Tokens, NewCenter, _, _):- get_colors(Center, Color, NewCenter),
                                                           length(Center, N1),
                                                           length(NewCenter, N2),
                                                           findall(Color, (Len is N1-N2, between(1, Len, _)), Tokens).

% Con los dos tipos de jugadas definidas, ver si una jugada es valida.
valid_play(Color, Row, FactoryNumber, Factories, Board, Center, NewCenter, NewBoard, P, IP):- nth1(2, Board, Wall),
                                                                                              nth1(Row, Wall, Line),
                                                                                              member(Color, Line),
                                                                                              dif(Color, ocupied),
                                                                                              pick_from_factory(Color, FactoryNumber, Factories, T, R),
                                                                                              add_selection(Board, Row, T, NewBoard),
                                                                                              append(Center, R, NewCenter).

valid_play(Color, Row, Center, Board, NewCenter, NewBoard, P, IP):- nth1(2, Board, Wall),
                                                                    nth1(Row, Wall, Line),
                                                                    member(Color, Line),
                                                                    dif(Color, ocupied),
                                                                    pick_from_center(Color, Center, T, NewCenter, P, IP),
                                                                    add_selection(Board, Row, T, NewBoard).

% Caso en que cogemos de la facotria pero solo podemos llenar el piso
valid_play(Color, Row, FactoryNumber, Factories, Board, Center, NewCenter, NewBoard, P, IP):- nth1(3, Board, Floor),
                                                                                              pick_from_factory(Color, FactoryNumber, Factories, T, R),
                                                                                              length(T, N),
                                                                                              count(Floor, empty, N2),
                                                                                              N =< N2,
                                                                                              fill_floor(Floor, T, NewFloor),
                                                                                              replaceP(Floor, NewFloor, Board, NewBoard),
                                                                                              append(Center, R, NewCenter).
% Caso que escogemos del centro pero solo podemos llenar el piso
valid_play(Color, Row, Center, Board, NewCenter, NewBoard, P, I):- pick_from_center(Color, Center, T, NewCenter, P, IP),
                                                                   nth1(3, Board, Floor),
                                                                   fill_floor(Floor, T, NewFloor),
                                                                   replaceP(Floor, NewFloor, Board, NewBoard).



% Separar las jugadas en dependencia de que jugador le toca, para poder determinar una estrategia distinta para cada jugador.

% El primer jugador simplemente realiza una jugada aleatoria (Intenta coger de una factoria aleatoria, si no escoge un color random del centro)
play(1, Board, Factories, Center, NewP, NewB, NewCenter, NewFactories, I):- member(F, Factories),
                                                                            dif(F, []),
                                                                            % Hallar los colores de la factoria
                                                                            %seleccionar un color
                                                                            member(Color, F),
                                                                            nth1(Row, Factories, F),
                                                                            nth1(2, Board, Wall),
                                                                            nth1(R, Wall, Line),
                                                                            member(Color, Line),
                                                                            %hacer una jugada valida seleccionando ese color de esa factoria
                                                                            valid_play(Color, R, Row, Factories, Board, Center, NewCenter, NewB, 1, I),
                                                                            write(("Player 1 pick ", Color, "from factory", Row,"\n")),
                                                                            replaceP(F, [], Factories, NewFactories),
                                                                            NewP is 2.

% Si no puede elegir de las factorias, elige del centro
play(1, Board, Factories, Center, NewP, NewB, NewCenter, NewFactories, I):- member(Color, Center),
                                                                            dif(Color, initial_token),
                                                                            nth1(2, Board, Wall),
                                                                            nth1(R, Wall, Line),
                                                                            member(Color, Line),
                                                                            % hacer una jugada valida seleccionando ese color del centro
                                                                            valid_play(Color, R, Center, Board, NewCenter, NewB, 1, I),
                                                                            % comprobar si obtuvimos el token inicial
                                                                            nth1(3, NewB, Floor),
                                                                            NewFactories = Factories,
                                                                            write(("Player 1 pick ", Color, "from center\n")),
                                                                            NewP is 2.

% El segundo jugador intenta completar una fila lo mas rapido posible
play(2, Board, Factories, Center, NewP, NewB, NewCenter, NewFactories, I):- nth1(2, Board, Wall),
                                                                            % Buscar la fila que menos falta por llenar
                                                                            nth1(1, Board, P),
                                                                            scan_best_row_in_wall(Wall, Row, P),
                                                                            % Elegir de una factoria
                                                                            nth1(Row, Wall, Line),
                                                                            member(Color, Line),
                                                                            dif(Color, ocupied),
                                                                            member(Fact, Factories),
                                                                            member(Color, Fact),
                                                                            nth1(F, Factories, Fact),
                                                                            valid_play(Color, Row, F, Factories, Board, Center, NewCenter, NewB, 2, I),
                                                                            write(("Player 2 picks ", Color, " from factory ", Row, "\n")),
                                                                            replaceP(Fact, [], Factories, NewFactories),
                                                                            NewP is 1.

% El segundo juegador elige del centro
play(2, Board, Factories, Center, NewP, NewB, NewCenter, NewFactories, I):- nth1(2, Board, Wall),
                                                                            % Buscar la fila que menos falta por llenar
                                                                            nth1(1, Board, P),
                                                                            scan_best_row_in_wall(Wall, Row, P),
                                                                            % Elegir del Centro
                                                                            member(Color, Center),
                                                                            dif(Color, initial_token),
                                                                            nth1(Row, Wall, Line),
                                                                            member(Color, Line),
                                                                            valid_play(Color, Row, Center, Board, NewCenter, NewB, 2, I),
                                                                            write(("Player 2 pick ", Color, "from center\n")),
                                                                            NewFactories = Factories,
                                                                            NewP is 1.

play(3, Board, Factories, Center, NewP, NewB, NewCenter, NewFactories, I):- member(F, Factories),
                                                                            dif(F, []),
                                                                            % Hallar los colores de la factoria
                                                                            %seleccionar un color
                                                                            member(Color, F),
                                                                            nth1(Row, Factories, F),
                                                                            nth1(2, Board, Wall),
                                                                            nth1(R, Wall, Line),
                                                                            member(Color, Line),
                                                                            %hacer una jugada valida seleccionando ese color de esa factoria
                                                                            valid_play(Color, R, Row, Factories, Board, Center, NewCenter, NewB,3, I),
                                                                            write(("Player 3 pick ", Color, "from factory", Row, "\n")),
                                                                            replaceP(F, [], Factories, NewFactories),
                                                                            NewP is 4.

% Si no puede elegir de las factorias, elige del centro
play(3, Board, Factories, Center, NewP, NewB, NewCenter, NewFactories, I):- member(Color, Center),
                                                                            dif(Color, initial_token),
                                                                            nth1(2, Board, Wall),
                                                                            nth1(R, Wall, Line),
                                                                            member(Color, Line),
                                                                            % hacer una jugada valida seleccionando ese color del centro
                                                                            valid_play(Color, R, Center, Board, NewCenter, NewB, 3, I),
                                                                            % comprobar si obtuvimos el token inicial
                                                                            write(("Player 3 pick ", Color, "from center\n")),
                                                                            NewFactories = Factories,
                                                                            NewP is 4.

play(4, Board, Factories, Center, NewP, NewB, NewCenter, NewFactories, I):- member(F, Factories),
                                                                            dif(F, []),
                                                                            % Hallar los colores de la factoria
                                                                            %seleccionar un color
                                                                            member(Color, F),
                                                                            nth1(Row, Factories, F),
                                                                            nth1(2, Board, Wall),
                                                                            nth1(R, Wall , Line),
                                                                            member(Color, Line),
                                                                            %hacer una jugada valida seleccionando ese color de esa factoria
                                                                            valid_play(Color, R, Row, Factories, Board, Center, NewCenter, NewB, 4, I),
                                                                            write(("Player 4 pick ", Color, "from factory", Row,"\n")),
                                                                            replaceP(F, [], Factories, NewFactories),
                                                                            NewP is 1.

% Si no puede elegir de las factorias, elige del centro
play(4, Board, Factories, Center, NewP, NewB, NewCenter, NewFactories, I):- member(Color, Center),
                                                                            dif(Color, initial_token),
                                                                            nth1(2, Board, Wall),
                                                                            nth1(R, Wall, Line),
                                                                            member(Color, Line),
                                                                            % hacer una jugada valida seleccionando ese color del centro
                                                                            valid_play(Color, R, Center, Board, NewCenter, NewB, 4, I),
                                                                            % comprobar si obtuvimos el token inicial
                                                                            write(("Player 4 pick ", Color, "from center\n")),
                                                                            NewFactories = Factories,
                                                                            NewP is 1.
