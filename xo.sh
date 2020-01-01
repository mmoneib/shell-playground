#!/bin/bash

#################################
# X O Bash v 1.0                #
# A classic X O game for BASH.  #
# Developed by: Muhammad Moneib #
#################################

state=();
victor=;
victorPositions=(); #For color formatting the output.
currentPlayer=;
human=;
currentEval=0;
computerChoice=;
computer="Stupid";
RED="\033[31m";
NORMAL="\033[0;39m"
isDebug=false;
function echod { [[ $isDebug == true ]] && echo $1; } #AOP

function printState {
  printf '\n';
  printedState=();
  if [[ ! -z $victor ]] && [[ "$victor" != "D" ]]; then
    for((i=0;i<${#victorPositions[@]};i++)); do
      printedState[${victorPositions[i]}]="$RED"${state[${victorPositions[i]}]};
    done    
  fi
  for((j=0;j<${#state[@]};j++)); do
    if [[ -z ${printedState[j]} ]]; then
      printedState[j]="$NORMAL"${state[j]};
    fi
  done
  printf "${printedState[0]}\t${printedState[1]}\t${printedState[2]}\n";
  printf "\n";
  printf "${printedState[3]}\t${printedState[4]}\t${printedState[5]}\n";
  printf "\n";
  printf "${printedState[6]}\t${printedState[7]}\t${printedState[8]}\n";
  printf "\n";
  printf $NORMAL;
  victorPositions=();
}

function switchComputerSmartness {
  [[ "$computer" == "Stupid" ]] && computer="Smart" || computer="Stupid";
}

function isVictorious {
  if [[ ! -z $1 ]]; then
    echod "Checking victory condition for the future state: $(eval echo $@).";
    thisState=("$@"); # Catching array parameter.
  else
    thisState=("${state[@]}"); # Copying array.
  fi
  #Check horizontal victory conditions.
  for ((i=0;i<7;i=$((i+3)))); do
    if [[ "${thisState[i]}" == "${thisState[i+1]}" ]] && [[ "${thisState[i+1]}" == "${thisState[i+2]}" ]]; then
      if [[ ! -z ${thisState[i]} ]]; then
        victor=${state[i]};
        victorPositions+=($i $((i+1)) $((i+2)));
        return;
      fi
    fi
  done
  #Check vertical victory conditions.
  for ((i=0;i<3;i++)); do
    if [[ "${thisState[i]}" == "${thisState[i+3]}" ]] && [[ "${thisState[i+3]}" == "${thisState[i+6]}" ]]; then
      if [[ ! -z ${thisState[i]} ]]; then
        victor=${thisState[i]};
        victorPositions+=($i $((i+3)) $((i+6)));
        return;
      fi
    fi
  done
  #Check first diagonal victory conditions.
  if [[ "${thisState[0]}" == "${thisState[4]}" ]] && [[ "${thisState[4]}" == "${thisState[8]}" ]]; then
    if [[ ! -z ${thisState[0]} ]]; then
      victor=${thisState[0]};
      victorPositions+=(0 4 8);
      return;
    fi
  fi
  #Check second diagonal victory conditions.
  if [[ "${thisState[2]}" == "${thisState[4]}" ]] && [[ "${thisState[4]}" == "${thisState[6]}" ]]; then
    if [[ ! -z ${thisState[2]} ]]; then
      victor=${thisState[2]};
      victorPositions+=(2 4 6);
      return;
    fi
  fi
  #Check condition of a draw.
  for ((i=0;i<${#thisState[@]};i++)); do
    if [[ "${thisState[i]}" != "X" ]] && [[ "${thisState[i]}" != "Y" ]]; then
      return;
    fi
  done
  victor="D";
}

function evaluateSmartChoice {
  # Greedy algorithm: Short-sighted maximization.
  futureState=("${state[@]}");
  futurePlayer=$currentPlayer;
  futurePos=$1;
  currentEval=0
  echod "Evaluating future state for 0-index position ${futurePos}";
  echod "Future player ${futurePlayer}";
  echod "Future state before adding future player $(eval echo ${futureState[@]})";
  futureState[$futurePos]="$futurePlayer";
  echod "Future state after adding future player $(eval echo ${futureState[@]})";
  # First heuristic: A winning or draw move. A certain heuristic, if I am allowed to say that.
  isVictorious "${futureState[@]}"
  if [[ ! -z $victor ]]; then 
    echod "First heuristic."
    currentEval=1000;
    victor=;
    return;
  fi
  # Second heuristic: A blocking move. A certain heuristic, if I am allowed to say that.
  [[ "$currentPlayer" == "X" ]] && oppositePlayer="Y" || oppositePlayer="X"; # One-liner If Else.
  futureState[$futurePos]=$oppositePlayer;
  echod "Future state after adding opposite player $(eval echo ${futureState[@]})";
  isVictorious "${futureState[@]}";
  if [[ ! -z $victor ]]; then
    echod "Second heuristic."
    currentEval=100;
    victor=;
    return;
  fi
  # Third heuristic: Controlling the center.
  if [[ "$futurePos" == "4" ]]; then
    echod "Third heuristic.";
    currentEval=50;
  fi
  # Fourth heuristic: No opposite on horizontal line.
  if (($futurePos < 9)); then offsetNum=6; fi
  if (($futurePos < 6)); then offsetNum=3; fi
  if (($futurePos < 3)); then offsetNum=0; fi
  modNum=3;
  if [[ "${futureState[(((futurePos+1)%(modNum+offsetNum)+offsetNum))]}" != $oppositePlayer ]] && [[ "${futureState[(((futurePos+2)%(modNum+offsetNum)+offsetNum))]}" != $oppositePlayer ]]; then
    echod "Fourth heuristic."
    ((currentEval+=10));
  fi
  # Fifth heuristic: No opposite on vertical line.
  modNum=9;
  if [[ "${futureState[(((futurePos+3)%modNum))]}" != $oppositePlayer ]] && [[ "${futureState[(((futurePos+6)%modNum))]}" != $oppositePlayer ]]; then
    echod "Fifth heuristic."
    ((currentEval+=10));
  fi
  # Sixth heuristic: No opposite om diagonal line. Implicitly favoriting corners as they provide 3 possibile lines instead of 2.
  if [[ "$futurePos" == "0" ]] || [[ "$futurePos" == "8" ]]; then
    echod "Sixth heuristic."
    [[ "$futureState[0]" != "$futurePlayer" && "$futureState[4]" != "$futurePlayer" && "$futureState[8]" != "$oppositePlayer" ]] && ((currentEval+=5));
  elif [[ "$futurePos" == "2" ]] || [[ "$futurePos" == "6" ]]; then
    echod "Sixth heuristic."
    [[ "$futureState[2]" != "$futurePlayer" && "$futureState[4]" != "$futurePlayer" && "$futureState[6]" != "$oppositePlayer" ]] && ((currentEval+=5));
  fi
}

function smartChoice {
  choices=();
  for((i=0;i<${#state[@]};i++)); do
    if [[ "${state[i]}" != "X" ]] && [[ "${state[i]}" != "Y" ]]; then
      choices+=( $i );
    fi
  done
  computerChoice=;
  bestEvalSoFar=0;
  for((j=0;j<${#choices[@]};j++)); do
    evaluateSmartChoice ${choices[j]};
    if (( $currentEval > $bestEvalSoFar )); then # Numerical comparisons must be inside arithmetic context (( )).
      bestEvalSoFar=$currentEval; 
      echod "Best eval $bestEvalSoFar"
      computerChoice=${choices[j]};
    fi
  done 
  echod "The omputer smartly chose $computerChoice."
  currentEval=0
  bestEvalSoFar=0;
}

function stupidChoice {
  choices=();
  for((i=0;i<${#state[@]};i++)); do
    if [[ "${state[i]}" != "X" ]] && [[ "${state[i]}" != "Y" ]]; then
      choices+=( $i );
    fi
  done
  computerChoice=${choices[$((RANDOM%${#choices[@]}))]}; 
}

function switchCurrentPlayer {
  if [[ "$currentPlayer" == "X" ]]; then
    currentPlayer="Y";
  elif [[ "$currentPlayer" == "Y" ]]; then
    currentPlayer="X";
  fi
}

function startEngine {
  while [ -z $victor ]; do
    printState;
    if [[ "$currentPlayer" == "$human" ]] || [[ "$human" == "XY" ]]; then
      printf "\nChoose a number to input $currentPlayer into:";
      validInput=;
      while(true); do
        read -N 1 inp;
        for((i=0;i<${#state[@]};i++)); do
          if [[ "$inp" == "${state[$i]}" ]]; then
            state[$i]=$currentPlayer;
            validInput=true;
          fi
        done
        if [[ $validInput == true ]]; then
          break;
        else
          printf "\nPlease enter a valid available number.\n"
        fi
      done
    else
      [[ "$computer" == "Stupid" ]] && stupidChoice || smartChoice;
      state[$computerChoice]=$currentPlayer;
    fi
    isVictorious;
    switchCurrentPlayer;
  done
  printState
  if [[ $victor == "D" ]]; then
    printf "\nGame ended in a draw!\n";
  else
    printf "\nGame over! $victor won!\n"
  fi
}

function startOneWithX {
  currentPlayer="X";
  human="X";
  startEngine;
}

function startOneWithY {
  currentPlayer="X";
  human="Y";
  startEngine;
}

function startOneWithRandom {
  choices=("X" "Y");
  currentPlayer=${choices[$((RANDOM%2))]};
  human=${choices[$((RANDOM%2))]};
  startEngine;
}

function startTwo {
  currentPlayer="X";
  human="XY";  
  startEngine;
}

function initializeState {
  state=(1 2 3 4 5 6 7 8 9);
  victor=;
  currentPlayer=;
  human=;
}

function printAbout {
  echo;
  echo "   #################################";
  echo "   # A classic X O game for BASH.  #";
  echo "   # Developed by: Muhammad Moneib #";
  echo "   #################################";
  echo;
  echo "X O is one of the simplest games in the world with a very limited choice space in its classical version. The purpose of this turn-based game is 
to get 3 similar letters on the same line in a 3*3 grid, either horizontally, vertically, or diagonally. The limited choices for each player allow developing 
more specific heuristics possible, which are not so very far from, but still more efficient than, a brute force solution. The limited choice space also allow
for implicit minimization of the opponents opportunity while maximizing the current player's.; only the second heuristic results in an explicit minimization
action. That's also why the depth of the decision tree here is no more than one at any moment since the direct leaves are searched in breadth only. The weight
of each heuristic is also fixed based on its importance for the game strategy.";
  echo;
  echo "Heuristics used for the smart computer player:";
  echo "  # First heuristic: A winning or draw move. A certain heuristic, if I am allowed to say that.";
  echo "  # Second heuristic: A blocking move. A certain heuristic, if I am allowed to say that.";
  echo "  # Third heuristic: Controlling the center.";
  echo "  # Fourth heuristic: No opposite on horizontal line.";
  echo "  # Fifth heuristic: No opposite on vertical line.";
  echo "  # Sixth heuristic: No opposite om diagonal line. Implicitly favoriting corners as they provide 3 possibile lines instead of 2.";
  echo;
  read -N 1 -s -p "Press any key to go back to the menu..." inp; # Read silently.
  echo;
  echo;
}

function showMenu {
  echo "Hello to the ultimate command-line XO game!"
  echo "_|_|_ ";
  echo "_|_|_";
  echo " | | ";
  echo "Please choose the type of game you want:"
  echo "1-A 1-player game starting with X."
  echo "2-A 1-player game starting with O."
  echo "3-A random 1-player game."
  echo "4-A 2-player game."
  echo "S-Switch to $(eval [[ "$computer" == "Stupid" ]] && echo "Smart" || echo "Stupid") computer oponent. Currently: $computer."
  echo "V-Switch verbose mode On/Off. Currently: $(eval [[ $isDebug == true ]] && echo "On" || echo "Off")."
  echo "A-Show About info."
  echo "X-Exit."
  echo "Input:"
  read -N 1 inp;
  if [[ "$inp" == "1" ]]; then
    startOneWithX;
  elif [[ "$inp" == "2" ]]; then
    startOneWithY;
  elif [[ "$inp" == "3" ]]; then
    startOneWithRandom;
  elif [[ "$inp" == "4" ]]; then
    startTwo;
  elif [[ "$inp" == "S" ]]; then
    switchComputerSmartness;
  elif [[ "$inp" == "V" ]]; then
    [[ $isDebug == true ]] && isDebug=false || isDebug=true;
  elif [[ "$inp" == "A" ]]; then
    printAbout;
  elif [[ "$inp" == "X" ]]; then
    exit;
  else
    printf "\nPlease make an informed choice. :-/\n";
  fi
}

while(true); do
  initializeState;
  showMenu;
done

