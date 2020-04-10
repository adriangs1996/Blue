%Include Section
:-["factories.pl"].
:-["tiled.pl"].
:-["players.pl"].


pretty_print(Board, PatternLine, Floor, Score):- nth1(1, Board, Line1),
                                                 nth1(2, Board, Line2),
                                                 nth1(3, Board, Line3),
                                                 nth1(4, Board, Line4),
                                                 nth1(5, Board, Line5),
                                                 nth1(1, PatternLine, PLine1),
                                                 nth1(2, PatternLine, PLine2),
                                                 nth1(3, PatternLine, PLine3),
                                                 nth1(4, PatternLine, PLine4),
                                                 nth1(5, PatternLine, PLine5),
                                                 write((PLine1, "\t\t\t\t\t")), write((Line1, "\n")),
                                                 write((PLine2, "\t\t\t\t\t")), write((Line2, "\n")),
                                                 write((PLine3, "\t\t\t\t")), write((Line3, "\n")),
                                                 write((PLine4, "\t\t\t")), write((Line4, "\n")),
                                                 write((PLine5, "\t\t")), write((Line5, "\n")),
                                                 write((Floor, "\t\t",Score,"\n\n")).


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

generate_valid_wall(OutWall):- random_permutation([r, b, y, g, w], X),
                               nth0(0, X, A),
                               nth0(1, X, B),
                               nth0(2, X, C),
                               nth0(3, X, D),
                               nth0(4, X, E),
                               OutWall=[X, [E, A, B, C, D], [D, E, A, B, C], [C, D, E, A, B], [B, C, D, E, A]].


tiled_all_walls(Boards, NewBoards):- !,findall(
                                         B, (
                                             between(1, 2, I),
                                             nth1(I, Boards, Board),
                                             nth1(1, Board, P),
                                             nth1(2, Board, W),
                                             nth1(3, Board, Floor),
                                             tiled(P, W, Floor, NewP, NewW, Score),
                                             findall(empty, between(1, 7, _), NewFloor),
                                             nth1(4, Board, OldScore),
                                             NewScore1 is Score + OldScore,
                                             NewScore is min(-Score, 0) * -1,
                                             B = [NewP, NewW, NewFloor, NewScore]),
                                         NewBoards
                                     ).

build_pool(Pool):- findall(r, between(1, 20, _), Reds),
                   findall(b, between(1, 20, _), Blues),
                   findall(y, between(1, 20, _), Yellows),
                   findall(b, between(1, 20, _), Blacks),
                   findall(w, between(1, 20, _), Whites),
                   NestedPool = [Whites, Reds, Blues, Yellows, Blacks],
                   flatten(NestedPool, Pool).



/*
==================  Reglas del juego =====================
*/

% El orden es B(PatternLines, Wall, Floor, ScoreTrack)

%Definir la regla que determina si una partida termina.
final(Board):- nth1(2, Board, Wall),
               not(forall(member(Line, Wall), (count(Line, ocupied, N), N < 5))),
               member(Line, Wall),
               count(Line, ocupied, N),
               N == 5.


%inicio del juego
game(Winner):- build_pool(Pool),
               fill_factories(Pool, 5, NewF, NewPool),
               % Generar los 4 tableros de los jugadores
               generate_valid_wall(Wall1),
               generate_valid_wall(Wall2),
               generate_valid_wall(Wall3),
               generate_valid_wall(Wall4),
               B1 = [
                   [[empty], [empty, empty], [empty, empty, empty], [empty, empty, empty, empty], [empty, empty, empty, empty, empty]],
                   Wall1,
                   [empty, empty, empty, empty, empty, empty, empty],
                   0],
               B2 = [
                   [[empty], [empty, empty], [empty, empty, empty], [empty, empty, empty, empty], [empty, empty, empty, empty, empty]],
                   Wall2,
                   [empty, empty, empty, empty, empty, empty, empty],
                   0],

               %% B3 = [
               %%     [[empty], [empty, empty], [empty, empty, empty], [empty, empty, empty, empty], [empty, empty, empty, empty, empty]],
               %%     Wall3,
               %%     [empty, empty, empty, empty, empty, empty, empty],
               %%     0],

               %% B4 = [
               %%     [[empty], [empty, empty], [empty, empty, empty], [empty, empty, empty, empty], [empty, empty, empty, empty, empty]],
               %%     Wall4,
               %%     [empty, empty, empty, empty, empty, empty, empty],
               %%     0],
               Boards = [B1 , B2],
               random(1, 2, Player),
               write("Starting game\n"),
               game(Boards, Player, NewPool, NewF, [initial_token], InitialPlayer, Winner).


% Final del juego
game(Boards, _, _, _, _, _, Winner):- member(B, Boards),
                                      final(B),
                                      get_max_score(Boards, Winner).

%Primera Fase
game(Boards, _, Pool, [[],[],[],[],[]], [], InitialPlayer,  Winner):- write("\t\t ENTERING TILING FASE \n\n"),
                                                                      write(("Pool ", Pool,"\n")),
                                                                      forall(member(B, Boards),
                                                                             (nth1(1, B, PatternLine),
                                                                              nth1(2, B, Wall),
                                                                              nth1(3, B, Floor),
                                                                              nth1(4, B, Score),
                                                                              pretty_print(Wall, PatternLine, Floor, Score))),
                                                                      tiled_all_walls(Boards, NewBoards), write(("Tiling walls\n")),
                                                                      fill_factories(Pool, 5, NewF, NewPool), write(("filling factories\n")),
                                                                      write("\t\t NEW BOARDS\n\n"),!,
                                                                      forall(member(B1, NewBoards),
                                                                             (nth1(1, B1, PatternLine1),
                                                                              nth1(2, B1, Wall1),
                                                                              nth1(3, B1, Floor1),
                                                                              nth1(4, B1, Score1),
                                                                              pretty_print(Wall1, PatternLine1, Floor1, Score1))),
                                                                      write("\t\t NEW FACTTORIES AND CENTER\n\n"),
                                                                      write(("Center: ", [initial_token], "\n\n")),
                                                                      write(("Factories: ", NewF, "\n\n")),

                                                                      nth1(InitialPlayer, NewBoards, IBoard),
                                                                      play(InitialPlayer, IBoard, NewF, [initial_token], NewP, NewB, NewCenter, NewFactories, I),
                                                                      replaceP(IBoard, NewB, NewBoards, NewBoards2),
                                                                      write(("Center: ",NewCenter, "\n\n")),
                                                                      write(("Factories: ", NewFactories, "\n\n")),
                                                                      sleep(4),
                                                                      game(NewBoards2, NewP, NewPool, NewFactories, NewCenter, I, Winner).

% Una Iteracion intermedia del juego
game(Boards, Player, Pool, Factories, Center, _, Winner):- nth1(Player, Boards, Board),
                                                           write(("Pool ", Pool, "\n")),
                                                           play(Player, Board, Factories, Center, NewP, NewB, NewCenter, NewFactories, InitialPlayer),
                                                           replaceP(Board, NewB, Boards, NewBoards),
                                                           write(("Center: ",NewCenter, "\n\n")),
                                                           write(("Factories: ", NewFactories, "\n\n")),
                                                           forall(member(B, NewBoards),
                                                                  (nth1(1, B, PatternLine),
                                                                   nth1(2, B, Wall),
                                                                   nth1(3, B, Floor),
                                                                   nth1(4, B, Score),
                                                                   pretty_print(Wall, PatternLine, Floor, Score))),
                                                           sleep(4),
                                                           game(NewBoards, NewP, Pool, NewFactories, NewCenter, InitialPlayer, Winner).
