/************************* Reglas que definen la fase de llenado de las factorias ****************************/

%Obtener 4 losas aleatorias de un pool de losas de 5 colores. El pool consiste en 1 lista, con los tokens que quedan en la bolsa.

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

