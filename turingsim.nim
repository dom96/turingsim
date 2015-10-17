import tables, terminal, strutils
type
  Direction = enum
    R, L, C
  Quintuple = tuple[currState: string, currInput: char, nextState: string,
                    output: char, direction: Direction]
  TransitionInput = tuple[currState: string, currInput: char]
  TransitionOutput = tuple[nextState: string, output: char,
                           direction: Direction]
  Transitions = Table[TransitionInput, TransitionOutput]

  TuringMachine = ref object
    tape: array[-1000 .. 1000, char]
    tapeLoc: range[-1000 .. 1000]
    currState: string
    transitions: Transitions

  TuringError = object of Exception

proc newTuringMachine(initialTape = "", emptyChar = '*'): TuringMachine =
  new result
  for i in -1000 .. 1000:
    result.tape[i] = '*'
  if initialTape != "":
    for i in 0 .. <initialTape.len:
      result.tape[i] = initialTape[i]

  result.tapeLoc = 0
  result.currState = "q0"
  result.transitions = initTable[TransitionInput, TransitionOutput]()

proc addTransition(tm: TuringMachine, transition: Quintuple) =
  tm.transitions[(transition.currState, transition.currInput)] =
      (transition.nextState, transition.output, transition.direction)

proc findTransition(tm: TuringMachine,
                    input: TransitionInput): TransitionOutput =
  try:
    result = tm.transitions[input]
  except KeyError:
    raise newException(TuringError,
      "Transition from $1 with input '$2' not specified" % [input[0], $input[1]])

proc next(tm: TuringMachine) =
  let input = (tm.currState, tm.tape[tm.tapeLoc])
  let (nextState, output, direction) = tm.findTransition(input)
  tm.currState = nextState
  tm.tape[tm.tapeLoc] = output
  case direction
  of R:
    tm.tapeLoc.inc
  of L:
    tm.tapeLoc.dec
  of C:
    discard

proc showUiTuring(tm: TuringMachine, errorMsg = "") =
  terminal.setCursorPos(2, 30)
  stdout.write("-------------------------------------------")
  terminal.setCursorPos(2, 31)
  stdout.write("|")
  for i in -10 .. 10:
    if i == tm.tapeLoc:
      setForegroundColor(fgBlack)
      setBackgroundColor(bgWhite)
      write(stdout, $tm.tape[i])
      stdout.write("|")
      resetAttributes()
    else:
      stdout.write(tm.tape[i] & "|")
  stdout.write("     " & tm.currState)
  terminal.setCursorPos(2, 32)
  stdout.write("-------------------------------------------")

  if errorMsg.len > 0:
    terminal.setCursorPos(0, 49)
    setForegroundColor(fgRed)
    stdout.write(errorMsg)
    resetAttributes()

  terminal.setCursorPos(0, 50)
  stdout.write("TuringSim> ")

proc startUiLoop(tm: TuringMachine) =
  system.addQuitProc(resetAttributes)

  var errorMsg = ""
  while true:
    terminal.eraseScreen()

    showUiTuring(tm, errorMsg)

    var line = stdin.readLine()
    case line
    of "n", "next":
      try:
        tm.next()
      except TuringError:
        errorMsg = getCurrentExceptionMsg()

when isMainModule:
  var tm = newTuringMachine("A101A")
  # Define the transitions
  tm.addTransition(("q0", '1', "q0", '1', R))
  tm.addTransition(("q0", '0', "q0", '0', R))
  tm.addTransition(("q0", 'A', "q_start", 'A', R))
  tm.addTransition(("q_start", '1', "q_start", '0', R))
  tm.addTransition(("q_start", '0', "q_start", '1', R))
  tm.addTransition(("q_start", 'A', "qH", 'A', C))

  startUiLoop(tm)



