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

proc newTuringMachine(initialTape = "", initialPos = 0,
                      emptyChar = '*'): TuringMachine =
  new result
  for i in -1000 .. 1000:
    result.tape[i] = '*'
  if initialTape != "":
    for i in 0 .. <initialTape.len:
      result.tape[i] = initialTape[i]

  result.tapeLoc = initialPos
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

proc showTransitions(tm: TuringMachine) =
  terminal.setCursorPos(2, 34)
  for key, val in tm.transitions:
    if key.currState == tm.currState and key.currInput == tm.tape[tm.tapeLoc]:
      setForegroundColor(fgGreen)
    stdout.write("($#, $#, $#, $#, $#)\n  " % [key.currState, $key.currInput,
        val.nextState, $val.output, $val.direction])
    resetAttributes()

proc showUiTuring(tm: TuringMachine, errorMsg = "") =
  ## Draw the UI of the Turing Simulator

  # Draw the top of the tape.
  terminal.setCursorPos(2, 30)
  stdout.write("-------------------------------------------")

  # Draw the tape contents.
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

  # Draw the current state.
  stdout.write("     " & tm.currState)

  # Draw the bottom of the tape.
  terminal.setCursorPos(2, 32)
  stdout.write("-------------------------------------------")

  showTransitions(tm)

  # Show error if one exists.
  if errorMsg.len > 0:
    terminal.setCursorPos(0, 49)
    setForegroundColor(fgRed)
    stdout.write(errorMsg)
    resetAttributes()

  # Show prompt.
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
    of "n", "next", "":
      try:
        tm.next()
      except TuringError:
        errorMsg = getCurrentExceptionMsg()

when isMainModule:

  # 1s complement (Q1)
  when true:
    var tm = newTuringMachine("A101A")
    # Define the transitions
    tm.addTransition(("q0", '1', "q0", '1', R))
    tm.addTransition(("q0", '0', "q0", '0', R))
    tm.addTransition(("q0", 'A', "q_start", 'A', R))
    tm.addTransition(("q_start", '1', "q_start", '0', R))
    tm.addTransition(("q_start", '0', "q_start", '1', R))
    tm.addTransition(("q_start", 'A', "qH", 'A', C))

  # Unary subtractor (Q2)
  when false:
    var tm = newTuringMachine("A111B11C", 4)

    tm.addTransition(("q0", 'B', "q0", 'B', R))
    tm.addTransition(("q0", 'C', "qH", 'C', C))
    tm.addTransition(("q0", '1', "q_sub", 'B', L))
    tm.addTransition(("q_sub", '1', "q0", 'B', R))
    tm.addTransition(("q_sub", 'B', "q_sub", 'B', L))

  # Copying (Q3)
  when false:
    var tm = newTuringMachine("000")

    tm.addTransition(("q0", '0', "q_copy", 'C', R))
    tm.addTransition(("q0", '#', "qH", '#', C))
    tm.addTransition(("q_copy", '#', "q_place", '#', R))
    tm.addTransition(("q_copy", '*', "q_place", '#', R))
    tm.addTransition(("q_copy", '0', "q_copy", '0', R))
    tm.addTransition(("q_place", '*', "q_back", '0', L))
    tm.addTransition(("q_place", '0', "q_place", '0', R))
    tm.addTransition(("q_back", 'C', "q0", '0', R))
    tm.addTransition(("q_back", '0', "q_back", '0', L))
    tm.addTransition(("q_back", '#', "q_back", '#', L))

  # Sorting (Q4)
  when false:
    #var tm = newTuringMachine("AyxxA")
    #var tm = newTuringMachine("AyxyxxyyyA")
    #var tm = newTuringMachine("AyxyxyxyxA")
    var tm = newTuringMachine("AxxxxxA")

    tm.addTransition(("q0", 'x', "q0", 'x', R))
    tm.addTransition(("q0", 'A', "q0", 'A', R))
    tm.addTransition(("q0", 'y', "q_find_x", 'M', R))
    tm.addTransition(("q_find_x", 'y', "q_find_x", 'y', R))
    tm.addTransition(("q_find_x", 'A', "q_replace_M", 'A', L))
    tm.addTransition(("q_find_x", 'x', "q_find_M", 'y', L))
    tm.addTransition(("q_replace_M", 'y', "q_replace_M", 'y', L))
    tm.addTransition(("q_replace_M", 'M', "qH", 'y', R))
    tm.addTransition(("q_find_M", 'x', "q_find_M", 'x', L))
    tm.addTransition(("q_find_M", 'y', "q_find_M", 'y', L))
    tm.addTransition(("q_find_M", 'M', "q0", 'x', R))
    # TODO: Add a q0 transition to the halt state.

  # Q5 - Unary addition.
  when false:
    var tm = newTuringMachine("A111B1111A", 4)

    tm.addTransition(("q0", 'B', "q1", '1', R))
    tm.addTransition(("q1", '1', "q1", '1', R))
    tm.addTransition(("q1", 'A', "q2", '*', L))
    tm.addTransition(("q2", '1', "qH", 'A', C))

  startUiLoop(tm)



