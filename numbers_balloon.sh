#!/bin/sh
################################################################################
# Numbers Balloo                                                               #
#                                                                              #
# A vintage, arcade game of hot air balloon trying to catch numbers without    #
# smashing into birds.                                                         #
#                                                                              #
# Conceptualized and Developed by: Muhammad Moneib                             #
################################################################################

#TODO Add X to represent birds and end the game if it hits the upper part of the baloon.
#TODO Adjust speeds.
#TODO Add input options.

function initialize {
  # System Configuration
  stty -echoctl   # Prevent echoing control characters. Mainly when reading is done, pressing arrows would print control.
  # User Configuration
  difficulty=1 # From 1 to 5
  # Configuration Validation
  # Internal Configuration
  numOfLines=$(( $(tput lines)-1 )) # Leaving last line for statistics.
  numOfCols=$(tput cols)
  numOfPixels=$(( numOfLines*numOfCols )) # Word 'pixel' is used liberally here.
  clockSpeed="$(echo "scale=1;1-($(( ($difficulty-1)*2 ))/10)"|bc -l)"|sed "s/^\./\0/g" # Internal difficulty.
  linesBetweenNumbers=5
  y=$(( $numOfLines-10 )) # Start at lower part vertically.
  x=$(( $numOfCols/2 )) # Start at center horizontally.
  iteration=0
  score=0 # Needed if the score is not the time.
useEven=false
  # Objects Definition
  balloonChar="|"
  basketChar="#"
  spaceChar=" "
  staticStatistics="Numbers Balloon by Muhammad Moneib - Difficulty: $difficulty - Score: "
  ballonGrid=() # Contains the positions forming the plane layer to be applied over the background grid.
  basketGrid=()
  backGrid="" # As a string for faster printing. Here is where background element (like rocks) will lie.
  for (( p=0; p<$numOfPixels; p++ )); do
    backGrid+=" " # Start with a blank background grid.
  done
  # Signal Traps
  function exitFunc {
    tput clear
    echo " GGG   AAA  MM MM EEEEE        OOO  V   V EEEEE RRRR 
G     A   A M M M E           O   O V   V E     R   R
G GGG AAAAA M M M EEEE        O   O V   V EEEE  RRRR 
G   G A   A M   M E           O   O  V V  E     R   R
 GGG  A   A M   M EEEEE        OOO    V   EEEEE R   R
"
    echo "$statistics" # Calculated by the engine.
  }
  trap exitFunc EXIT # TODO Escape errors from trap.
  # Splash Screen
  splashLines=("N   N U   U MM MM BBBB  EEEEE RRRR   SSSS       BBBB   AAA  L     L      OOO   OOO  N   N"
               "NN  N U   U M M M B   B E     R   R S           B   B A   A L     L     O   O O   O NN  N"
               "N N N U   U M M M BBBB  EEEE  RRRR  SSSSS       BBBB  AAAAA L     L     O   O O   O N N N"
               "N  NN U   U M   M B   B E     R   R     S       B   B A   A L     L     O   O O   O N  NN"
               "N   N  UUU  M   M BBBB  EEEEE R   R SSSS        BBBB  A   A LLLLL LLLLL  OOO   OOO  N   N"
               "                                                                                         "
               "                        M  u  h  a  m  m  a  d   M  o  n  e  i  b                        ")
  line="${splashLines[0]}"
  splashX=$(( numOfCols/2-$(( ${#line}/2 )) ))  # Horizontal centering for top-scrolling games.
  for (( i=0; i<${#splashLines[@]}; i++ )); do
    # Injection of the splash logo line by line in the background of the first frame.
    backGrid="${backGrid:0:$(( splashX+$(( i*numOfCols)) ))}""${splashLines[i]}""${backGrid:$(( splashX+$(( i*numOfCols))+${#line} ))}"
  done
  backGrid="${backGrid:0:$numOfPixels}" # Trimming the empty excess due to the insertions.
}

function engine {
  while true; do
    # Background Layer
    newLineUp=""
    if [ $(( iteration%$(( linesBetweenNumberss+1 )) )) -eq 0 ]; then
      numberPositionInLine=$(( RANDOM%numOfCols )) # Random position for the number.
      # Static concatination with the 2 for loops is faster than successive string replacement, which is not needed as we won't have more than one number per line.
      for (( p=0; p<$(( numberPositionInLine-1 )); p++ )); do
        newLineUp+="$spaceChar"
      done
      newLineUp+="$(( RANDOM%10 ))"
      for (( p=$numberPositionInLine; p<$numOfCols; p++ )); do
        newLineUp+="$spaceChar"
      done
    else
      for (( p=0; p<$numOfCols; p++ )); do
        newLineUp+="$spaceChar" # Empty line.
      done
    fi
    backGrid="$newLineUp$backGrid" # Add new line on top of the background grid.
    backGrid="${backGrid:0:$numOfPixels}" # Trim the extra line at the bottom.
    # Boundary Rules
    [ $(( x+4 )) -ge $(( numOfCols-1)) ] && x=$(( x-2 )) # 5 is the greatest distance from x to the right based on the grid below. It is the width of the plane.
    [ $(( x-4 )) -lt 0 ] && x=$(( x+2 ))
    [ $(( y+4 )) -ge $(( numOfLines)) ] && y=$(( y-2 ))
    # ForegroundLayer
    balloonGridEven=($(( y*numOfCols+x )) $(( y*numOfCols+x+1 )) $(( y*numOfCols+x+2 )) $(( y*numOfCols+x+3 )) $(( y*numOfCols+x-1 )) $(( y*numOfCols+x-2 )) $(( y*numOfCols+x-3 ))
$(( (y-1)*numOfCols+x )) $(( (y-1)*numOfCols+x+1 )) $(( (y-1)*numOfCols+x+2 )) $(( (y-1)*numOfCols+x+3 )) $(( (y-1)*numOfCols+x+4 )) $(( (y-1)*numOfCols+x-1 )) $(( (y-1)*numOfCols+x-2 )) $(( (y-1)*numOfCols+x-3 )) $(( (y-1)*numOfCols+x-4 ))
$(( (y-2)*numOfCols+x )) $(( (y-2)*numOfCols+x+1 )) $(( (y-2)*numOfCols+x+2 )) $(( (y-2)*numOfCols+x+3 )) $(( (y-2)*numOfCols+x+4 )) $(( (y-2)*numOfCols+x-1 )) $(( (y-2)*numOfCols+x-2 )) $(( (y-2)*numOfCols+x-3 )) $(( (y-2)*numOfCols+x-4 ))
$(( (y-3)*numOfCols+x )) $(( (y-3)*numOfCols+x+1 )) $(( (y-3)*numOfCols+x+2 )) $(( (y-3)*numOfCols+x+3 )) $(( (y-3)*numOfCols+x-1 )) $(( (y-3)*numOfCols+x-2 )) $(( (y-3)*numOfCols+x-3 ))
$(( (y-4)*numOfCols+x )) $(( (y-4)*numOfCols+x+1 )) $(( (y-4)*numOfCols+x-1 ))
$(( (y+1)*numOfCols+x )) $(( (y+1)*numOfCols+x+1 )) $(( (y+1)*numOfCols+x+2 )) $(( (y+1)*numOfCols+x-1 )) $(( (y+1)*numOfCols+x-2 ))
)
    balloonGridOdd=($(( y*numOfCols+x )) $(( y*numOfCols+x+1 )) $(( y*numOfCols+x+2 )) $(( y*numOfCols+x+3 )) $(( y*numOfCols+x-1 )) $(( y*numOfCols+x-2 )) $(( y*numOfCols+x-3 ))
$(( (y-1)*numOfCols+x )) $(( (y-1)*numOfCols+x+1 )) $(( (y-1)*numOfCols+x+2 )) $(( (y-1)*numOfCols+x+3 )) $(( (y-1)*numOfCols+x+4 )) $(( (y-1)*numOfCols+x-1 )) $(( (y-1)*numOfCols+x-2 )) $(( (y-1)*numOfCols+x-3 )) $(( (y-1)*numOfCols+x-4 ))
$(( (y-2)*numOfCols+x )) $(( (y-2)*numOfCols+x+1 )) $(( (y-2)*numOfCols+x+2 )) $(( (y-2)*numOfCols+x+3 )) $(( (y-2)*numOfCols+x+4 )) $(( (y-2)*numOfCols+x-1 )) $(( (y-2)*numOfCols+x-2 )) $(( (y-2)*numOfCols+x-3 )) $(( (y-2)*numOfCols+x-4 ))
$(( (y-3)*numOfCols+x )) $(( (y-3)*numOfCols+x+1 )) $(( (y-3)*numOfCols+x+2 )) $(( (y-3)*numOfCols+x+3 )) $(( (y-3)*numOfCols+x-1 )) $(( (y-3)*numOfCols+x-2 )) $(( (y-3)*numOfCols+x-3 ))
$(( (y-4)*numOfCols+x )) $(( (y-4)*numOfCols+x+1 )) $(( (y-4)*numOfCols+x-1 ))
$(( (y+1)*numOfCols+x )) $(( (y+1)*numOfCols+x+1 )) $(( (y+1)*numOfCols+x-1 )) 
)
    basketGrid=($(( (y+2)*numOfCols+x+1 )) $(( (y+2)*numOfCols+x-1 ))
$(( (y+3)*numOfCols+x )) $(( (y+3)*numOfCols+x+1 )) $(( (y+3)*numOfCols+x-1 ))
$(( (y+4)*numOfCols+x )) $(( (y+4)*numOfCols+x+1 )) $(( (y+4)*numOfCols+x-1 ))
)
    if [ $(( iteration%10 )) -eq 0 ]; then # Rotating frames for object animation.
      if [ "$useEven" == "true" ]; then
        useEven="false" 
      else
        useEven="true"
      fi
    fi
    # Merge of State + Collision Rules
    allGrid="$backGrid" # A new layer is needed to avoid mixing up the top layer in the dynamic of the background layer with the next iteration.
    for (( a=0; a<${#balloonGridEven[@]}; a++ )); do
      if [ "$useEven" == "true" ]; then
        allGrid=${allGrid:0:${balloonGridEven[$a]}}"$balloonChar"${allGrid:$(( ${balloonGridEven[$a]}+1 ))}
      else
        allGrid=${allGrid:0:${balloonGridOdd[$a]}}"$balloonChar"${allGrid:$(( ${balloonGridOdd[$a]}+1 ))}
      fi
    done
    for (( a=0; a<${#basketGrid[@]}; a++ )); do
      backGridChar="${backGrid:${basketGrid[$a]}:1}"
      [ ! "$backGridChar" == "$spaceChar" ] && score=$(( score + backGridChar )) && backGrid=${backGrid:0:${basketGrid[$a]}}"$paceChar"${backGrid:$(( basketGrid[$a]+1 ))} && printf "\a" # Detection by negation of space.
      allGrid=${allGrid:0:${basketGrid[$a]}}"$basketChar"${allGrid:$(( ${basketGrid[$a]}+1 ))}
    done
    # Frame Print
    statistics="$staticStatistics$score"
    for (( i=${#statistics}; i<$((numOfCols-2)); i++ )); do # Dynamic, based on score width.
      statistics+=" "
    done
    tput cup 0 0 # Write over the previous frame, faster than tput reset.
    echo -e "$allGrid$statistics" # Can be commented out for debugging. Echo seems faster than printf.
    # Clock + User Interaction
    iteration=$(( iteration+1 ))
    read -sn 3 -t 0.02 inp # Clocking integrated in read command.
    case $inp in
      $'\033[A') y=$((y-2)) ;; # Up
      $'\033[D') x=$((x-2)) ;; # Left
      $'\033[B') y=$((y+2)) ;; # Down
      $'\033[C') x=$((x+2)) ;; # Right
      *) continue;;
    esac
  done
}

initialize
engine
