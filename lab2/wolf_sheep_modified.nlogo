globals [
  max-sheep            
  sheep-fear-radius     
]

breed [ sheep a-sheep ]
breed [ wolves wolf ]

turtles-own [
  energy                
]

patches-own [
  countdown             
]

to setup
  clear-all

  ifelse netlogo-web?
  [ set max-sheep 10000 ]
  [ set max-sheep 30000 ]

  set sheep-fear-radius 2

  ;; настройка травы
  ifelse model-version = "sheep-wolves-grass" [
    ask patches [
      set pcolor one-of [ green brown ]
      ifelse pcolor = green
      [ set countdown grass-regrowth-time ]
      [ set countdown random grass-regrowth-time ]
    ]
  ]
  [
    ask patches [ set pcolor green ]
  ]

  create-sheep initial-number-sheep [
    set shape "sheep"
    set color white
    set size 1.5
    set energy random (2 * sheep-gain-from-food)
    setxy random-xcor random-ycor
  ]

  create-wolves initial-number-wolves [
    set shape "wolf"
    set color black
    set size 2
    set energy random (2 * wolf-gain-from-food)
    setxy random-xcor random-ycor
  ]

  display-labels
  reset-ticks
end

to go
  if not any? turtles [ stop ]

  if not any? wolves and count sheep > max-sheep [
    user-message "The sheep have inherited the earth"
    stop
  ]

  ask sheep [
    move-sheep

    if model-version = "sheep-wolves-grass" [
      set energy energy - 1
      eat-grass
      death
    ]

    reproduce-sheep
  ]

  ask wolves [
    move-wolf
    set energy energy - 1
    eat-sheep
    death
    reproduce-wolves
  ]

  ask wolves [
    resolve-wolf-collision
  ]

  if model-version = "sheep-wolves-grass" [
    ask patches [ grow-grass ]
  ]

  tick
  display-labels
end

to move
  rt random 50
  lt random 50
  fd 1
end

to move-sheep
  rt random 50
  lt random 50

  let danger one-of wolves in-radius sheep-fear-radius
  if danger != nobody [
    face danger
    rt 180              
  ]

  fd 1
end

to move-wolf
  let nearby-sheep sheep in-radius 3
  let target-sheep nearby-sheep with [ not any? wolves-here ]

  if any? target-sheep [
    face one-of target-sheep
  ]

  if not any? target-sheep [
    let safe-patches patches in-radius 3 with [ not any? wolves-here ]
    if any? safe-patches [
      face one-of safe-patches
    ]

    ;; 3. если ничего нет — случайный шаг
    if not any? safe-patches [
      rt random 50
      lt random 50
    ]
  ]

  fd 1
end

to resolve-wolf-collision
  let others other wolves-here
  if any? others [
    if who > min [who] of wolves-here [
      die
    ]
  ]
end

to eat-grass
  if pcolor = green [
    set pcolor brown
    set energy energy + sheep-gain-from-food
  ]
end

to eat-sheep
  let prey one-of sheep-here
  if prey != nobody [
    ask prey [ die ]
    set energy energy + wolf-gain-from-food
  ]
end

to reproduce-sheep
  if random-float 100 < sheep-reproduce [
    set energy (energy / 2)
    hatch 1 [ rt random-float 360 fd 1 ]
  ]
end

to reproduce-wolves
  if random-float 100 < wolf-reproduce [
    set energy (energy / 2)
    hatch 1 [ rt random-float 360 fd 1 ]
  ]
end

to death
  if energy < 0 [ die ]
end

to grow-grass
  if pcolor = brown [
    ifelse countdown <= 0 [
      set pcolor green
      set countdown grass-regrowth-time
    ]
    [
      set countdown countdown - 1
    ]
  ]
end

to-report grass
  ifelse model-version = "sheep-wolves-grass" [
    report patches with [pcolor = green]
  ]
  [
    report 0
  ]
end

to display-labels
  ask turtles [ set label "" ]
  if show-energy? [
    ask wolves [ set label round energy ]
    if model-version = "sheep-wolves-grass" [
      ask sheep [ set label round energy ]
    ]
  ]
end
