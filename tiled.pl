:-["utilities.pl"].

/************************ Reglas que definen el proceso de Alicatado **********************/

sum_floor(Floor, 0):- not(member(ocupied, Floor)).
sum_floor(Floor, S):- count(Floor, ocupied, O),
                      FloorSum = [1, 2, 4, 6, 8, 11, 14],
                      nth1(O, FloorSum, S).

count_down_joined([ocupied], 1).
count_down_joined([ocupied | R], C):- count_down_joined(R, Z),
                                      C is Z + 1.
count_down_joined([X|_], 0).

count_down_joined([], 0).

find_vertically_joined(W, I, J, N):- findall(X, (nth1(K, W, Row), K =< I, nth1(J, Row, X)), Downs),
                                     findall(X, (nth1(K, W, Row), K > I, nth1(J, Row, X)), Ups),
                                     count_down_joined(Downs, C1),
                                     count_down_joined(Ups, C2),
                                     N is C1 + C2.

find_horizontally_joined(W, I, J, N):- findall(X, (nth1(I, W, Row), nth1(K, Row, X), K < J), L),
                                       findall(X, (nth1(I, W, Row), nth1(K, Row, X), K > J), Rights),
                                       list_reverse(L, Lefts),
                                       count_down_joined(Lefts, C1),
                                       count_down_joined(Rights, C2),
                                       N is C1 + C2 + 1.


score(Wall, I, J, Score):- find_vertically_joined(Wall, I, J, S1),
                           find_horizontally_joined(Wall, I, J, S2),
                           Score is S1 + S2.

tiled(PatternLine, Wall, Floor, NewP, NewW, Score):- findall(X, (member(X, PatternLine), count(X, empty, N), N == 0), ValidP),
                                                     findall(X, (member(Y, ValidP), length(Y,I), empty_list(I, X)), NewPatterns),
                                                     findall([X, S, I],
                                                             (member(P, ValidP),
                                                              length(P, I),
                                                              nth1(I, Wall, W),
                                                              nth1(1, P, Color),
                                                              member(Color, W),
                                                              nth1(J, W, Color),
                                                              replaceP(Color, ocupied, W, X),
                                                              score(Wall, I, J, S)),
                                                             WallScores),
                                                     dif(WallScores, []),
                                                     findall(X, (member(L, WallScores), nth1(2, L, X)), Scores),
                                                     sum(Scores, Sum),
                                                     sum_floor(Floor, Neg),
                                                     Score is min(-Sum + Neg, 0) * -1,
                                                     findall(X, (member(L, WallScores), nth1(1, L, X)), News),
                                                     findall(X, (member(L, WallScores), nth1(3, L, I), nth1(I, Wall, X)), Olds),
                                                     replace_rows(PatternLine, ValidP, NewPatterns, NewP),
                                                     replace_rows(Wall, Olds, News, NewW).

tiled(PatternLine, Wall, Floor, PatternLine, Wall, Score):- findall(X, (member(X, PatternLine), count(X, empty, N), N == 0), ValidP),
                                                            findall(X, (member(Y, ValidP), length(Y,I), empty_list(I, X)), NewPatterns),
                                                            findall([X, S, I],
                                                                    (member(P, ValidP),
                                                                     length(P, I),
                                                                     nth1(I, Wall, W),
                                                                     nth1(1, P, Color),
                                                                     member(Color, W),
                                                                     nth1(J, W, Color),
                                                                     replaceP(Color, ocupied, W, X),
                                                                     score(Wall, I, J, S)),
                                                                    WallScores),
                                                            WallScores == [],
                                                            sum_floor(Floor, Score).

