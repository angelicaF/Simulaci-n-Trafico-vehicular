;Built in NetLogo 5.2.1

globals [ CarroEnf CarrosTransitados Desaceleracion VelocidadMax VelocidadMin VelocidadMaxAdentro VelocidadMaxAfuera DistanciaRotDirecto
  DistanciaRotIzquierda DistanciaRotDerecha GradosPorM RadioRot DesacelerEntRot DistanciaRotRecta DistanciaAlCentro TiempoReaccion Pos]
breed [ carros carro ]
turtles-own [ velocidad distanciaRot direccion ]

to setup
  clear-all
  set CarrosTransitados 0
  ; 100 ticks por segundo
  set Aceleracion 0.0005 ; 5 m/s^2
  set Desaceleracion 0.0005 ; 5 m/s^2
  set VelocidadMax  0.16666667 ; 60km/h, 16,6667 m/s
  set VelocidadMin  1.e-9
  set VelocidadMaxAdentro  VelocidadMax * 0.5  ; la mitad de la velocidad normal
  set VelocidadMaxAfuera  VelocidadMax * 0.62  ; 62% de la velocidad normal
  set DistanciaRotDirecto 34.77
  set DistanciaRotIzquierda 58.34
  ;set DistanciaRotDerecha 35.2
  set DistanciaRotDerecha 9.9
  set GradosPorM 3.81972
  set RadioRot sqrt (15 ^ 2 - 6 ^ 2)
  set DesacelerEntRot (VelocidadMax ^ 2 - VelocidadMaxAdentro ^ 2) / (2 * (Desaceleracion))
  set DistanciaRotRecta DesacelerEntRot + RadioRot
  set DistanciaAlCentro sqrt (DistanciaRotRecta ^ 2 + 6 ^ 2)
  set SeparacionMin 8; asuma el tamaño de carro = 3m y separacion = 5m
  set TiempoReaccion 100; 100 ticks = 1s es el tiempo de reaccion
  set Pos 0;

  create-carros NumCarros
  [
    set color (random 3 * 40 + 15) ; 15=rojo=derecha, 55=verde=directo, 95=azul=izquierda
    set shape "car"
    set size 5
    set velocidad VelocidadMax - random-float .1
    set distanciaRot 0
    set direccion 0
    distribuir-carros
  ]
  set CarroEnf one-of carros
  watch CarroEnf
  ask patches
  [
    if (pxcor ^ 2 + pycor ^ 2 < 20 ^ 2) and (pxcor ^ 2 + pycor ^ 2 > 10 ^ 2)
    [
      set pcolor grey
    ]

      if abs (pxcor) > 10 and abs (pxcor) < 20 and (pxcor ^ 2 + pycor ^ 2 > 20 ^ 2)
    [
      set pcolor grey
    ]

    if abs (pxcor) > 1 and abs (pxcor) < 11 and (pxcor ^ 2 + pycor ^ 2 > 30 ^ 2)
    [
      set pcolor white
    ]

    if abs (pxcor) > 1 and abs (pxcor) < 10 and (pxcor ^ 2 + pycor ^ 2 > 10 ^ 2)
    [
      set pcolor grey
    ]

    if abs (pycor) > 1 and abs (pycor) < 20 and (pxcor ^ 2 + pycor ^ 2 > 10 ^ 2)
    [
      set pcolor grey
    ]

     if abs (pycor) > 1 and abs (pycor) < 10 and (pxcor ^ 2 + pycor ^ 2 > 30 ^ 2)
    [
      set pcolor white
    ]
     if abs (pycor) > 1 and abs (pycor) < 9 and (pxcor ^ 2 + pycor ^ 2 > 30 ^ 2)
    [
      set pcolor grey
    ]
    if ((abs (pxcor) - 44 < pycor) and (abs (pxcor) - 30 > pycor) and abs (pxcor) > 1 and pycor < -1)
    [
      set pcolor grey
    ]
    if (( (- pxcor) + 44 > pycor) and ( (- pxcor) + 30 < pycor) and (pxcor) > 1 and pycor > 1)
    [
      set pcolor grey
    ]
    if (( ( pxcor) + 44 > pycor) and ( ( pxcor) + 30 < pycor) and  (pxcor) < -1 and pycor > 1)
    [
      set pcolor grey
    ]
;    if ((pxcor = -85) and (pycor = -5))
;    [
;      set pcolor yellow
;    ]
  ]
  reset-ticks
end

to distribuir-carros  ;; procedure
  set heading random 4 * 90
  if (heading = 0)
    [setxy 6 (38 + random (max-pycor - 38)) * (2 * random 2 - 1)
      if (color = red)
      [set xcor (xcor + 9)]
    ]
  if (heading = 90)
    [setxy ((38 + random (max-pxcor - 38)) * (2 * random 2 - 1)) -6
      if (color = red)
      [set ycor (ycor - 9)]
    ]
  if (heading = 180)
    [setxy -6 ((38 + random (max-pycor - 38)) * (2 * random 2 - 1))
      if (color = red)
      [set xcor (xcor - 9)]
    ]
  if (heading = 270)
    [setxy ((38 + random (max-pxcor - 38)) * (2 * random 2 - 1)) 6
      if (color = red)
      [set ycor (ycor + 9)]
    ]
  if any? other turtles-here
    [ distribuir-carros ]
  
   
   
end

to go
  ask carros [avance]
  tick
  ;if ticks > 30000 [stop]
end

to avance
  let miDir heading
  set direccion (subtract-headings miDir (towardsxy 0 0))
  let dist00 distancexy 0 0
  ifelse color = red and dist00 < 26.7;31.7
  [
    porfuera
  ]
  [
    ifelse dist00 <= 15
    [
      pordentro
    ]
    [
      porpista
    ]
  ]
  ;plot [velocidad] of CarroEnf * 360 ; pasa de m/s a km/h
end

to porfuera
  ;  if [ pcolor ] of patch-ahead 23 != grey
  if direccion > 0 and direccion < 45 ; Empieza giro a la derecha
  [
    set CarrosTransitados CarrosTransitados + 1
    set distanciaRot 0
    rt 45
  ]
  ifelse distanciaRot < DistanciaRotDerecha
  [
    let miDir heading
    let d DistanciaRotDerecha - distanciaRot
    ifelse d > 12
    [
      let t d / velocidad
      let carros45Grados carros with [(subtract-headings heading miDir = 45) and (distance myself < 52.35)]
      let carrosEntrantes carros45Grados with [(distancexy 0 0) + velocidad * t > 15 and (distancexy 0 0)  + velocidad * t < 46.39]
      ifelse any? carrosEntrantes
      [
        let desaceleraParada (velocidad ^ 2 / (2 * (d - 12)))
        set velocidad velocidad - desaceleraParada
      ]
      [
        set velocidad velocidad + Aceleracion
      ]
    ]
    [
      set velocidad velocidad + Aceleracion
    ]
    if (velocidad > VelocidadMaxAfuera) [set velocidad VelocidadMaxAfuera]
    if (velocidad < VelocidadMin) [set velocidad VelocidadMin]

    ;    plot [velocidad] of CarroEnf * 3.6 ; pasa de m/s a km/h
    fd velocidad
    set distanciaRot distanciaRot + velocidad
  ]
  [
    ;    plot [velocidad] of CarroEnf * 3.6 ; pasa de m/s a km/h
    rt 45
    fd velocidad
    set distanciaRot 0
    coordinaDireccion
  ]
end

to pordentro
  ;  if [ pcolor ] of patch-ahead 5 != grey
  if distanciaRot = 0 ; empieza el ingreso a la rotonda para ir directo o a la izquierda
  [
    set CarrosTransitados CarrosTransitados + 1
    set velocidad VelocidadMaxAdentro
    set distanciaRot 0.00001 ; empieza rotonda
    rt 66.422
  ]
  ifelse ((color = sky and distanciaRot < DistanciaRotIzquierda ) or (color = green and distanciaRot < DistanciaRotDirecto ))
  [
    let carrosRotonda other carros with [distancexy 0 0 < 15]
    fd velocidad
    lt velocidad * GradosPorM
    set distanciaRot distanciaRot + velocidad
    let d distancexy 0 0 / 14.9999
    setxy (xcor / d) (ycor / d)
  ]  
  [
    ;    plot [velocidad] of CarroEnf * 3.6 ; pasa de m/s a km/h
    rt 66.422
    fd velocidad
    set distanciaRot 0
    coordinaDireccion
  ]
end

to porpista
  let miDir heading
  let distCentro (distancexy 0 0)
  let velocidad1 velocidad;; guarda la velocidad inicial para su uso posterior
  
  if(xcor > -85 and xcor < -80  and ycor = -6)[
      if(color = red)
      [
        if(heading = 90)[
;          let carrosMismaDir1 other carros with [heading = miDir]
;          ifelse any? carrosMismaDir1
;          [
;            let carrosLado other carrosMismaDir1 with [(towards myself) != miDir and (xcor = ([xcor] of myself) and ycor != (-15))]
;            ifelse any? carrosLado
;            [
;              set color yellow
;              
;            ]
;            [
;              set ycor -15
;            ]
;            
;          ][]  
         ;set pcolor yellow
        ;stop
        set ycor -15  
        ]       
      ]
        
   ]

  
  if ( distCentro > 15)
  [

    let distSeparacion SeparacionMin + velocidad * TiempoReaccion
    let carrosMismaDir other carros with [heading = miDir]
    ifelse any? carrosMismaDir
    [
      let carrosFrente other carrosMismaDir with [(distance myself) != 0 and (towards myself) != miDir and (xcor = ([xcor] of myself) or ycor = ([ycor] of myself))]
      ifelse any? carrosFrente
      [
        let carroMasCerca (min-one-of carrosFrente [distance myself])
        let distCarroMasCerca distance carroMasCerca
        let velCarroMasCerca [velocidad] of carroMasCerca
        ifelse distCarroMasCerca < distSeparacion
        [
          if velocidad >= velCarroMasCerca
          [
            set velocidad velocidad - Desaceleracion
          ]
          if distCarroMasCerca < SeparacionMin
          [
            set velocidad velocidad - Desaceleracion
            if velocidad >= velCarroMasCerca
            [ set velocidad velCarroMasCerca - Desaceleracion ]
          ]
        ]
        [ set velocidad velocidad + Aceleracion ] ; fin carroMasCerca
      ]
      [ set velocidad velocidad + Aceleracion ] ; fin carrosFrente
    ]
    [ set velocidad velocidad + Aceleracion ] ; fin carrosMismaDir
  ] ; fin distancexy 0 0
    ;  if ( (distancexy 0 0) > 15 and (distancexy 0 0) < 16.7)
    ; [
    ;  let carros-45degree carros with [(subtract-headings heading miDir = -45) ]
    ;  ]
  if ( distCentro > 25 and distCentro < 50 )
  [
    let d distCentro - 25
    let t d / velocidad
    let carrosRotonda carros with [(distancexy 0 0) <= 15]
    let carrosEntrantes carrosRotonda with [(subtract-headings heading miDir > 0 )]
    if any? carrosEntrantes
    [
      let desaceleraParada (velocidad ^ 2 / (2 * d))
      set velocidad velocidad - desaceleraParada
    ]

  ]
  let vmax VelocidadMax
  if (distCentro < DistanciaAlCentro)
  [
    let velocidad2 velocidad ; guarda el valor calculado de velocidad
    set velocidad velocidad1 ; restaura la velocidad inicial
    ifelse color = red
    [
      let d sqrt ( distCentro ^ 2 - 36) - 31 + DistanciaRotDerecha
      let t d / velocidad
      let carrosPerpend carros with [(subtract-headings heading miDir = 90) and (subtract-headings (towards myself) miDir < 0)]
      let carrosEntrantes carrosPerpend with [(distancexy 0 0) + velocidad * t > 15 and (distancexy 0 0)  + velocidad * t < 46.39]
      ifelse any? carrosEntrantes
      [
        let desaceleraParada (velocidad ^ 2 / (2 * (d - 12)))
        set velocidad velocidad - desaceleraParada
      ]
      [
        set velocidad velocidad + Aceleracion
      ]
      if (velocidad > velocidad2) [set velocidad velocidad2]
    ]
    [
      set velocidad velocidad2
    ]
    let distDesdeRot sqrt(distCentro ^ 2 - 36) - RadioRot ; RadioRot = sqrt(15^2+6^2)
    set vmax sqrt(VelocidadMax ^ 2 - 2 * Desaceleracion * (DesacelerEntRot - distDesdeRot)) ; DesacelerEntRot = (v^2 - v0^2)/(2a)
  ]
  if vmax > VelocidadMax
  [
    set vmax VelocidadMax
  ]
  if velocidad > vmax
  [
    set velocidad vmax
  ]
  if velocidad < VelocidadMin
  [
    set velocidad VelocidadMin
  ]
  forward velocidad
end

to coordinaDireccion
  if (heading > 355 or heading < 5)
  [
    set heading 0
    ifelse (color = red)
    [set xcor 15]
    [set xcor 6]
  ]
  if (heading > 85 and heading < 95)
  [
    set heading 90
    ifelse (color = red)
    [
      set Pos random (100)
      ifelse(Pos < 50)[       
        set ycor -15        
      ]
     [
       set ycor -6  
     ]
    ]
    [set ycor -6]
  ]
  if (heading > 175 and heading < 185)
  [
    set heading 180
    ifelse (color = red)
    [set xcor -15]
    [set xcor -6]
  ]
  if (heading > 265 and heading < 275)
  [
    set heading 270
    ifelse (color = red)
    [set ycor 15]
    [set ycor 6]
  ]
end
