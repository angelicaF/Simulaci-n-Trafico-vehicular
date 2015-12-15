;Built in NetLogo 5.2.1

globals [ CarroEnf CarrosTransitados Desaceleracion VelocidadMax VelocidadMin VelocidadMaxAdentro VelocidadMaxAfuera DistanciaRotDirecto
  DistanciaRotIzquierda DistanciaRotDerecha GradosPorM RadioRot DesacelerEntRot DistanciaRotRecta DistanciaAlCentro TiempoReaccion Pos]
breed [ carros carro ]
turtles-own [ velocidad distanciaRot direccion espera carril]

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
    set espera 0
    set carril 0
  ]
  set CarroEnf one-of carros
  ;watch CarroEnf
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
    if ((pycor = -30) and (pxcor = 30))
    [
      set pcolor yellow
    ]
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

to seleccionaRegla
  if(Regla = "Cambia cuando hay mucha presa")[
    presa
    ;set color  black
  ]
  if(Regla = "Cambia cuando llega al final")[
    final
    ;set color  yellow
  ]
  if(Regla = "Cambia apenas pueda")[
    cambio
    ;set color  white
  ]
end



to avance
  let miDir heading
  set direccion (subtract-headings miDir (towardsxy 0 0))
  let dist00 distancexy 0 0
  ifelse(carril = 0)[
    ;coloca los carros rojos en los carriles antes de entrar a la pista
    if(ycor < -120 and heading = 0)[
      set Pos random (100)
      ifelse(Pos < 50)
      [
        set xcor 15
      ]
      [
        set xcor 6
      ]
      set carril 1
    ]
    if(xcor < -120 and heading = 90)[
      set Pos random (100)
      ifelse(Pos < 50)
      [
        set ycor -15
      ]
      [
        set ycor -6
      ]
      set carril 1
    ]
    if(ycor > 120 and heading = 180)[
      set Pos random (100)
      ifelse(Pos < 50)
      [
        set xcor -15
      ]
      [
        set xcor -6
      ]
      set carril 1
    ]
    if(xcor > 120 and heading = 270)[
      set Pos random (100)
      ifelse(Pos < 50)
      [
        set ycor 15
      ]
      [
        set ycor 6
      ]
      set carril 1
    ]
    ;fin coloca rojos
  ]
  [ ;else carril = 0
    if(ycor >= -115 and heading = 0)[
      set carril 0
    ]
    if(xcor >= -115 and heading = 90)[
      set carril 0
    ]
    if(ycor <= 115 and heading = 180)[
      set carril 0
    ]
    if(xcor <= 115 and heading = 270)[
      set carril 0
    ]
  ]

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

    fd velocidad
    set distanciaRot distanciaRot + velocidad
  ]
  [
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
  ; guarda la velocidad inicial para su uso posterior
  let velocidad1 velocidad
  ; método que escoge una regla para utilizar para el cambio de carril dependiendo de la seleccionada por el usuario
  seleccionaRegla


  ifelse(espera = 0) [
    if ( distCentro > 15)
    [

      let distSeparacion SeparacionMin + velocidad * TiempoReaccion
      let carrosMismaDir other carros with [heading = miDir]
      ifelse any? carrosMismaDir
      [
        let carrosFrente1 other carrosMismaDir with [(distance myself) != 0 and (towards myself) != miDir]
        let carrosFrente other carrosMismaDir with [(distance myself) != 0 and (towards myself) != miDir]
        ifelse(miDir = 0 or miDir = 180)[
          set carrosFrente other carrosFrente1 with [xcor = ([xcor] of myself)]
        ]
        [
          set carrosFrente other carrosFrente1 with [ycor = ([ycor] of myself)]
        ]
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
  ]
  ;esta esperando cambio de carril
  [
    set velocidad 0.01
    cambioEspera
  ]

  forward velocidad
end



to presa
  ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ; | EL CAMBIO DE CARRIL SE DA SI SE DETECTA QUE HAY PRESA, ES DECIR SI VA AVANZANDO MUY LENTAMENTE |
  ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  let miDir heading
  let distCentro (distancexy 0 0)
  ; guarda la velocidad inicial para su uso posterior
  let velocidad1 velocidad

  ;***********************ROJOS*******************************
  ;para que los carros  rojos de heading 0 se cambien de carril
  ifelse(ycor > -110 and ycor <= ((RadioRot * -1) - 12)  and xcor = 6)[
    if(color = red)
      [
        if(heading = 0)[
          ;set color pink
          if( velocidad1 < 0.02)[

            ;revisa que no haya un carro al lado para que se pueda cambiar de carril
            let carrosMismaDir1 other carros with [heading = miDir]
            ifelse any? carrosMismaDir1
            [
              let carrosLado other carrosMismaDir1 with [ ((([ycor] of myself) - ycor) < 6 and (([ycor] of myself) - ycor) > -6)    and xcor = 15]
              ifelse any? carrosLado
              [
                set xcor 6
                ;set espera 0
              ]
              [
                set xcor 15
                set espera 0
              ]
            ]
            [
              set xcor 15
              set espera 0
            ]
          ]
        ]
      ]
  ]
  ;caso en que se debe detener para hacer el cambio
  [
    if(ycor > ((RadioRot * -1) - 12) and color = red and xcor = 6) [
      set espera 1
    ]
  ]
  ;fin de para que los carros  rojos de heading 0 se cambien de carril

  ;para que los carros  rojos de heading 90 se cambien de carril
  ifelse(xcor > -110 and xcor <= ((RadioRot * -1) - 12)  and ycor = -6)[
    if(color = red)
      [
        if(heading = 90)[
          if( velocidad1 < 0.02)[
            ;revisa que no haya un carro al lado para que se pueda cambiar de carril
            let carrosMismaDir1 other carros with [heading = miDir]
            ifelse any? carrosMismaDir1
            [

              let carrosLado other carrosMismaDir1 with [((([xcor] of myself) - xcor) < 6 and (([xcor] of myself) - xcor) > -6)   and ycor = -15]
              ifelse any? carrosLado
              [
                set ycor  -6
                ;set espera 0
              ]
              [
                set ycor -15
                set espera 0
              ]

            ]
            [
              set ycor -15
              set espera 0
            ]
          ]
        ]
      ]
  ]
  ;caso en que se debe detener para hacer el cambio
  [
    if(xcor > ((RadioRot * -1) - 12) and color = red and ycor = -6) [
      set espera 1
    ]
  ]
  ;fin de para que los carros  rojos de heading 90 se cambien de carril


  ;para que los carros  rojos de heading 180 se cambien de carril
  ifelse(ycor >= (RadioRot + 12) and ycor < 110  and xcor = -6)[
    if(color = red)
      [
        if(heading = 180)[
          if( velocidad1 < 0.02)[
            ;revisa que no haya un carro al lado para que se pueda cambiar de carril
            let carrosMismaDir1 other carros with [heading = miDir]
            ifelse any? carrosMismaDir1
            [
              let carrosLado other carrosMismaDir1 with [ ((([ycor] of myself) - ycor) < 6 and (([ycor] of myself) - ycor) > -6)   and xcor = -15]
              ifelse any? carrosLado
              [
                set xcor  -6
                ;set espera 0
              ]
              [
                set xcor -15
                set espera 0
              ]

            ]
            [
              set xcor -15
              set espera 0
            ]
          ]
        ]
      ]
  ]
  ;caso en que se debe detener para hacer el cambio
  [
    if(ycor < (RadioRot + 12) and color = red and  xcor = -6) [
      set espera 1
    ]
  ]
  ;fin de para que los carros  rojos de heading 180 se cambien de carril


  ;para que los carros  rojos de heading 270 se cambien de carril
  ifelse(xcor >= (RadioRot + 12) and xcor < 110  and ycor = 6)[
    if(color = red)
      [
        if(heading = 270)[
          if( velocidad1 < 0.02)[
            ;revisa que no haya un carro al lado para que se pueda cambiar de carril
            let carrosMismaDir1 other carros with [heading = miDir]
            ifelse any? carrosMismaDir1
            [
              let carrosLado other carrosMismaDir1 with [ ((([xcor] of myself) - xcor) < 6 and (([xcor] of myself) - xcor) > -6) and ycor = 15]
              ifelse any? carrosLado
              [
                set ycor  6
                ;set espera 0
              ]
              [
                set ycor 15
                set espera 0
              ]
            ]
            [
              set ycor 15
              set espera 0
            ]
          ]
        ]
      ]
  ]
  ;caso en que se debe detener para hacer el cambio
  [
    if(xcor < (RadioRot + 12) and color = red and ycor = 6) [
      set espera 1
    ]
  ]
  ;fin de para que los carros  rojos de heading 270 se cambien de carril


  ;***********************AZULES Y VERDES*******************************
  ;para que los carros azules y verdes de heading 0 se cambien de carril
  ifelse(ycor > -110 and ycor <= ((RadioRot * -1) - 12)  and xcor = 15)[
    if(color = sky or color = green)
      [
        if(heading = 0)[
          if( velocidad1 < 0.02)[
            ;revisa que no haya un carro al lado para que se pueda cambiar de carril
            let carrosMismaDir1 other carros with [heading = miDir]
            ifelse any? carrosMismaDir1
            [
              let carrosLado other carrosMismaDir1 with [ ((([ycor] of myself) - ycor) < 6 and (([ycor] of myself) - ycor) > -6)  and xcor = 6]
              ifelse any? carrosLado
              [
                set xcor 15
                ;set espera 0
              ]
              [
                set xcor 6
                set espera 0
              ]

            ]
            [
              set xcor 6
              set espera 0
            ]
          ]
        ]
      ]
  ]
  ;caso en que se debe detener para hacer el cambio
  [
    if(ycor > ((RadioRot * -1) - 12) and color != red and xcor = 15) [
      set espera 1
    ]
  ]
  ;fin de para que los carros azules y verdes de heading 0 se cambien de carril

  ;para que los carros azules y verdes de heading 90 se cambien de carril
  ifelse(xcor > -110 and xcor <= ((RadioRot * -1) - 12)  and ycor = -15)[
    if(color = sky or color = green)
      [
        if(heading = 90)[
          if( velocidad1 < 0.02)[
            ;revisa que no haya un carro al lado para que se pueda cambiar de carril
            let carrosMismaDir1 other carros with [heading = miDir]
            ifelse any? carrosMismaDir1
            [
              let carrosLado other carrosMismaDir1 with [((([xcor] of myself) - xcor) < 6 and (([xcor] of myself) - xcor) > -6)   and ycor = -6]
              ifelse any? carrosLado
              [
                set ycor  -15
                ;set espera 0
              ]
              [
                set ycor -6
                set espera 0
              ]

            ]
            [
              set ycor -6
              set espera 0
            ]
          ]
        ]
      ]
  ]
  ;caso en que se debe detener para hacer el cambio
  [
    if(xcor > ((RadioRot * -1) - 12) and color != red and ycor = -15) [
      set espera 1
    ]
  ]
  ;fin de para que los carros azules y verdes de heading 90 se cambien de carril

  ;para que los carros azules y verdes de heading 180 se cambien de carril
  ifelse(ycor >= (RadioRot + 12) and ycor < 110  and xcor = -15)[
    if(color = sky or color = green)
      [
        if(heading = 180)[
          if( velocidad1 < 0.02)[
            ;revisa que no haya un carro al lado para que se pueda cambiar de carril
            let carrosMismaDir1 other carros with [heading = miDir]
            ifelse any? carrosMismaDir1
            [
              let carrosLado other carrosMismaDir1 with [ ((([ycor] of myself) - ycor) < 6 and (([ycor] of myself) - ycor) > -6)    and xcor = -6]
              ifelse any? carrosLado
              [
                set xcor  -15
                ;set espera 0
              ]
              [
                set xcor -6
                set espera 0
              ]

            ]
            [
              set xcor -6
              set espera 0
            ]
          ]
        ]
      ]
  ]
  ;caso en que se debe detener para hacer el cambio
  [
    if(ycor < (RadioRot + 12) and color != red and xcor = -15) [
      set espera 1
    ]
  ]
  ;fin de para que los carros azules y verdes de heading 180 se cambien de carril


  ;para que los carros azules y verdes de heading 270 se cambien de carril
  ifelse(xcor >= (RadioRot + 12) and xcor < 110  and ycor = 15)[
    if(color = sky or color = green)
      [
        if(heading = 270)[
          if( velocidad1 < 0.02)[
            ;revisa que no haya un carro al lado para que se pueda cambiar de carril
            let carrosMismaDir1 other carros with [heading = miDir]
            ifelse any? carrosMismaDir1
            [
              let carrosLado other carrosMismaDir1 with [ ((([xcor] of myself) - xcor) < 6 and (([xcor] of myself) - xcor) > -6)  and ycor = 6]
              ifelse any? carrosLado
              [
                set ycor  15
                ;set espera 0
              ]
              [
                set ycor 6
                set espera 0
              ]
            ]
            [
              set ycor 6
              set espera 0
            ]
          ]
        ]
      ]
  ]
  ;caso en que se debe detener para hacer el cambio
  [
    if(xcor < (RadioRot + 12) and color != red and ycor = 15) [
      set espera 1
    ]
  ]
  ;fin de para que los carros azules y verdes de heading 270 se cambien de carril

end


to final
  ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ; | EL CAMBIO DE CARRIL SE DA JUSTO ANTES DE ENTRAR A LA ROTONDA |
  ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  let miDir heading
  let distCentro (distancexy 0 0)
  ; guarda la velocidad inicial para su uso posterior
  let velocidad1 velocidad

  ;***********************ROJOS*******************************
  ;para que los carros  rojos de heading 0 se cambien de carril
  ifelse(ycor > ((RadioRot * -1) - 40) and ycor <= ((RadioRot * -1) - 12)  and xcor = 6)[
    if(color = red)
      [
        if(heading = 0)[
          ;set color pink

          ;revisa que no haya un carro al lado para que se pueda cambiar de carril
          let carrosMismaDir1 other carros with [heading = miDir]
          ifelse any? carrosMismaDir1
            [
              let carrosLado other carrosMismaDir1 with [ ((([ycor] of myself) - ycor) < 6 and (([ycor] of myself) - ycor) > -6)    and xcor = 15]
              ifelse any? carrosLado
              [
                set xcor 6
                ;set espera 0
              ]
              [
                set xcor 15
                set espera 0
              ]
            ]
            [
              set xcor 15
              set espera 0
            ]

        ]
      ]
  ]
  ;caso en que se debe detener para hacer el cambio
  [
    if(ycor > ((RadioRot * -1) - 12) and color = red and xcor = 6) [
      set espera 1
    ]
  ]
  ;fin de para que los carros  rojos de heading 0 se cambien de carril

  ;para que los carros  rojos de heading 90 se cambien de carril
  ifelse(xcor > ((RadioRot * -1) - 40) and xcor <= ((RadioRot * -1) - 12)  and ycor = -6)[
    if(color = red)
      [
        if(heading = 90)[
          ;revisa que no haya un carro al lado para que se pueda cambiar de carril
          let carrosMismaDir1 other carros with [heading = miDir]
          ifelse any? carrosMismaDir1
          [

            let carrosLado other carrosMismaDir1 with [((([xcor] of myself) - xcor) < 6 and (([xcor] of myself) - xcor) > -6)   and ycor = -15]
            ifelse any? carrosLado
            [
              set ycor  -6
              ;set espera 0
            ]
            [
              set ycor -15
              set espera 0
            ]

          ]
          [
            set ycor -15
            set espera 0
          ]
        ]

      ]
  ]
  ;caso en que se debe detener para hacer el cambio
  [
    if(xcor > ((RadioRot * -1) - 12) and color = red and ycor = -6) [
      set espera 1
    ]
  ]
  ;fin de para que los carros  rojos de heading 90 se cambien de carril


  ;para que los carros  rojos de heading 180 se cambien de carril
  ifelse(ycor >= (RadioRot + 12) and ycor < (RadioRot + 40)  and xcor = -6)[
    if(color = red)
      [
        if(heading = 180)[
          ;revisa que no haya un carro al lado para que se pueda cambiar de carril
          let carrosMismaDir1 other carros with [heading = miDir]
          ifelse any? carrosMismaDir1
            [
              let carrosLado other carrosMismaDir1 with [ ((([ycor] of myself) - ycor) < 6 and (([ycor] of myself) - ycor) > -6)   and xcor = -15]
              ifelse any? carrosLado
              [
                set xcor  -6
                ;set espera 0
              ]
              [
                set xcor -15
                set espera 0
              ]

            ]
            [
              set xcor -15
              set espera 0
            ]
        ]
      ]
  ]
  ;caso en que se debe detener para hacer el cambio
  [
    if(ycor < (RadioRot + 12) and color = red and  xcor = -6) [
      set espera 1
    ]
  ]
  ;fin de para que los carros  rojos de heading 180 se cambien de carril

  ;para que los carros  rojos de heading 270 se cambien de carril
  ifelse(xcor >= (RadioRot + 12)  and xcor < (RadioRot + 40)  and ycor = 6)[
    if(color = red)
      [
        if(heading = 270)[
          ;revisa que no haya un carro al lado para que se pueda cambiar de carril
          let carrosMismaDir1 other carros with [heading = miDir]
          ifelse any? carrosMismaDir1
          [
            let carrosLado other carrosMismaDir1 with [ ((([xcor] of myself) - xcor) < 6 and (([xcor] of myself) - xcor) > -6) and ycor = 15]
            ifelse any? carrosLado
            [
              set ycor  6
              ;set espera 0
            ]
            [
              set ycor 15
              set espera 0
            ]
          ]
          [
            set ycor 15
            set espera 0
          ]
        ]
      ]
  ]
  ;caso en que se debe detener para hacer el cambio
  [
    if(xcor < (RadioRot + 12) and color = red and ycor = 6) [
      set espera 1
    ]
  ]
  ;fin de para que los carros  rojos de heading 270 se cambien de carril

  ;***********************AZULES Y VERDES*******************************
  ;para que los carros azules y verdes de heading 0 se cambien de carril
  ifelse(ycor > ((RadioRot * -1) - 40) and ycor <= ((RadioRot * -1) - 12)  and xcor = 15)[
    if(color = sky or color = green)
      [
        if(heading = 0)[
          ;revisa que no haya un carro al lado para que se pueda cambiar de carril
          let carrosMismaDir1 other carros with [heading = miDir]
          ifelse any? carrosMismaDir1
            [
              let carrosLado other carrosMismaDir1 with [ ((([ycor] of myself) - ycor) < 6 and (([ycor] of myself) - ycor) > -6)  and xcor = 6]
              ifelse any? carrosLado
              [
                set xcor 15
                ;set espera 0
              ]
              [
                set xcor 6
                set espera 0
              ]

            ]
            [
              set xcor 6
              set espera 0
            ]
        ]
      ]
  ]
  ;caso en que se debe detener para hacer el cambio
  [
    if(ycor > ((RadioRot * -1) - 12) and color != red and xcor = 15) [
      set espera 1
    ]
  ]
  ;fin de para que los carros azules y verdes de heading 0 se cambien de carril

  ;para que los carros azules y verdes de heading 90 se cambien de carril
  ifelse(xcor > ((RadioRot * -1) - 40) and xcor <= ((RadioRot * -1) - 12)   and ycor = -15)[
    if(color = sky or color = green)
      [
        if(heading = 90)[
          ;revisa que no haya un carro al lado para que se pueda cambiar de carril
          let carrosMismaDir1 other carros with [heading = miDir]
          ifelse any? carrosMismaDir1
            [
              let carrosLado other carrosMismaDir1 with [((([xcor] of myself) - xcor) < 6 and (([xcor] of myself) - xcor) > -6)   and ycor = -6]
              ifelse any? carrosLado
              [
                set ycor  -15
                ;set espera 0
              ]
              [
                set ycor -6
                set espera 0
              ]

            ]
            [
              set ycor -6
              set espera 0
            ]
        ]
      ]
  ]
  ;caso en que se debe detener para hacer el cambio
  [
    if(xcor > ((RadioRot * -1) - 12) and color != red and ycor = -15) [
      set espera 1
    ]
  ]
  ;fin de para que los carros azules y verdes de heading 90 se cambien de carril

  ;para que los carros azules y verdes de heading 180 se cambien de carril
  ifelse(ycor >= (RadioRot + 12) and ycor < (RadioRot + 40)  and xcor = -15)[
    if(color = sky or color = green)
      [
        if(heading = 180)[
          ;revisa que no haya un carro al lado para que se pueda cambiar de carril
          let carrosMismaDir1 other carros with [heading = miDir]
          ifelse any? carrosMismaDir1
            [
              let carrosLado other carrosMismaDir1 with [ ((([ycor] of myself) - ycor) < 6 and (([ycor] of myself) - ycor) > -6)    and xcor = -6]
              ifelse any? carrosLado
              [
                set xcor  -15
                ;set espera 0
              ]
              [
                set xcor -6
                set espera 0
              ]

            ]
            [
              set xcor -6
              set espera 0
            ]
        ]
      ]
  ]
  ;caso en que se debe detener para hacer el cambio
  [
    if(ycor < (RadioRot + 12) and color != red and xcor = -15) [
      set espera 1
    ]
  ]
  ;fin de para que los carros azules y verdes de heading 180 se cambien de carril


  ;para que los carros azules y verdes de heading 270 se cambien de carril
  ifelse(xcor >= (RadioRot + 12)  and xcor < (RadioRot + 40)  and ycor = 15)[
    if(color = sky or color = green)
      [
        if(heading = 270)[
          ;revisa que no haya un carro al lado para que se pueda cambiar de carril
          let carrosMismaDir1 other carros with [heading = miDir]
          ifelse any? carrosMismaDir1
            [
              let carrosLado other carrosMismaDir1 with [ ((([xcor] of myself) - xcor) < 6 and (([xcor] of myself) - xcor) > -6)  and ycor = 6]
              ifelse any? carrosLado
              [
                set ycor  15
                ;set espera 0
              ]
              [
                set ycor 6
                set espera 0
              ]
            ]
            [
              set ycor 6
              set espera 0
            ]
        ]
      ]
  ]
  ;caso en que se debe detener para hacer el cambio
  [
    if(xcor < (RadioRot + 12) and color != red and ycor = 15) [
      set espera 1
    ]
  ]
  ;fin de para que los carros azules y verdes de heading 270 se cambien de carril


end

to cambio
  ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ; | EL CAMBIO DE CARRIL SE DA APENAS SE DETECTA QUE ESTA EN EL CARRIL EQUIVOCADO |
  ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  let miDir heading
  let distCentro (distancexy 0 0)
  ;guarda la velocidad inicial para su uso posterior
  let velocidad1 velocidad

  ;***********************ROJOS*******************************
  ;para que los carros  rojos de heading 0 se cambien de carril
  ifelse(ycor > -115 and ycor <= ((RadioRot * -1) - 12)  and xcor = 6)[
    if(color = red)
      [
        if(heading = 0)[
          ;revisa que no haya un carro al lado para que se pueda cambiar de carril
          let carrosMismaDir1 other carros with [heading = miDir]
          ifelse any? carrosMismaDir1
            [
              let carrosLado other carrosMismaDir1 with [ ((([ycor] of myself) - ycor) < 6 and (([ycor] of myself) - ycor) > -6)    and xcor = 15]
              ifelse any? carrosLado
              [
                set xcor 6
                ;set espera 0
              ]
              [
                set xcor 15
                set espera 0
              ]
            ]
            [
              set xcor 15
              set espera 0
            ]

        ]
      ]
  ]
  ;caso en que se debe detener para hacer el cambio
  [
    if(ycor > ((RadioRot * -1) - 12) and color = red and xcor = 6) [
      set espera 1
    ]
  ]
  ;fin de para que los carros  rojos de heading 0 se cambien de carril

  ;para que los carros  rojos de heading 90 se cambien de carril
  ifelse(xcor > -110 and xcor <= ((RadioRot * -1) - 12)  and ycor = -6)[
    if(color = red)
      [
        if(heading = 90)[
          ;revisa que no haya un carro al lado para que se pueda cambiar de carril
          let carrosMismaDir1 other carros with [heading = miDir]
          ifelse any? carrosMismaDir1
          [

            let carrosLado other carrosMismaDir1 with [((([xcor] of myself) - xcor) < 6 and (([xcor] of myself) - xcor) > -6)   and ycor = -15]
            ifelse any? carrosLado
            [
              set ycor  -6
              ;set espera 0
            ]
            [
              set ycor -15
              set espera 0
            ]

          ]
          [
            set ycor -15
            set espera 0
          ]
        ]

      ]
  ]
  ;caso en que se debe detener para hacer el cambio
  [
    if(xcor > ((RadioRot * -1) - 12) and color = red and ycor = -6) [
      set espera 1
    ]
  ]
  ;fin de para que los carros  rojos de heading 90 se cambien de carril

  ;para que los carros  rojos de heading 180 se cambien de carril
  ifelse(ycor >= (RadioRot + 12) and ycor < 110  and xcor = -6)[
    if(color = red)
      [
        if(heading = 180)[
          ;revisa que no haya un carro al lado para que se pueda cambiar de carril
          let carrosMismaDir1 other carros with [heading = miDir]
          ifelse any? carrosMismaDir1
            [
              let carrosLado other carrosMismaDir1 with [ ((([ycor] of myself) - ycor) < 6 and (([ycor] of myself) - ycor) > -6)   and xcor = -15]
              ifelse any? carrosLado
              [
                set xcor  -6
                ;set espera 0
              ]
              [
                set xcor -15
                set espera 0
              ]

            ]
            [
              set xcor -15
              set espera 0
            ]
        ]
      ]
  ]
  ;caso en que se debe detener para hacer el cambio
  [
    if(ycor < (RadioRot + 12) and color = red and  xcor = -6) [
      set espera 1
    ]
  ]
  ;fin de para que los carros  rojos de heading 180 se cambien de carril

  ;para que los carros  rojos de heading 270 se cambien de carril
  ifelse(xcor >= (RadioRot + 12) and xcor < 110  and ycor = 6)[
    if(color = red)
      [
        if(heading = 270)[
          ;revisa que no haya un carro al lado para que se pueda cambiar de carril
          let carrosMismaDir1 other carros with [heading = miDir]
          ifelse any? carrosMismaDir1
          [
            let carrosLado other carrosMismaDir1 with [ ((([xcor] of myself) - xcor) < 6 and (([xcor] of myself) - xcor) > -6) and ycor = 15]
            ifelse any? carrosLado
            [
              set ycor  6
              ;set espera 0
            ]
            [
              set ycor 15
              set espera 0
            ]
          ]
          [
            set ycor 15
            set espera 0
          ]
        ]
      ]
  ]
  ;caso en que se debe detener para hacer el cambio
  [
    if(xcor < (RadioRot + 12) and color = red and ycor = 6) [
      set espera 1
    ]
  ]
  ;fin de para que los carros  rojos de heading 270 se cambien de carril

  ;***********************AZULES Y VERDES*******************************
  ;para que los carros azules y verdes de heading 0 se cambien de carril
  ifelse(ycor > -115 and ycor <= ((RadioRot * -1) - 12)  and xcor = 15)[
    if(color = sky or color = green)
      [
        if(heading = 0)[
          ;revisa que no haya un carro al lado para que se pueda cambiar de carril
          let carrosMismaDir1 other carros with [heading = miDir]
          ifelse any? carrosMismaDir1
            [
              let carrosLado other carrosMismaDir1 with [ ((([ycor] of myself) - ycor) < 6 and (([ycor] of myself) - ycor) > -6)  and xcor = 6]
              ifelse any? carrosLado
              [
                set xcor 15
                ;set espera 0
              ]
              [
                set xcor 6
                set espera 0
              ]

            ]
            [
              set xcor 6
              set espera 0
            ]
        ]
      ]
  ]
  ;caso en que se debe detener para hacer el cambio
  [
    if(ycor > ((RadioRot * -1) - 12) and color != red and xcor = 15) [
      set espera 1
    ]
  ]
  ;fin de para que los carros azules y verdes de heading 0 se cambien de carril

  ;para que los carros azules y verdes de heading 90 se cambien de carril
  ifelse(xcor > -110 and xcor <= ((RadioRot * -1) - 12)  and ycor = -15)[
    if(color = sky or color = green)
      [
        if(heading = 90)[
          ;revisa que no haya un carro al lado para que se pueda cambiar de carril
          let carrosMismaDir1 other carros with [heading = miDir]
          ifelse any? carrosMismaDir1
            [
              let carrosLado other carrosMismaDir1 with [((([xcor] of myself) - xcor) < 6 and (([xcor] of myself) - xcor) > -6)   and ycor = -6]
              ifelse any? carrosLado
              [
                set ycor  -15
                ;set espera 0
              ]
              [
                set ycor -6
                set espera 0
              ]

            ]
            [
              set ycor -6
              set espera 0
            ]
        ]
      ]
  ]
  ;caso en que se debe detener para hacer el cambio
  [
    if(xcor > ((RadioRot * -1) - 12) and color != red and ycor = -15) [
      set espera 1
    ]
  ]
  ;fin de para que los carros azules y verdes de heading 90 se cambien de carril

  ;para que los carros azules y verdes de heading 180 se cambien de carril
  ifelse(ycor >= (RadioRot + 12) and ycor < 110  and xcor = -15)[
    if(color = sky or color = green)
      [
        if(heading = 180)[
          ;revisa que no haya un carro al lado para que se pueda cambiar de carril
          let carrosMismaDir1 other carros with [heading = miDir]
          ifelse any? carrosMismaDir1
            [
              let carrosLado other carrosMismaDir1 with [ ((([ycor] of myself) - ycor) < 6 and (([ycor] of myself) - ycor) > -6)    and xcor = -6]
              ifelse any? carrosLado
              [
                set xcor  -15
                ;set espera 0
              ]
              [
                set xcor -6
                set espera 0
              ]

            ]
            [
              set xcor -6
              set espera 0
            ]
        ]
      ]
  ]
  ;caso en que se debe detener para hacer el cambio
  [
    if(ycor < (RadioRot + 12) and color != red and xcor = -15) [
      set espera 1
    ]
  ]
  ;fin de para que los carros azules y verdes de heading 180 se cambien de carril


  ;para que los carros azules y verdes de heading 270 se cambien de carril
  ifelse(xcor >= (RadioRot + 12) and xcor < 110  and ycor = 15)[
    if(color = sky or color = green)
      [
        if(heading = 270)[
          ;revisa que no haya un carro al lado para que se pueda cambiar de carril
          let carrosMismaDir1 other carros with [heading = miDir]
          ifelse any? carrosMismaDir1
            [
              let carrosLado other carrosMismaDir1 with [ ((([xcor] of myself) - xcor) < 6 and (([xcor] of myself) - xcor) > -6)  and ycor = 6]
              ifelse any? carrosLado
              [
                set ycor  15
                ;set espera 0
              ]
              [
                set ycor 6
                set espera 0
              ]
            ]
            [
              set ycor 6
              set espera 0
            ]
        ]
      ]
  ]
  ;caso en que se debe detener para hacer el cambio
  [
    if(xcor < (RadioRot + 12) and color != red and ycor = 15) [
      set espera 1
    ]
  ]
  ;fin de para que los carros  azules y verdes de heading 270 se cambien de carril

end

;******************************************************MÉTODO PARA CAMBIAR DE CARRIL SI ESTÁ ESPERANDO********************************************************************
to cambioEspera
  ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ; | EL CAMBIO DE CARRIL SE DA SI SE DETECTA QUE HAY PRESA, ES DECIR SI VA AVANZANDO MUY LENTAMENTE |
  ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  let miDir heading
  let distCentro (distancexy 0 0)
  ; guarda la velocidad inicial para su uso posterior
  let velocidad1 velocidad

  ;***********************ROJOS*******************************
  ;para que los carros  rojos de heading 0 se cambien de carril
  if(xcor = 6 and color = red)[
    if(heading = 0)[
      ;set color pink
      ;revisa que no haya un carro al lado para que se pueda cambiar de carril
      let carrosMismaDir1 other carros with [heading = miDir]
      ifelse any? carrosMismaDir1
        [
          let carrosLado other carrosMismaDir1 with [ ((([ycor] of myself) - ycor) < 6 and (([ycor] of myself) - ycor) > -6)    and xcor = 15]
          ifelse any? carrosLado
            [
              set xcor 6
              ;set espera 0
            ]
            [
              set xcor 15
              set espera 0
            ]
        ]
        [
          set xcor 15
          set espera 0
        ]

    ]

  ]
  ;fin de para que los carros  rojos de heading 0 se cambien de carril

  ;para que los carros  rojos de heading 90 se cambien de carril
  if(ycor = -6 and color = red)[
    if(heading = 90)[

      ;revisa que no haya un carro al lado para que se pueda cambiar de carril
      let carrosMismaDir1 other carros with [heading = miDir]
      ifelse any? carrosMismaDir1
        [

          let carrosLado other carrosMismaDir1 with [((([xcor] of myself) - xcor) < 6 and (([xcor] of myself) - xcor) > -6)   and ycor = -15]
          ifelse any? carrosLado
            [
              set ycor  -6
              ;set espera 0
            ]
            [
              set ycor -15
              set espera 0
            ]

        ]
        [
          set ycor -15
          set espera 0
        ]

    ]

  ]
  ;fin de para que los carros  rojos de heading 90 se cambien de carril


  ;para que los carros  rojos de heading 180 se cambien de carril
  if(color = red  and xcor = -6)[
    if(heading = 180)[

      ;revisa que no haya un carro al lado para que se pueda cambiar de carril
      let carrosMismaDir1 other carros with [heading = miDir]
      ifelse any? carrosMismaDir1
        [
          let carrosLado other carrosMismaDir1 with [ ((([ycor] of myself) - ycor) < 6 and (([ycor] of myself) - ycor) > -6)   and xcor = -15]
          ifelse any? carrosLado
            [
              set xcor  -6
              ;set espera 0
            ]
            [
              set xcor -15
              set espera 0
            ]

        ]
        [
          set xcor -15
          set espera 0
        ]

    ]

  ]
  ;fin de para que los carros  rojos de heading 180 se cambien de carril


  ;para que los carros  rojos de heading 270 se cambien de carril
  if(color = red  and ycor = 6)[
    if(heading = 270)[

      ;revisa que no haya un carro al lado para que se pueda cambiar de carril
      let carrosMismaDir1 other carros with [heading = miDir]
      ifelse any? carrosMismaDir1
        [
          let carrosLado other carrosMismaDir1 with [ ((([xcor] of myself) - xcor) < 6 and (([xcor] of myself) - xcor) > -6) and ycor = 15]
          ifelse any? carrosLado
            [
              set ycor  6
              ;set espera 0
            ]
            [
              set ycor 15
              set espera 0
            ]
        ]
        [
          set ycor 15
          set espera 0
        ]

    ]

  ]
  ;fin de para que los carros  rojos de heading 270 se cambien de carril


  ;***********************AZULES Y VERDES*******************************
  ;para que los carros azules y verdes de heading 0 se cambien de carril
  if(color != red  and xcor = 15)[
    if(heading = 0)[

      ;revisa que no haya un carro al lado para que se pueda cambiar de carril
      let carrosMismaDir1 other carros with [heading = miDir]
      ifelse any? carrosMismaDir1
        [
          let carrosLado other carrosMismaDir1 with [ ((([ycor] of myself) - ycor) < 6 and (([ycor] of myself) - ycor) > -6)  and xcor = 6]
          ifelse any? carrosLado
            [
              set xcor 15
              ;set espera 0
            ]
            [
              set xcor 6
              set espera 0
            ]

        ]
        [
          set xcor 6
          set espera 0
        ]

    ]

  ]
  ;fin de para que los carros azules y verdes de heading 0 se cambien de carril

  ;para que los carros azules y verdes de heading 90 se cambien de carril
  if(color != red  and ycor = -15)[
    if(heading = 90)[

      ;revisa que no haya un carro al lado para que se pueda cambiar de carril
      let carrosMismaDir1 other carros with [heading = miDir]
      ifelse any? carrosMismaDir1
        [
          let carrosLado other carrosMismaDir1 with [((([xcor] of myself) - xcor) < 6 and (([xcor] of myself) - xcor) > -6)   and ycor = -6]
          ifelse any? carrosLado
            [
              set ycor  -15
              ;set espera 0
            ]
            [
              set ycor -6
              set espera 0
            ]

        ]
        [
          set ycor -6
          set espera 0
        ]

    ]

  ]
  ;fin de para que los carros azules y verdes de heading 90 se cambien de carril

  ;para que los carros azules y verdes de heading 180 se cambien de carril
  if(color != red  and xcor = -15)[
    if(heading = 180)[

      ;revisa que no haya un carro al lado para que se pueda cambiar de carril
      let carrosMismaDir1 other carros with [heading = miDir]
      ifelse any? carrosMismaDir1
        [
          let carrosLado other carrosMismaDir1 with [ ((([ycor] of myself) - ycor) < 6 and (([ycor] of myself) - ycor) > -6)    and xcor = -6]
          ifelse any? carrosLado
            [
              set xcor  -15
              ;set espera 0
            ]
            [
              set xcor -6
              set espera 0
            ]

        ]
        [
          set xcor -6
          set espera 0
        ]

    ]

  ]
  ;fin de para que los carros azules y verdes de heading 180 se cambien de carril


  ;para que los carros azules y verdes de heading 270 se cambien de carril
  if(color != red  and ycor = 15)[
    if(heading = 270)[

      ;revisa que no haya un carro al lado para que se pueda cambiar de carril
      let carrosMismaDir1 other carros with [heading = miDir]
      ifelse any? carrosMismaDir1
        [
          let carrosLado other carrosMismaDir1 with [ ((([xcor] of myself) - xcor) < 6 and (([xcor] of myself) - xcor) > -6)  and ycor = 6]
          ifelse any? carrosLado
            [
              set ycor  15
              ;set espera 0
            ]
            [
              set ycor 6
              set espera 0
            ]
        ]
        [
          set ycor 6
          set espera 0
        ]
    ]

  ]
  ;fin de para que los carros azules y verdes de heading 270 se cambien de carril
end


to coordinaDireccion
  if (heading > 355 or heading < 5)
  [
    set heading 0
    ifelse (color = red)
    [
      ;set xcor 15
    ]
    [set xcor 6]
  ]
  if (heading > 85 and heading < 95)
  [
    set heading 90
    ifelse (color = red)
    [
      ; set ycor -15
    ]
    [set ycor -6]
  ]
  if (heading > 175 and heading < 185)
  [
    set heading 180
    ifelse (color = red)
    [
      ;set xcor -15
    ]
    [set xcor -6]
  ]
  if (heading > 265 and heading < 275)
  [
    set heading 270
    ifelse (color = red)
    [
      ;set ycor 15
    ]
    [set ycor 6]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
230
10
725
526
120
120
2.01245
1
10
1
1
1
0
1
1
1
-120
120
-120
120
0
0
1
ticks
30.0

BUTTON
58
15
122
50
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
57
68
120
101
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
138
10
171
160
NumCarros
NumCarros
1
80
80
1
1
NIL
VERTICAL

PLOT
15
317
215
467
Velocidad
NIL
km/h
0.0
1.0
0.0
40.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot [velocidad] of CarroEnf * 360"

MONITOR
9
477
70
522
Direccion
[heading] of CarroEnf
2
1
11

MONITOR
759
27
831
72
carros/min
CarrosTransitados / ticks * 6000
0
1
11

MONITOR
846
27
967
72
Tránsito de Carros
CarrosTransitados
17
1
11

BUTTON
57
119
121
152
step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
18
167
212
200
Aceleracion
Aceleracion
0
0.002
5.0E-4
0.0001
1
x10⁴m/s²
HORIZONTAL

SLIDER
17
213
210
246
SeparacionMin
SeparacionMin
5
50
8
1
1
m
HORIZONTAL

MONITOR
762
152
960
197
Promedio total
(((sum [velocidad] of turtles) / (count turtles)) * 100) * 3.6
17
1
11

PLOT
763
202
960
336
Promedio total
NIL
km/h
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Promedio" 1.0 0 -7500403 true "" "plot (((sum [velocidad] of turtles) / (count turtles)) * 100) * 3.6"

PLOT
978
203
1175
335
Promedio rojos
NIL
km/h
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Promedio" 1.0 0 -16777216 true "" "plot (((sum [velocidad] of turtles with [color = red]) / (count turtles with [color = red])) * 100) * 3.6"

MONITOR
978
153
1176
198
Promedio rojos
(((sum [velocidad] of turtles with [color = red]) / (count turtles with [color = red])) * 100) * 3.6
17
1
11

MONITOR
763
345
961
390
Promedio verdes
(((sum [velocidad] of turtles with [color = green]) / (count turtles with [color = green])) * 100) * 3.6
17
1
11

PLOT
763
397
961
528
Promedio verdes
NIL
km/h
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot (((sum [velocidad] of turtles with [color = green]) / (count turtles with [color = green])) * 100) * 3.6"

MONITOR
978
345
1175
390
Promedio azules
(((sum [velocidad] of turtles with [color = sky]) / (count turtles with [color = sky])) * 100) * 3.6
17
1
11

PLOT
979
398
1174
529
Promedio azules
NIL
km/h
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot (((sum [velocidad] of turtles with [color = sky]) / (count turtles with [color = sky])) * 100) * 3.6"

TEXTBOX
832
93
1126
151
Promedios de Velocidad:
24
0.0
1

CHOOSER
18
258
212
303
Regla
Regla
"Cambia cuando hay mucha presa" "Cambia cuando llega al final" "Cambia apenas pueda"
0

BUTTON
81
482
224
515
Enfatizar Carro
watch CarroEnf
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

This section could give a general understanding of what the model is trying to show or explain.

## HOW IT WORKS

This section could explain what rules the agents use to create the overall behavior of the model.

## HOW TO USE IT

This section could explain how to use the model, including a description of each of the items in the interface tab.

## THINGS TO NOTICE

This section could give some ideas of things for the user to notice while running the model.

## THINGS TO TRY

This section could give some ideas of things for the user to try to do (move sliders, switches, etc.) with the model.

## EXTENDING THE MODEL

This section could give some ideas of things to add or change in the procedures tab to make the model more complicated, detailed, accurate, etc.

## NETLOGO FEATURES

This section could point out any especially interesting or unusual features of NetLogo that the model makes use of, particularly in the Procedures tab.  It might also point out places where workarounds were needed because of missing features.

## RELATED MODELS

This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.

## CREDITS AND REFERENCES

This section could contain a reference to the model's URL on the web if it has one, as well as any other necessary credits or references.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.2.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
