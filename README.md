# Blue
# Autores:

   * Eliane Puerta Cabrera.
   * Adrian Gonzalez Sanchez.

## Definiciones de las reglas del juego.

Blue es un juego con varias modalidades, incluso en el dorso del manueal se puede encontrar una modalidad donde los muros que se quieren construir no se atan a colores diferentes en cada fila y columna. Las siguientes reglas son las rigen nuestro proyecto a grandes rasgos.

***Cantidad de jugadores:***

Blue puede jugarse con 2, 3 o 4 jugadores. Nuestro proyecto fue pensado para 4 jugadores, aunque para presentarlo y para facilitar la lectura de las salidas en consolas, decidimos realizar simulaciones solamente con dos jugadores, aunque es perfectamente extensible con solo cambiar algunos argumentos. Para eso ver el apartado referente al juego desde la perspectiva de Prolog.

***Muros:***

Los muros son el objetivo, son los responsables de incrementar nuestros puntos, y por tanto, una de las estructuras de mayor importancia a tener en cuenta en el juego. Los muros los representamos como una Lista de Listas de 5 elementos cada una. Estos muros son creados aleatoriamente al inicio de cada partida y se le asigna uno a cada jugador, por supuesto verificando siempre que estos muros cumplan la restriccion de que solo puede existir una losa del mismo color tanto en filas como columnas. Una forma sencilla de crear muros siempre validos es generar una permutacion aleatoria de los 5 colores que conforman el muro y luego rellenar el mismo por diagonales de 5 elementos de izquierda a derecha.

***Patrones de Lineas:***

Los patrones de lineas son las filas donde vamos colacando nuestras losas para luego "alicatarlas" en el muro, el rellenado de estas lineas constituye la estrategia fundamental a la hora de jugar a Blue. Nuevamente, para nosotros esta estructura no es mas que una lista de listas, donde la primera tiene 1 elemento, la segunda 2, etc, hasta llegar a 5. Por regla estas lineas se llenan de derecha a izquierda, algo que parece raro a la hora de ir observando el juego pues la forma de las filas hacen que se justifiquen a la izquierda en la consola, pero aun asi se llenan de derecha a izquierda.

***El Piso:***

Nuevamente es una Lista de 7 elementos que no importa los colores que se le pongan, siempre se llena de un elemento "ocupied", pues lo que nos interesa es saber la cantidad de losas en el piso a la hora de mapearlo con una puntuacion negativa. El piso posee las siguientes puntuaciones en cada cassilla, que constituye el mapeo hacia lo que se resta de la puntuacion: [-1, -1, -2, -2 , -2, -3, -3].

***El Centro:***

Esta estructura cambia en dependencia de la forma de jugar, nosotros seguimos la idea de que cada vez que se selecciona losas de una factoria, las restantes van al Centro, de donde pueden ser elegidas mas adelante. El centro contiene la ficha de jugador inicial, la cual se le transfiere al primer jugador que seleccione fichas del centro, esta ficha va directamente al Piso y permite a ese jugador, ser el primero en jugar luego de la fase de "alicatado".

***Factories:***

Las factorias son mini listas de 4 elementos que almacenan colores aleatorios que se sacan de la bolsa.

***El score:***

Es simplemente un contador que lleva el rastro de la puntuacion de cada jugador.

***El Pool:***

Es como una bolsa que contiene todas las fichas disponibles. El juego cuenta con 100 fichas, 20 de cada color. (Los colores son representados por las letras r, b, g, w, y, en nuestro proyecto, iniciales de rogo, negro, gris, blanco y amarillo).

Las definiciones anteriores permiten explicar facilmente nuestra estructura Board, la cual aparece en gran cantidad de las reglas definidas en el programa. Board es una lista de 4 elementos que guarda el estado de un jugador, o sea, 

Board = [LineaDePatron, Muro, Piso, Score].

Por supuesto, Boards es la representacion de un tablero por cada jugador, por tanto en los screenshots, Boards contiene dos elementos Board.

Junto con Boards, las estructuras Center, Factories y Pool, constituyen el estado del juego. Podemos entonces declarar que tenemos que entrar en fase de "alicatado" cuando cada Factory esta vacia y cuando Center esta vacio. Dicho esto, esta fase constituye en poner ocupied en cada casilla del muro que pertenezca al color y fila de una Linea de Patron que halla sido completada y adicionar los scores (parece simple :=() ).

*Como restricciones al juego tenemos*: 
  * solo se puede completar una linea de patron con el mismo color, y solo con un color que no este ocupied en el muro.
  
  * Al seleccionar un color (tanto de factoria, como del centro), es necesario tomar todos los colores iguales del mismo    almacenamiento, de no caber todos en la linea que se desea, el resto debe pasar al Piso.
  
  * Solo se pasa a fase de "alicatado" una vez que el centro y las factorias esten vacias.
  
  * Un jugador no puede tener un score negativo, al menos siempre es 0.
  
  * El juego termina cuando es vacio el centro, las factorias y el pool, o cuando un jugador completa una fila entera del muro.
  
  * Los jugadores juegan en en un orden creciente (1, 2, 3, 4, 1, etc,), simulando la direccion de las manecillas del reloj.
  
  * El primer jugador en empezar el juego es aleatorio.
  
  * Ningun jugador puede violar su turno, a menos que no tenga jugada posible, (Elegir todos los colores de un almacenamiento y ponerlos en el Piso es una jugada valida).
  
  * Un jugador, al alicatar un muro, gana tantos puntos como losas adyacentes tenga horizontal y verticalmente (en nuestro proyecto, las losas se ponen "al mismo tiempo", o sea, que no se forman nuevas cadenas de losas adyacentes en tiempo de alicatado, sino luego, una cadena que se forme en la ronda n, afecta a la ronda n+1, pero no a otra losa en la misma ronda n).
  
  Con estas reglas en la mesa, nuestro objetivo es simular el juego de Blue, y reportar el ganador, asi como ir informando en cada paso de las acciones que se toman.
  
  ## Jugando.
  
  Para empezar el juego se toman los pasos siguientes:
  
  ```bash
  $ prolog
  ```
  
  ```prolog
  -? consult("game.pl").
  -? game(W).
  ```
  
  Como se muestra en la siguiente imagen las dos primeras iteraciones del juego donde primero juega el jugador 1 y despues el jugador 2:
  
  ![screenshot](https://github.com/adriangs1996/Blue/blob/master/screenshots/Screenshot%20from%202020-04-10%2015-38-17.png)
  
  En la siguiente se ve como se llega a la fase de "alicatado" cuando tanto el centro como las factories son vacias:
  
  ![screenshot](https://github.com/adriangs1996/Blue/blob/master/screenshots/Screenshot%20from%202020-04-10%2015-38-56.png)
  
  Y en esta se ve como luego del alicatado, el jugador 1 gana dos puntos y se le resta 1 porque tenia una ficha en el Piso, por lo que su score es 1, y el jugador 2 no gana puntos pues coloca dos colores en el muro, pero tiene 3 fichas en el Piso lo que provoca que se quede con 0.
  
   ![screenshot](https://github.com/adriangs1996/Blue/blob/master/screenshots/Screenshot%20from%202020-04-10%2015-40-06.png)
   
   ## El Juego desde Prolog.
   
   La implementacion del juego, es literalmente la implementacion de cada regla que discutimos anteriormente. Dicho esto, el flujo principal del programa primero incluye algunas utilidades y funciones en archivos adjuntos (separamos los archivos por un tema de comodidad a la hora de programar, para mantener organizado el codigo):
   
   ```prolog
   :- ["factories.pl"].
   :- ["tiled.pl"].
   :- ["players.pl"].
   ```
   
   Una vez cargado el programa, solo que que se pregunte por el objetivo game. Aunuqe game se llama con un solo argumento, que devuelve la puntuacion del jugador ganador, en verdad este objetivo es el fundamental en el programa, pues recursivamente se ocupa de ir iterando por cada fase del juego, por ejemplo, la interacion intermedia se representa por el objetivo:
   
   ```prolog
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

   ```
   
Definir de esta forma el ciclo del juego, separa la logica del juego de la cantidad de jugadores, por ejemplo, ya que es play el encargado de recibir el jugador que va a realizar una jugada, y en cambio, si triunfa, devolver el nuevo estado y el proximo jugador a jugar. Por supuesto, game tiene otras definiciones que permiten diferenciar las fases (final, de alicatado).

De querer jugar con mas jugadores, en el archivo play.pl se encuentran implementaciones para los jugadores 3 y 4, los cuales juegan de forma bastante simialar al 1, en cambio el jugador 2, intenta seguir una estrategia un poco greedy, al intentar llenar una fila del muro lo mas rapido posible (por supuesto, por simplicidad elige un color al azar de un almacenamiento a la hora de llenar una fila, el solo sabe la fila que quiere llenar, por eso es posible que no siempre su eleccion sea la mas apropiada, pues a lo mejor eligiendo otro color llena la linea de patron). Curiosamente, el jugador 1 gana aproximadamente la misma cantidad de veces que el jugador 2, y es que el jugador 1 juega casi que aleatorio, y sus jugadas repercuten bastante en lo que intente hacer el jugador 2, aun cuando el 1 no haga una buena jugada, puede que le quite al jugar 2 una buena posibilidad. Es incluso interesante, como de repente, el jugador 1 puede acumular de golpe hasta 36 puntos (es lo mas que vimos), aun cuando sus elecciones no habian alicatado en 1 o 2 fases anteriores, pero aleatoreamente fue construyendo gran cantidad de losas adyacentes, lo que hace que de golpe suba mucho su puntuacion. Quizas jugar aleatorio no sea tan mala idea :).

El objetivo fundamental a la hora de escoger una fila para llenar para el jugador 2 esta dado al tratar de cumplir:

```prolog
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

```

Como se ve, intenta buscar una linea del muro, tal que para toda otra linea del muro la cantidad de elementos vacios de la primera sea menor o igual que los de la segunda (en otras palabras, a la que le falta menos para llenarse).

Fuera de como juega cada jugador, diferentes objetivos restrigen las jugadas que se pueden hacer y velan porque se cumplan las reglas del juego. Uno de los mas importantes quizas es:

```prolog
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
```

Este objetivo intenta realizar una seleccion del almacenamiento que se especifica, y solo triunfa si es posible agregarlo a nuestra Linea de Patron o a nuestro Piso. Objetivos intermedios como add_selection, fill_floor y pick_from_factory/center se ocupan de que cada uno de estos procesos solo triunfe si cumplen con las reglas que indican en sus nombres y que fueron discutidas anteriormente.

Notar que por la forma en que estan elaboradas las reglas, la seleccion del jugador 1 nunca es del todo aleatoria, pues el jugador 1 de triunfar en una llamada al objetivo play, y para que esto se cumpla, cada una de estas reglas intermedias debe cumplirse, el solo hecho de llamar a random_member, por ejemplo, para seleccionar un color aleatorio de algun almacenamiento, pudiera provocar una cadena de fails que eventualmente harian fallar al objetivo principal, game. 

Dicho esto, la forma de jugar del jugador 1 pudiera ser mejor descrita como " toma lo primero que este disponible y colocalo en algun lugar valido".

Nos falta por definir las reglas que rigen entonces, el llenado de las factories, el alicatado, la extraccion del Pool, y el momento inicial donde se crean los tableros.

De la extraccion del Pool se ocupa un objetivo que se llama select4_from_pool/3 que triunfa si es posible elegir aleatoriamente 4 elementos del Pool actual, y como efecto colateral devuelve el nuevo pool sin estos 4 elementos.

Este objetivo es clave pues cada factory triufa en su llenado, si es posible que extraiga 4 elementos del pool, dicho asi el objetivo fill_factories/4 triunfa si por cada factoria definida, se pueden extraer 4 elementos del pool.

Del alicatado se ocupa el objetivo tiled/6, que triunfa si todos las lineas de patron llenas contienen un color que puede ser sustituido en el muro por ocupied y a la vez, se les calcula el score que aportan estas casillas donde se pone ocupied. Notar que este objetivo debe triunfar aun cuando la cantidad de lineas de patron llenas sea 0, en dicho caso, solo se tiene en cuenta el Piso para el score (o sea se devuelve un score negativo).

Para comenzar el juego, se utiliza una version de game/1, la cual a diferencia del game/7, se encarga de inicializar todo el juego, su definicion es la siguiente:

```prolog
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


```

Descomentando B3 y B4, y cambiando 5 por 9 en fill_factory en cada game, asi como redefiniendo en play.pl que luego del jugaor 2 viene el 3, luego del 3 viene el 4, y luego del 4 viene el 1, se puede extender el juego para 4 jugadores, aunque la salida no es muy amigable.
