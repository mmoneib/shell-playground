#!/bin/bash
################################################################################
# Connect 4 for Bash
#
# The classic turn-based, 2-players game of connecting 4 tiles of the player
# consecutively, either horizontlaly, vertically, or diagonally.
#
# Developer: Muhammad Moneib
################################################################################

source turn_based__sourced.sh;
title="Connect 4 in Bash";
width=8;
height=8;
state=();
currentState=;
players=(Blue Red);
isComputer=(false true);

#TODO Add 3 computer levels.
#TODO Randomize player start.
#TODO Colorize tiles based on player and recent action.

function mOpt1 { echo "Play against the computer."; }
function mOpt2 { echo "Play against a human being."; }
function mOpt3 { echo "Exit"; }

function mAct1 { isComputer=(false true); }
function mAct2 { isComputer=(false false); }
function mAct3 { exit; }

function initialize {
  for ((h=0;h<$height;h++)); do
    for ((w=0;w<width;w++)); do
      state[$((h*width+w))]="O";
    done
  done
  winningPieces=();
  menuOptions=(mOpt1 mOpt2 mOpt3);
  menuActions=(mAct1 mAct2 mAct3);
  winConditions=(checkHorizontalWC checkVerticalWC checkDiagonalForwardWC checkDiagonalBackWC);
  drawConditions=(checkDC);
  rules=(checkValidMove);
  heuristics=(checkWinningH checkDrawH checkPotentialWinsH checkPotentialLossesH);
}

function echoState {
  echo;
  for ((w=0;w<width;w++)); do
    printf "$((w+1))\\t";
  done
  echo;
  echo;
  for ((h=0;h<height;h++)); do
    for ((w=0;w<width;w++)); do
      printf  "${currentState[$((h*width+w))]}\\t";
    done
    echo;
  done
  echo;
}

function markWinningPiecesGreen {
  while [[ ! -z $1 ]]; do
    currentState[$1]="\033[0;32m"${currentState[$1]}"\033[0m";
    shift;
  done    
}

function getPotentialChoices {
  choices=();
  for ((i=0;i<$width;i++)); do
    if [[ "${currentState[$i]}" == "O" ]]; then
      choices+=($i);
    fi
  done
}

function checkDC {
  local isDrawCondition=false;
  for ((i=0;i<${#currentState[@]};i++)); do
    if [[ "${currentState[$i]}" == "O" ]]; then
      isDrawCondition=false
      return;
    fi
  done
  isDrawCondition=true;
  eval $1=$isDrawCondition;
}

function checkWC {
  winningPieces=();
  local basePiece;
  local coeff=$2;
  local hStart=$3
  local hFinish=$4;
  local wStart=$5;
  local wFinish=$6
  local isWinningCondition=false;
  for ((h=0;h<height;h++)); do
    for ((w=0;w<width;w++)); do
      basePiece=$((h*width+w));
      if [[ "${currentState[$basePiece]}" != "O" ]]; then
        local symbol=${currentState[$basePiece]};
        local tempWin=true;
        for ((numOfPieces=1;numOfPieces<4;numOfPieces++)); do
          if [[ "${currentState[$((basePiece+numOfPieces*coeff))]}" != "$symbol" ]]; then
            tempWin=false;
            break;
          fi
        done
        if [[ "$tempWin" == "true" ]]; then
          isWinningCondition=true;
          winner="${currentState[$((h*width+w))]}";
          winningPieces+=("$basePiece $((basePiece+coeff)) $((basePiece+coeff*2)) $((basePiece+coeff*3))");
        fi
      fi
    done
  done
  markWinningPiecesGreen ${winningPieces[@]};
  eval $1=$isWinningCondition;
}

function checkHorizontalWC {
  checkWC isWinningConditionHorizontal 1 0 $((height-1)) 0 $((width-4));
  eval $1=$isWinningConditionHorizontal
}
  
function checkVerticalWC {
  checkWC isWinningConditionVertical $width 0 $((height-4)) 0 $((width-1));
  eval $1=$isWinningConditionVertical;
}

function checkDiagonalForwardWC {  
  # Check from left to right.
  checkWC isWinningConditionDiagonalForwardWC $((width+1)) 0 $((height-4)) 0 $((width-4));
  eval $1=$isWinningConditionDiagonalForwardWC;
}

function checkDiagonalBackWC {
  # Check from left to right.
  checkWC isWinningConditionDiagonalBackWC $((width-1)) $((height-5)) $((height-1)) $((width-5)) $((width-1));
  eval $1=$isWinningConditionDiagonalBackWC;
}

function checkValidMove {
  isValidState=$1;
  choice=$(($2-1));
  if [[ "${currentState[$choice]}" == "O" ]]; then
    isValidState=true;
  else
    isValidState=false;
  fi
}

function applyPhysics {
  choice=$1;
  currentPlayer=$2;
  while [[ "${currentState[$choice]}" == "O" ]]; do
    choice=$((choice+8));
  done
  currentState[$((choice-8))]=${players[$currentPlayer]};
}

function searchBoard {
  local value=0;
  local coeff=$2;
  local symbol=$3; 
  local basePiece;
  for ((h=0;h<height;h++)); do
    for ((w=0;w<width;w++)); do
      basePiece=$((h*width+w));
      local tempValue=0;
      for ((numOfPieces=0;numOfPieces<4;numOfPieces++)); do
        if [[ "${currentState[$((basePiece+numOfPieces*coeff))]}" != "$symbol" ]] && [[ "${currentState[$((basePiece+numOfPieces*coeff))]}" != "O" ]]; then
          tempValue=-1;
          break;
        else
           if [[ "${currentState[$((basePiece+numOfPieces*coeff))]}" == "$symbol" ]]; then
             tempValue=$((tempValue+1));
           fi
        fi
      done
      if (($tempValue>=0)); then
        value=$((value+tempValue**2));
      fi
    done
  done
  eval $1=$value;
 }

function checkPotentialWinsH {
  local value=0;
  local symbol=$2;
  coeff=1;
  searchBoard value1 $coeff $symbol;
  coeff=$width;
  searchBoard value2 $coeff $symbol
  coeff=$((width+1));
  searchBoard value3 $coeff $symbol
  coeff=$((width-1));
  searchBoard value4 $coeff $symbol
  eval $1=$((value1+value2+value3+value4));
}

function checkWinningH {
  local value=0;
  local symbol=$2;
  checkHorizontalWC result;
  if [[ $result == true ]] && [[ "${players[$currentPlayer]}" == "$symbol" ]]; then
    value=$((value+1000000));
  fi
  checkVerticalWC result;
  if [[ $result == true ]] && [[ "${players[$currentPlayer]}" == "$symbol" ]]; then
    value=$((value+1000000));
  fi
  checkDiagonalForwardWC result;
  if [[ $result == true ]] && [[ "${players[$currentPlayer]}" == "$symbol" ]]; then
    value=$((value+1000000));
  fi;
  checkDiagonalBackWC result;
  if [[ $Sresult == true ]] && [[ "${players[$currentPlayer]}" == "$symbol" ]]; then
    value=$((value+1000000));
  fi
  eval $1=$value;
}

function checkPotentialLossesH {
  local value=0;
  local symbol=$([[ "$2" == "${players[0]}" ]] && echo ${players[1]} || echo ${players[0]});
  coeff=1;
  searchBoard value1 $coeff $symbol;
  coeff=$width;
  searchBoard value2 $coeff $symbol
  coeff=$((width+1));
  searchBoard value3 $coeff $symbol
  coeff=$((width-1));
  searchBoard value4 $coeff $symbol
  eval $1=$((-10*(value1+value2+value3+value4)));
}

function checkDrawH { # Calculate hueristic for causing a draw. Which player is current doesn't matter.
  local value=0;
  local symbol=$2;
  checkDC result;
  if [[ $result == true ]]; then
    value=1000000;
  fi; 
  eval $1=$value;
}

tb_engine;
