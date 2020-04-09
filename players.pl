scan_best_row_in_wall(Wall, Row):- member(X, Wall),
                                   forall(member(Y, Wall), (count(Y, ocupied, N1), count(X, ocupied, N2), N1 =< N2)),
                                   nth1(Row, Wall, X).


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
                                                                        write((Factories," \n")),
                                                                        nth1(FactoryNumber, Factories, F),
                                                                        write(("picking from factory ", FactoryNumber,F," \n")),
                                                                        member(Color, F),
                                                                        get_colors(F, Color, Remainder),
                                                                        length(Remainder, K),
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
valid_play(Color, Row, FactoryNumber, Factories, Board, Center, NewCenter, NewBoard):- pick_from_factory(Color, FactoryNumber, Factories, T, R),
                                                                                       write(("Pick ",Color," from factory ",FactoryNumber, "\n")),
                                                                                       add_selection(Board, Row, T, NewBoard),
                                                                                       append(Center, R, NewCenter).

valid_play(Color, Row, Center, Board, NewCenter, NewBoard):- pick_from_center(Color, Center, T, NewCenter),
                                                             add_selection(Board, Row, T, NewBoard).


% Separar las jugadas en dependencia de que jugador le toca, para poder determinar una estrategia distinta para cada jugador.

% El primer jugador simplemente realiza una jugada aleatoria (Intenta coger de una factoria aleatoria, si no escoge un color random del centro)
play(1, Board, Factories, _, NewP, NewB, NewCenter, NewFactories, I):- findall(X, (member(X, Factories), length(X, N), N > 0), Facts),
                                                                       member(_, Facts),
                                                                       random_member(F, Facts),
                                                                       % Hallar los colores de la factoria
                                                                       findall(X, member(X, F), Colors),
                                                                       %seleccionar un color
                                                                       random_member(Color, Colors),
                                                                       nth1(Row, F, Factories),
                                                                       write(("Player 1 pick ", Color, "from factory", Row)),
                                                                       %hacer una jugada valida seleccionando ese color de esa factoria
                                                                       valid_play(Color, R, Row, Factories, Board, Center, NewCenter, NewB),
                                                                       replaceP(F, [], Factories, NewFactories),
                                                                       NewP is 2.

% Si no puede elegir de las factorias, elige del centro
play(1, Board, _, Center, newP, NewB, NewCenter, NewFactories, I):- findall(X, (member(X, Center), dif(X, initial_token)), Colors),
                                                                    % seleccionar un color aleatorio del centro
                                                                    random_member(Color, Colors),
                                                                    write(("Player 1 pick ", Color, "from center")),
                                                                    % hacer una jugada valida seleccionando ese color del centro
                                                                    valid_play(Color, R, Center, Board, NewCenter, NewB),
                                                                    % comprobar si obtuvimos el token inicial
                                                                    nth1(3, NewB, Floor),
                                                                    member(initial_token, Floor),
                                                                    I is 1,
                                                                    NewP is 2.

% Si no puede elegir de las factorias, elige del centro
play(1, Board, _, Center, newP, NewB, NewCenter, NewFactories, I):- findall(X, (member(X, Center), dif(X, initial_token)), Colors),
                                                                    % seleccionar un color aleatorio del centro
                                                                    random_member(Color, Colors),
                                                                    write(("Player 1 pick ", Color, "from center")),
                                                                    % hacer una jugada valida seleccionando ese color del centro
                                                                    valid_play(Color, R, Center, Board, NewCenter, NewB),
                                                                    % Si se ejecuta esta regla, no obtuvimos el token inicial
                                                                    NewP is 2.


% El segundo jugador intenta completar una fila lo mas rapido posible
play(2, Board, Factories, Center, NewP, NewB, NewCenter, NewFactories, I):- nth1(2, Board, Wall),
                                                                            % Buscar la fila que menos falta por llenar
                                                                            scan_best_row_in_wall(Wall, Row),
                                                                            write(("Player 2 selected row ",Row," to fill\n")),
                                                                            % Elegir de una factoria
                                                                            valid_play(Color, Row, F, Factories, Board, Center, NewCenter, NewB),
                                                                            write(("Player 2 pick ", Color, "from factory", F)),
                                                                            nth1(F, Factories, Fact),
                                                                            replaceP(Fact, [], Factories, NewFactories),
                                                                            NewP is 3.

% El segundo juegador elige del centro
play(2, Board, Factories, Center, NewP, NewB, NewCenter, NewFactories, I):- nth1(2, Board, Wall),
                                                                            % Buscar la fila que menos falta por llenar
                                                                            scan_best_row_in_wall(Wall, Row),
                                                                            % Elegir del Centro
                                                                            valid_play(Color, Row, Center, Board, NewCenter, NewB),
                                                                            write(("Player 2 pick ", Color, "from center")),
                                                                            nth1(3, NewB, Floor),
                                                                            member(initial_token, Floor),
                                                                            I is 2,
                                                                            NewP is 3.

play(2, Board, Factories, Center, NewP, NewB, NewCenter, NewFactories, I):- nth1(2, Board, Wall),
                                                                            % Buscar la fila que menos falta por llenar
                                                                            scan_best_row_in_wall(Wall, Row),
                                                                            % Elegir del Centro
                                                                            valid_play(Color, Row, Center, Board, NewCenter, NewB),
                                                                            write(("Player 2 pick ", Color, "from center")),
                                                                            % Si ejecutamos esta regla, es porque no obtuvimos el token inicial.
                                                                            NewP is 3.


% El primer jugador simplemente realiza una jugada aleatoria (Intenta coger de una factoria aleatoria, si no escoge un color random del centro)
play(3, Board, Factories, _, NewP, NewB, NewCenter, NewFactories, I):- findall(X, (member(X, Factories), length(X, N), N > 0), Facts),
                                                                       member(_, Facts),
                                                                       random_member(F, Facts),
                                                                       % Hallar los colores de la factoria
                                                                       findall(X, member(X, F), Colors),
                                                                       %seleccionar un color
                                                                       random_member(Color, Colors),
                                                                       nth1(Row, F, Factories),
                                                                       write(("Player 3 pick ", Color, "from factory", Row)),
                                                                       %hacer una jugada valida seleccionando ese color de esa factoria
                                                                       valid_play(Color, R, Row, Factories, Board, Center, NewCenter, NewB),
                                                                       replaceP(F, [], Factories, NewFactories),
                                                                       NewP is 4.

% Si no puede elegir de las factorias, elige del centro
play(3, Board, _, Center, newP, NewB, NewCenter, NewFactories, I):- findall(X, (member(X, Center), dif(X, initial_token)), Colors),
                                                                    % seleccionar un color aleatorio del centro
                                                                    random_member(Color, Colors),
                                                                    write(("Player 3 pick ", Color, "from center")),
                                                                    % hacer una jugada valida seleccionando ese color del centro
                                                                    valid_play(Color, R, Center, Board, NewCenter, NewB),
                                                                    % comprobar si obtuvimos el token inicial
                                                                    nth1(3, NewB, Floor),
                                                                    member(initial_token, Floor),
                                                                    I is 3,
                                                                    NewP is 4.

% Si no puede elegir de las factorias, elige del centro
play(3, Board, _, Center, newP, NewB, NewCenter, NewFactories, I):- findall(X, (member(X, Center), dif(X, initial_token)), Colors),
                                                                    % seleccionar un color aleatorio del centro
                                                                    random_member(Color, Colors),
                                                                    % hacer una jugada valida seleccionando ese color del centro
                                                                    valid_play(Color, R, Center, Board, NewCenter, NewB),
                                                                    write(("Player 3 pick ", Color, "from center")),
                                                                    % Si se ejecuta esta regla, no obtuvimos el token inicial
                                                                    NewP is 4.

% El primer jugador simplemente realiza una jugada aleatoria (Intenta coger de una factoria aleatoria, si no escoge un color random del centro)
play(4, Board, Factories, _, NewP, NewB, NewCenter, NewFactories, I):- findall(X, (member(X, Factories), length(X, N), N > 0), Facts),
                                                                       member(_, Facts),
                                                                       random_member(F, Facts),
                                                                       % Hallar los colores de la factoria
                                                                       findall(X, member(X, F), Colors),
                                                                       %seleccionar un color
                                                                       random_member(Color, Colors),
                                                                       nth1(Row, F, Factories),
                                                                       write(("Player 4 pick ", Color, "from factory", Row)),
                                                                       %hacer una jugada valida seleccionando ese color de esa factoria
                                                                       valid_play(Color, R, Row, Factories, Board, Center, NewCenter, NewB),
                                                                       replaceP(F, [], Factories, NewFactories),
                                                                       NewP is 1.

% Si no puede elegir de las factorias, elige del centro
play(4, Board, _, Center, newP, NewB, NewCenter, NewFactories, I):- findall(X, (member(X, Center), dif(X, initial_token)), Colors),
                                                                    % seleccionar un color aleatorio del centro
                                                                    random_member(Color, Colors),
                                                                    write(("Player 4 pick ", Color, "from center")),
                                                                    % hacer una jugada valida seleccionando ese color del centro
                                                                    valid_play(Color, R, Center, Board, NewCenter, NewB),
                                                                    % comprobar si obtuvimos el token inicial
                                                                    nth1(3, NewB, Floor),
                                                                    member(initial_token, Floor),
                                                                    I is 4,
                                                                    NewP is 1.

% Si no puede elegir de las factorias, elige del centro
play(4, Board, _, Center, newP, NewB, NewCenter, NewFactories, I):- findall(X, (member(X, Center), dif(X, initial_token)), Colors),
                                                                    % seleccionar un color aleatorio del centro
                                                                    random_member(Color, Colors),
                                                                    write(("Player 4 pick ", Color, "from center")),
                                                                    % hacer una jugada valida seleccionando ese color del centro
                                                                    valid_play(Color, R, Center, Board, NewCenter, NewB),
                                                                    % Si se ejecuta esta regla, no obtuvimos el token inicial
                                                                    NewP is 1.



%% play(3, Board, Factories, Center, NewP, NewB, NewCenter, NewFactories, I).
%% play(4, Board, Factories, Center, NewP, NewB, NewCenter, NewFactories, I).

