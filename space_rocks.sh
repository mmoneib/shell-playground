#!/bin/sh
################################################################################
# Space Rocks                                                                  #
#                                                                              #
# A vintage, arcade game of a space ship avoiding falling rocks.               #
#                                                                              #
# Conceptualized and Developed by: Muhammad Moneib                             #
################################################################################

# INITIALIZATION
## System
# Prevent echoing control characters. Mainly when reading is done, pressing arrows woulf print control.
stty -echoctl
## Configuration
difficulty=5 # From 1 to 5
planeChar="█"
plane=( "   $planeChar   " "  $planeChar$planeChar$planeChar  " "$planeChar$planeChar $planeChar $planeChar$planeChar" " $planeChar $planeChar $planeChar " )
rockChar="▓"
spaceChar=" "
## Traps
function exitFunc {
  tput clear
  echo " GGG   AAA  MM MM EEEEE        OOO  V   V EEEEE RRRR 
G     A   A M M M E           O   O V   V E     R   R
G GGG AAAAA M M M EEEE        O   O V   V EEEE  RRRR 
G   G A   A M   M E           O   O  V V  E     R   R
 GGG  A   A M   M EEEEE        OOO    V   EEEEE R   R
"
  echo "$statistics"
}
trap exitFunc EXIT # TODO Escape errors from trap.
## Initial Conditions
linesBetweenRocks=$(( 5-difficulty )) # Configurable as an indicator of difficulty.
numOfLines=$(( $(tput lines)-1 )) # Leaving last line for statistics.
numOfCols=$(tput cols)
numOfPixels=$(( numOfLines*numOfCols )) # Word 'pixel' is used liberally here.
iteration=0
staticStatistics="Space Rocks by Muhammad Moneib - Difficulty: $difficulty - Score: "
# Position the plane at the lower center.
y=$(( $numOfLines-10 ))
x=$(( $numOfCols/2 ))
## Grids
planeGrid=() # Contains the positions forming the plane layer to be applied over the background grid.
backGrid="" # As a string for faster printing. Here is where background element (like rocks) will lie.
for (( p=0; p<$numOfPixels; p++ )); do
  backGrid+=" " # Start with a blank background grid.
done
# SPLASH
splashLines=(" SSSS PPPP   AAA   CCCC EEEEE       RRRR   OOO   CCCC K   K  SSSS"
             "S     P   P A   A C     E           R   R O   O C     K  K  S    "
             "SSSSS PPPP  AAAAA C     EEEE        RRRR  O   O C     KKK   SSSSS"
             "    S P     A   A C     E           R   R O   O C     K  K      S"
             "SSSS  P     A   A  CCCC EEEEE       R   R  OOO   CCCC K   K SSSS "
             "                                                                 "
             "            M  u  h  a  m  m  a  d   M  o  n  e  i  b            ")
line="${splashLines[0]}"
splashX=$(( numOfCols/2-$(( ${#line}/2 )) ))
for (( i=0; i<${#splashLines[@]}; i++ )); do
  backGrid="${backGrid:0:$(( splashX+$(( i*numOfCols)) ))}""${splashLines[i]}""${backGrid:$(( splashX+$(( i*numOfCols))+${#line} ))}"
done
backGrid="${backGrid:0:$numOfPixels}"
# ENGINE
while true; do
  ## Dynamics of Background Layer
  newLineUp=""
  if [ $(( iteration%$(( linesBetweenRocks+1 )) )) -eq 0 ]; then
    rockPositionInLine=$(( RANDOM%numOfCols )) # Random position for the rock.
    # Static concatination with the 2 for loops is faster than successive string replacement, which is not needed as we won't have more than one rock per line.
    for (( p=0; p<$((rockPositionInLine-1)); p++ )); do
      newLineUp+="$spaceChar"
    done
    newLineUp+="$rockChar"
    for (( p=$rockPositionInLine; p<$numOfCols; p++ )); do
      newLineUp+="$spaceChar"
    done
  else
    for (( p=0; p<$numOfCols; p++ )); do
      newLineUp+="$spaceChar" # Empty line.
    done
  fi
  ## Rendering of Background Layer
  backGrid="$newLineUp$backGrid" # Add new line on top of the background grid.
  backGrid="${backGrid:0:$numOfPixels}" # Trim the extra line at the bottom.
  ## Boundary rules
  # Prevent the plane from exiting the edge of the screen.
  [ $(( x+5 )) -ge $(( numOfCols-1)) ] && x=$(( x-2 )) # 5 is the greatest distance from x to the right based on the grid below. It is the width of the plane.
  [ $x -lt 0 ] && x=$(( x+2 ))
  [ $(( y+3 )) -ge $(( numOfLines)) ] && y=$(( y-2 ))
  ## Dynamics of Plane Layer
  # Plane is injected on top of the background through a new layer using a predefined equation with position variables. Shape is hard-coded for performance reasons.
  # TODO y and x at the center of the plane.
  planeGrid=($(( y*numOfCols+x+3 )) $(( (y+1)*numOfCols+x+2 )) $(( (y+1)*numOfCols+x+3 )) $(( (y+1)*numOfCols+x+4 )) $(( (y+2)*numOfCols+x )) $(( (y+2)*numOfCols+x+1 )) $(( (y+2)*numOfCols+x+3 )) $(( (y+2)*numOfCols+x+5 )) $(( (y+2)*numOfCols+x+6 )) $(( (y+3)*numOfCols+x+1)) $(( (y+3)*numOfCols+x+3)) $(( (y+3)*numOfCols+x+5 )) )
  ## Merging of Layers
  # A new layer is needed to avoid mixing up the top layer (plane) in the dynamic of the background layer with the next iteration.
  allGrid="$backGrid" 
  for (( a=0; a<${#planeGrid[@]}; a++ )); do
    ## Collision Rules
    [ "${backGrid:${planeGrid[$a]}:1}" == "$rockChar" ] && printf "\a" && sleep 1 && printf "\a" && sleep 1 && printf "\a" && sleep 1 && exit # Faster check of collision rules while merging the layers.
    ## Rendering of Plane Layer
    allGrid=${allGrid:0:${planeGrid[$a]}}"$planeChar"${allGrid:$(( ${planeGrid[$a]}+1 ))}
  done
  # Rendering Screen
  statistics="$staticStatistics$iteration"
  for (( i=${#statistics}; i<$((numOfCols-2)); i++ )); do
    statistics+=" "
  done
  tput cup 0 0 # Write over the previous frame, faster than tput reset.
  echo -e "$allGrid$statistics" # Can be commented out for debugging. Echo seems faster than printf.
  # Clock
  iteration=$(( iteration+1 ))
  # Interactivity
  # At the bottom since the game runs without it.
  read -sn 3 -t 0.02 inp # Clocking integrated in read command.
  case $inp in
    $'\033[A') y=$((y-2)) ;; # Up
    $'\033[D') x=$((x-2)) ;; # Left
    $'\033[B') y=$((y+2)) ;; # Down
    $'\033[C') x=$((x+2)) ;; # Right
    *) continue;;
  esac
done

