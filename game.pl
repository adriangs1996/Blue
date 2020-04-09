%Include Section
:-["factories.pl"].
:-["tiled.pl"].
:-["players.pl"].

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

generate_valid_wall(OutWall):- random_permutation([red, blue, yellow, black, white], X),
                               nth0(0, X, A),
                               nth0(1, X, B),
                               nth0(2, X, C),
                               nth0(3, X, D),
                               nth0(4, X, E),
                               OutWall=[X, [E, A, B, C, D], [D, E, A, B, C], [C, D, E, A, B], [B, C, D, E, A]].


tiled_all_walls(Boards, NewBoards):- findall(
                                         B, (
                                             between(1, 4, I),
                                             nth1(I, Boards, Board),
                                             nth1(1, Board, P),
                                             nth1(2, Board, W),
                                             nth1(3, Board, Floor),
                                             tiled(P, W, Floor, NewP, NewW, Score),
                                             findall(empty, (between(1, 7, _), NewFloor)),
                                             nth1(4, Board, OldScore),
                                             NewScore is Score + OldScore,
                                             B = [NewP, NewW, NewFloor, NewScore]),
                                         NewBoards
                                     ).

build_pool(Pool):- findall(red, between(1, 20, _), Reds),
                   findall(blue, between(1, 20, _), Blues),
                   findall(yellow, between(1, 20, _), Yellows),
                   findall(black, between(1, 20, _), Blacks),
                   findall(white, between(1, 20, _), Whites),
                   NestedPool = [Whites, Reds, Blues, Yellows, Blacks],
                   flatten(NestedPool, Pool).



/*
==================  Reglas del juego =====================
*/

% El orden es B(PatternLines, Wall, Floor, ScoreTrack)

%Definir la regla que determina si una partida termina.
final(Board):- nth1(2, Board, Wall),
               not(forall(member(Line, Wall), (count(Line, ocupied, N), N < 5))).


%inicio del juego
game(Winner):- build_pool(Pool),
               fill_factories(Pool, 9, NewF, NewPool),
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

               B3 = [
                   [[empty], [empty, empty], [empty, empty, empty], [empty, empty, empty, empty], [empty, empty, empty, empty, empty]],
                   Wall3,
                   [empty, empty, empty, empty, empty, empty, empty],
                   0],

               B4 = [
                   [[empty], [empty, empty], [empty, empty, empty], [empty, empty, empty, empty], [empty, empty, empty, empty, empty]],
                   Wall4,
                   [empty, empty, empty, empty, empty, empty, empty],
                   0],
               Boards = [B1 , B2, B3, B4],
               random(1, 4, Player),
               game(Boards, Player, NewPool, NewF, [initial_token], InitialPlayer, Winner).


% Final del juego
game(Boards, _, _, _, _, _, Winner):- not(forall(member(Board, Boards), not(final(Board)))),
                                      get_max_score(Boards, Winner).

%Primera Fase
game(Boards, _, Pool, [[],[],[],[],[],[],[],[],[]], [], InitialPlayer,  Winner):- tiled_all_walls(Boards, NewBoards), write(("Tiling walls\n")),
                                                                                  fill_factories(Pool, 9, NewF, NewPool), write(("filling factories\n")),
                                                                                  nth1(InitialPlayer, NewBoards, Board), write(("Playing:",InitialPlayer,"\n")),
                                                                                  play(InitialPlayer, Board, NewF, [initial_token], NewP, NewB, NewCenter, NewFactories, I),
                                                                                  game(NewB, NewP, NewPool, NewFactories, NewCenter, I, Winner).

% Una Iteracion intermedia del juego
game(Boards, Player, Pool, Factories, Center, InitialPlayer, Winner):- nth1(Player, Boards, Board), write(("Playing: ",Player,"\n")),
                                                                       play(Player, Board, Factories, Center, NewP, NewB, NewCenter, NewFactories, I),
                                                                       game(NewB, NewP, Pool, NewFactories, NewCenter, I, Winner).
