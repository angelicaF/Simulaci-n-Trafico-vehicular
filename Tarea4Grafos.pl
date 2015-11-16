% -------- GRAFOS NO DIRIGIDOS -------- %
% listasComponentes/2(+L,-C) -> C es el grafo con lista de componentes creado a partir de la lista de adyacencias A
listasComponentes([], []).
listasComponentes([X|Xr], [Z,Zr]) :-
    listasCompAux([X|Xr], [[],[]], [Z,Zr]).
listasCompAux([], [A, Ar], [A, Ar]).
listasCompAux([X|Xr], [A, Ar], [R, Rr]) :-
    adyacencias(X, A, Ar, B, Br),
    listasCompAux(Xr, [B, Br], [R, Rr]).
    
adyacencias([], N, A, N, A).
adyacencias([N,A], X, Xr, R, Rr) :-
    (   miembro(N,X)  ->  append(X,[],Y);append(X, [N], Y)   ),
    revisa(A, Y, R),
    producto([N], A, P),
	append(Xr, P, Rr).

revisa([], P, P).
revisa([A|Ar], P, R) :-
    (   miembro(A,P)  ->  append([], P, X); append([A],P,X)   ),
    revisa(Ar, X, R).


% arcosComponentes/2(+A,-C) -> C es el grafo con lista de componentes creado a partir de los arcos A
arcosComponentes([], []).
arcosComponentes(C, [Rn,Ra]) :-
    arcosComponentesAux(C, [], [], Rn, Ra).
    
arcosComponentesAux([], An, Aa, An, Aa).
arcosComponentesAux([O-D|Or], An, Aa, Rn, Ra) :-
    (   miembro(O,An)  ->  append(An, [], Y);append(An, [O], Y)   ),
    (   miembro(D,An)  ->  append(Y, [], Xn);append(Y, [D], Xn)   ),
    (   miembro([O, D],Aa)  ->  append(Aa, [], Xa);append(Aa, [[O,D]], Xa)   ),
    arcosComponentesAux(Or, Xn, Xa, Rn, Ra),!.
arcosComponentesAux([O|Or], An, Aa, Rn, Ra) :-
    (   miembro(O,An)  ->  append(An, [], Xn);append(An, [O], Xn)   ),
    arcosComponentesAux(Or, Xn, Aa, Rn, Ra),!.

% componentesArcos/2(+C, -A) -> A es el grafo con arcos creado a partir de la lista de componentes C
componentesArcos([], []).
componentesArcos([An, Aa], R) :-
    componentesArcosA(Aa, [], [], Rn, X),
    componentesArcosN(An, Rn, X, R).

componentesArcosA([], An, Aa, An, Aa).
componentesArcosA([[A,B]|Ar], An, Aa, Rn, Ra) :-
    (   miembro(A,An)  ->  append(An, [], Y);append(An, [A], Y)   ),
    (   miembro(B,Y)  ->  append(Y, [], Z);append(Y, [B], Z)   ),
    (   miembro(A-B,Aa)  ->  append(Aa, [], X);append(Aa, [A-B], X)   ),
    componentesArcosA(Ar, Z, X, Rn, Ra).

componentesArcosN([], An, X, X).
componentesArcosN([A|Ar], An, Aa, R) :-
    (   miembro(A,An)  ->  append(Aa, [], Y);append(Aa, [A], Y)   ),
    componentesArcosN(Ar, An, Y, R).

% -------- GRAFOS DIRIGIDOS -------- %
% listasComponentes/2(+L,-C) -> C es el grafo con lista de componentes creado a partir de la lista de adyacencias A
listasComponentesD([], []).
listasComponentesD([X|Xr], [Z,Zr]) :-
    listasCompAuxD([X|Xr], [[],[]], [Z,Zr]).
listasCompAuxD([], [A, Ar], [A, Ar]).
listasCompAuxD([X|Xr], [A, Ar], [R, Rr]) :-
    adyacenciasD(X, A, Ar, B, Br),
    listasCompAuxD(Xr, [B, Br], [R, Rr]).
    
adyacenciasD([], N, A, N, A).
adyacenciasD([N,A], X, Xr, R, Rr) :-
    (   miembro(N,X)  ->  append(X,[],Y);append(X, [N], Y)   ),
    revisaD(A, Y, R),
    producto([N], A, P),
	append(Xr, P, Rr).

revisaD([], P, P).
revisaD([A|Ar], P, R) :-
    (   miembro(A,P)  ->  append([], P, X); append([A],P,X)   ),
    revisaD(Ar, X, R).

% arcosComponentes/2(+A,-C) -> C es el grafo con lista de componentes creado a partir de los arcos A
arcosComponentesD([], []).
arcosComponentesD(C, [Rn,Ra]) :-
    arcosComponentesAuxD(C, [], [], Rn, Ra).
    
arcosComponentesAuxD([], An, Aa, An, Aa).
arcosComponentesAuxD([O > D|Or], An, Aa, Rn, Ra) :-
    (   miembro(O,An)  ->  append(An, [], Y);append(An, [O], Y)   ),
    (   miembro(D,An)  ->  append(Y, [], Xn);append(Y, [D], Xn)   ),
    (   miembro([O, D],Aa)  ->  append(Aa, [], Xa);append(Aa, [[O,D]], Xa)   ),
    arcosComponentesAuxD(Or, Xn, Xa, Rn, Ra),!.
arcosComponentesAuxD([O|Or], An, Aa, Rn, Ra) :-
    (   miembro(O,An)  ->  append(An, [], Xn);append(An, [O], Xn)   ),
    arcosComponentesAuxD(Or, Xn, Aa, Rn, Ra),!.

% componentesArcosD/2(+C, -A) -> A es el grafo con arcos creado a partir de la lista de componentes C
componentesArcosD([], []).
componentesArcosD([An, Aa], R) :-
    componentesArcosAD(Aa, [], [], Rn, X),
    componentesArcosND(An, Rn, X, R).

componentesArcosAD([], An, Aa, An, Aa).
componentesArcosAD([[A,B]|Ar], An, Aa, Rn, Ra) :-
    (   miembro(A,An)  ->  append(An, [], Y);append(An, [A], Y)   ),
    (   miembro(B,Y)  ->  append(Y, [], Z);append(Y, [B], Z)   ),
    (   miembro(A-B,Aa)  ->  append(Aa, [], X);append(Aa, [A > B], X)   ),
    componentesArcosAD(Ar, Z, X, Rn, Ra).

componentesArcosND([], An, X, X).
componentesArcosND([A|Ar], An, Aa, R) :-
    (   miembro(A,An)  ->  append(Aa, [], Y);append(Aa, [A], Y)   ),
    componentesArcosND(Ar, An, Y, R).

% -------- FUNCIONES AUXILIARES -------- %
producto(A, B, AxB):-
    findall([Ea,Eb], (member(Ea,A),member(Eb,B)), AxB).

miembro(X, [X|_]).			% si X es el elementos de la cabeza,
miembro(X, [_|R]) :-			% es miembro; en otro caso,
   miembro(X, R).			% lo buscamos en la cola

