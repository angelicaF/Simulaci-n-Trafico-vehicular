ad(_, _).
adj(_, _).
arco(_,_).
grafo(_,_).
digrafo(_,_).
    
    
% -------- GRAFOS NO DIRIGIDOS -------- %
% listasComponentes/2(+L,-C) -> C es el grafo con componentes de grafo creado a partir de la lista de adyacencias L
listasComponentes([], []).
listasComponentes([X|Xr], grafo(Z,Zr)) :-
    listasCompAux([X|Xr], [[],[]], [Z,Zr]).
listasCompAux([], [A, Ar], [A, Ar]).
listasCompAux([X|Xr], [A, Ar], [R, Rr]) :-
    adyacencias(X, A, Ar, B, Br),
    listasCompAux(Xr, [B, Br], [R, Rr]).
    
adyacencias([], N, A, N, A).
adyacencias(ad(N,A), X, Xr, R, Rr) :-
    (   miembro(N,X)  ->  append(X,[],Y);append(X, [N], Y)   ),
    revisa(A, Y, R),
    producto([N], A, P1),
    toArco(P1,P),
	append(Xr, P, Rr).

revisa([], P, P).
revisa([A|Ar], P, R) :-
    (   miembro(A,P)  ->  append([], P, X); append([A],P,X)   ),
    revisa(Ar, X, R).

%componentesListas/2(+C,-L) -> L es el grafo con lista de adyacencia creado a partir de los componentes del grafo C
componentesListas(grafo(Ns,Es),AL) :- memberchk(arco(_,_,_),Es), ! ,
   componentesListasAux(Ns,Es,AL).
componentesListas(grafo(Ns,Es),AL) :- !,
   componentesListasAux2(Ns,Es,AL).

componentesListasAux([],_,[]).
componentesListasAux([V|Vs],Es,[ad(V,L)|Ns]) :-
   findall(T,((member(arco(X,V,I),Es) ; member(arco(V,X,I),Es)),T = X/I),L),
   componentesListasAux(Vs,Es,Ns).

componentesListasAux2([],_,[]).
componentesListasAux2([V|Vs],Es,[ad(V,L)|Ns]) :-
   findall(X,(member(arco(X,V),Es) ; member(arco(V,X),Es)),L), componentesListasAux2(Vs,Es,Ns).

% arcosComponentes/2(+A,-C) -> C es el grafo con lista de componentes creado a partir de los arcos A
arcosComponentes([], []).
arcosComponentes(C, grafo(Rn,Ra)) :-
    arcosComponentesAux(C, [], [], Rn, Ra).
    
arcosComponentesAux([], An, Aa, An, Aa).
arcosComponentesAux([O-D|Or], An, Aa, Rn, Ra) :-
    (   miembro(O,An)  ->  append(An, [], Y);append(An, [O], Y)   ),
    (   miembro(D,An)  ->  append(Y, [], Xn);append(Y, [D], Xn)   ),
    (   miembro([O, D],Aa)  ->  append(Aa, [], Xa);append(Aa, [arco(O,D)], Xa)   ),
    arcosComponentesAux(Or, Xn, Xa, Rn, Ra),!.
arcosComponentesAux([O|Or], An, Aa, Rn, Ra) :-
    (   miembro(O,An)  ->  append(An, [], Xn);append(An, [O], Xn)   ),
    arcosComponentesAux(Or, Xn, Aa, Rn, Ra),!.

% componentesArcos/2(+C, -A) -> A es el grafo con arcos creado a partir de la lista de componentes C
componentesArcos([], []).
componentesArcos(grafo(An, Aa), R) :-
    componentesArcosA(Aa, [], [], Rn, X),
    componentesArcosN(An, Rn, X, R).

componentesArcosA([], An, Aa, An, Aa).
componentesArcosA([arco(A,B)|Ar], An, Aa, Rn, Ra) :-
    (   miembro(A,An)  ->  append(An, [], Y);append(An, [A], Y)   ),
    (   miembro(B,Y)  ->  append(Y, [], Z);append(Y, [B], Z)   ),
    (   miembro(A-B,Aa)  ->  append(Aa, [], X);append(Aa, [A-B], X)   ),
    componentesArcosA(Ar, Z, X, Rn, Ra).

componentesArcosN([], _, X, X).
componentesArcosN([A|Ar], An, Aa, R) :-
    (   miembro(A,An)  ->  append(Aa, [], Y);append(Aa, [A], Y)   ),
    componentesArcosN(Ar, An, Y, R).

% -------- GRAFOS DIRIGIDOS -------- %
% listasComponentes/2(+L,-C) -> C es el grafo con lista de componentes creado a partir de la lista de adyacencias A
listasComponentesD([], []).
listasComponentesD([X|Xr], digrafo(Z,Zr)) :-
    listasCompAuxD([X|Xr], [[],[]], [Z,Zr]).
listasCompAuxD([], [A, Ar], [A, Ar]).
listasCompAuxD([X|Xr], [A, Ar], [R, Rr]) :-
    adyacenciasD(X, A, Ar, B, Br),
    listasCompAuxD(Xr, [B, Br], [R, Rr]).
    
adyacenciasD([], N, A, N, A).
adyacenciasD(ad(N,A), X, Xr, R, Rr) :-
    (   miembro(N,X)  ->  append(X,[],Y);append(X, [N], Y)   ),
    revisa(A, Y, R),
    producto([N], A, P1),
    toArco(P1,P),
	append(Xr, P, Rr).

revisaD([], P, P).
revisaD([A|Ar], P, R) :-
    (   miembro(A,P)  ->  append([], P, X); append([A],P,X)   ),
    revisaD(Ar, X, R).

%componentesListas/2(+C,-L) -> L es el grafo dirigido con lista de adyacencia creado a partir de los componentes del grafo C
componentesListasD(digrafo(Ns,As),AL) :- memberchk(arco(_,_,_),As), !,
   componentesListasDAux(Ns,As,AL).
componentesListasD(digrafo(Ns,As),AL) :-
   componentesListasDAux2(Ns,As,AL).

componentesListasDAux([],_,[]).
componentesListasDAux([V|Vs],As,[adj(V,L)|Ns]) :-
   findall(T,(member(arco(V,X,I),As), T=X/I),L), componentesListasDAux(Vs,As,Ns).

componentesListasDAux2([],_,[]).
componentesListasDAux2([V|Vs],As,[adj(V,L)|Ns]) :-
   findall(X,member(arco(V,X),As),L), componentesListasDAux2(Vs,As,Ns).

% arcosComponentes/2(+A,-C) -> C es el grafo con lista de componentes creado a partir de los arcos A
arcosComponentesD([], []).
arcosComponentesD(C, digrafo(Rn,Ra)) :-
    arcosComponentesAuxD(C, [], [], Rn, Ra).
    
arcosComponentesAuxD([], An, Aa, An, Aa).
arcosComponentesAuxD([O > D|Or], An, Aa, Rn, Ra) :-
    (   miembro(O,An)  ->  append(An, [], Y);append(An, [O], Y)   ),
    (   miembro(D,An)  ->  append(Y, [], Xn);append(Y, [D], Xn)   ),
    (   miembro([O, D],Aa)  ->  append(Aa, [], Xa);append(Aa, [arco(O,D)], Xa)   ),
    arcosComponentesAuxD(Or, Xn, Xa, Rn, Ra),!.
arcosComponentesAuxD([O|Or], An, Aa, Rn, Ra) :-
    (   miembro(O,An)  ->  append(An, [], Xn);append(An, [O], Xn)   ),
    arcosComponentesAuxD(Or, Xn, Aa, Rn, Ra),!.

% componentesArcosD/2(+C, -A) -> A es el grafo con arcos creado a partir de la lista de componentes C
componentesArcosD([], []).
componentesArcosD(digrafo(An, Aa), R) :-
    componentesArcosAD(Aa, [], [], Rn, X),
    componentesArcosND(An, Rn, X, R).

componentesArcosAD([], An, Aa, An, Aa).
componentesArcosAD([arco(A,B)|Ar], An, Aa, Rn, Ra) :-
    (   miembro(A,An)  ->  append(An, [], Y);append(An, [A], Y)   ),
    (   miembro(B,Y)  ->  append(Y, [], Z);append(Y, [B], Z)   ),
    (   miembro(A-B,Aa)  ->  append(Aa, [], X);append(Aa, [A > B], X)   ),
    componentesArcosAD(Ar, Z, X, Rn, Ra).

componentesArcosND([], _, X, X).
componentesArcosND([A|Ar], An, Aa, R) :-
    (   miembro(A,An)  ->  append(Aa, [], Y);append(Aa, [A], Y)   ),
    componentesArcosND(Ar, An, Y, R).

% -------- FUNCIONES AUXILIARES -------- %
producto(A, B, AxB):-
    findall([Ea,Eb], (member(Ea,A),member(Eb,B)), AxB).

toArco(P, A) :-
	toArcoAux(P,[],A).

toArcoAux([],A,A).
toArcoAux([[N1,N2]|Pr], A, R):-
    append(A, [arco(N1,N2)], X),
    toArcoAux(Pr, X, R).

miembro(X, [X|_]).			% si X es el elementos de la cabeza,
miembro(X, [_|R]) :-			% es miembro; en otro caso,
   miembro(X, R).			% lo buscamos en la cola

