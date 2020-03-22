#!/bin/bash
################################################################################
# Turned-Based Game Engine
#
# A backend endgine which facilitates developing turn-based games using Bash.
# The engine allows rapid development of new games by allowing the developer
# to focus on the development of the game's display, the conditions for moves,
# the conditions for winning or losing, and the heuristics which define the 
# strategy and artificial intelligence of the computer openent.
# The engine allows an indefinte number of plauyers of any combination of
# humans or computers. The AI is applied using a single level of heuristics
# *mainly for performance reasons, so there's only a single level depth search
# in the state tree. Minimax can be simulated using negative heuristics for
# a defensive strategy. The menus of the game along with the desired actions
# is also fully customizable.
# This script is not meant to be used on its own as it's only meant to be 
# sourced by other game-implementing script.
#
# Developer: Muhammad Moneib
################################################################################

#TODO Add description comments for each variable.
title=;
state=;
currentState=;
newState=;
menuOptions=();
menuActions=();
choices=();
heuristics=();
rules=();
winConditions=();
drawConditions=();
players=();
currentPlayer=;
isComputer=();

#TODO Add score keeping.

function _tb_echoMenu { # Prints the intro and menu options.
  echo;
  echo "Welcome to $title!";
  echo;
  echo "Please choose one of the following options:"
  for ((i=0;i<${#menuOptions[@]};i++)); do
    echo "$((i+1))-$(eval ${menuOptions[$i]})";
  done
  echo;
}

function initialize { # Sets the initial state. To be called at the beginning and after each game.
  echo "Menu options, initial values, and state must be initialized using an initialize function.";
}

function echoState { # Prints the current stete in the game's format.
  echo "Echoing state must be implemented.";
}

function getPotentialChoices { # For computer input, as for human, it's more efficient to get the choice and then evaluate.
  echo "Load the choices array with all the possible legal choices from this current state.";
}

function _tb_checkHeuristics { # Calculates the value of the future state based on the heuritics applied.
  local overallResult=0;
  for ((j=0;j<${#heuristics[@]};j++)); do
    ${heuristics[$j]} result ${players[$currentPlayer]};
    overallResult=$((overallResult+result)); #echo "J$j $result";
  done
  eval $1=$overallResult;
}

function _tb_isComputerTurn { # Identifies if the current player is not human.
  local playerNum=$2;
  if [[ ${isComputer[$playerNum]} == true ]]; then
    isComputerTurn=true;
  else
    isComputerTurn=false;
  fi
  eval $1=$isComputerTurn;
}

function _tb_pointToPotentialState {
  for _stateItem in ${!state[@]}; do # TODO Source out as generic array copying for both indexed and associative arrays.
    newState[_stateItem]=${state[_stateItem]};
  done
  declare -ng currentState=newState; # g for global scope. Otherwise, declare is only function scoped.
}

function _tb_pointToCurrentState {
  declare -ng currentState=state;
}

function _tb_getComputerInput {
  highestValue=-9999999;
  currentPlayer=$2;
  getPotentialChoices;
  input=choices[$((RANDOM%${#choices[@]}))];
  for ((k=0;k<${#choices[@]};k++)); do
    _tb_pointToPotentialState;
    applyPhysics ${choices[$k]} $currentPlayer;
    _tb_checkHeuristics value;
    _tb_pointToCurrentState;
    if (($value>$highestValue)); then
      input=${choices[$k]};
      highestValue=$value;
    fi
  done
  echo "Computer made the choice "$((input+1));
  eval $1=$input; echo "Highest value: $highestValue";
}

function _tb_getUserInput {
  read -p "${players[$2]}'s turn. Please make a move: " -e inp;
  echo;
  eval $1=$inp;
}
 
function _tb_getInput { # Gets the current turn's input.
  currentPlayer=$2;
  _tb_isComputerTurn isComputerTurn $currentPlayer;
  if [[ $isComputerTurn == true ]]; then 
    _tb_getComputerInput choice $currentPlayer;
  else
    isValidState=false;
    while [[ $isValidState != true ]]; do
      _tb_getUserInput choice $currentPlayer;
      _tb_isValidState $isValidState $choice;
    done
  fi
  eval $1=$choice;
}

function _tb_isValidState { # Invisible constraints of the game rules and visible constraints the environmetn.
  isValidState=$1;
  choice=$2;
  for ((i=0;i<${#rules[@]};i++)); do
    ${rules[$i]} $isValidState $choice;
    if [[ $isValidState == false ]]; then
      echo "Incorrect choice as rule $((i+1)) was violated! Please make another choice.";
      return;
    fi      
  done
}

function tryChoice { # Apart of constraints, this is how the environmet of the state impacts the choice's outcome.
  echo "The new state from the player's (potential) choice must be returned by the tryChoice function."
}

function applyPhysics { # Apart of constraints, this is how the environmet of the state impacts the choice's outcome.
  echo "The interaction of the player's choice after it was applied with the environment must be implemented in applyPhysics function.";
}

function _tb_isWinningState { # aka. Game-Ending condition, including a draw.
  isWinningState=false;
  for ((i=0;i<${#winConditions[@]};i++)); do
    ${winConditions[$i]} result;
    if [[ $result == true ]]; then
      isWinningState=true;
    fi      
  done
  eval $1=$isWinningState;
}

function _tb_isDrawState { # aka. Game-Ending condition, including a draw.
  isDrawState=false;
  for ((i=0;i<${#drawConditions[@]};i++)); do
    ${drawConditions[$i]} result;
    if [[ $result == true ]]; then
      isDrawState=true;
    fi   
  done
  eval $1=$isDrawState;
}

function _tb_announceWinner {
  echo
  echo "Game is over. ${players[$currentPlayer]} wins!";
  echo
}

function _tb_announceDraw {
  echo
  echo "Game is over with a draw.";
  echo
}

function _tb_shiftPlayer {
  currentPlayer=$1;
  currentPlayer=$(((currentPlayer+1)%${#players[@]}));
}

function _tb_getUserMenuSelection {
  local isValidInput=false;
  local incorrectInputWarning=""
  while [[ $isValidInput == false ]]; do
    read -N 1 -p "$incorrectInputWarning ""Your choice: " inp;
    echo;
    for ((i=1;i<=${#menuActions[@]};i++)) do
      if [[ "$inp" == "$i" ]]; then
        isValidInput=true;
      fi
    done
    incorrectInputWarning="Incorrect input, please choose one of the above options.";
  done
  eval ${menuActions[$(("$inp"-1))]};
}

function _initialize {
  isWinningState=false;
  isDrawState=false;
  initialize;
}

function tb_engine { # What sets the game in motion. Caller of all other functions except initialize. Runs indefinitely and not to be overridden.
  while (true); do
    _initialize;
    _tb_echoMenu;
    _tb_getUserMenuSelection;
    _tb_pointToCurrentState;
    echoState;
    currentPlayer=0;
    while [[ $isWinningState != true ]]; do
      _tb_getInput choice $currentPlayer;
      applyPhysics $choice $currentPlayer;
      echoState;
      _tb_isWinningState isWinningState;
      if [[ $isWinningState == true ]]; then
        _tb_announceWinner;
        break;
      else
        _tb_isDrawState isDrawState;
        if [[ $isDrawState == true ]]; then
          _tb_announceDraw;
          break;
         fi
      fi
      _tb_shiftPlayer $currentPlayer;
    done
    echoState
  done
}
