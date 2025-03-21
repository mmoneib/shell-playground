#!/bin/sh
################################################################################
# Snake                                                                        #
#                                                                              #
# A clone of the classic game of NOKIA fame.                                   #
#                                                                              #
# Developed by: Muhammad Moneib                                                #
################################################################################
#TODO Use arcade__actions better than template?

function initialize {
  # System Configuration
  stty -echoctl   # Prevent echoing control characters. Mainly when reading is done, pressing arrows would print control.
  ~more_system_configuration_here~
  # User Configuration
  difficulty=5 # From 1 to 5
  # Configuration Validation
  # Internal Configuration
  numOfLines=$(( $(tput lines)-1 )) # Leaving last line for statistics.
  numOfCols=$(tput cols)
  numOfPixels=$(( numOfLines*numOfCols )) # Word 'pixel' is used liberally here.
  clockSpeed="$(echo "scale=2;(1-($(( (difficulty-1)*2 ))/10))/10"|bc -l|sed "s/^\./0\./g")" # Internal difficulty.
  y=$(( $numOfLines-10 )) # Start at lower part vertically.
  x=$(( $numOfCols/2 )) # Start at center horizontally.	
  iteration=0
  score=0 # Needed if the score is not the time.
  #~object_animation_frame_configuration_here~
  # Objects Definition
  snakeChar="X"
  foodChar="O"
  staticStatistics="Snake"" by Muhammad Moneib - Width: $numOfCols - Height: $numOfLines - Difficulty: $difficulty - Score: "
  snakeGrid=()
  backGrid="" # As a string for faster printing. Here is where background element (like rocks) will lie.
  for (( p=0; p<$numOfPixels; p++ )); do
    backGrid+=" " # Start with a blank background grid.
  done
  # Signal Traps
  function exitFunc {
    [ ! $? -eq 0 ] && echo "Error occured! :-(" && exit 1 # $? has to be in the first line of the function to get the last's exit code.
    tput clear
    echo " GGG   AAA  MM MM EEEEE        OOO  V   V EEEEE RRRR 
G     A   A M M M E           O   O V   V E     R   R
G GGG AAAAA M M M EEEE        O   O V   V EEEE  RRRR 
G   G A   A M   M E           O   O  V V  E     R   R
 GGG  A   A M   M EEEEE        OOO    V   EEEEE R   R"
    echo "$statistics" # Calculated by the engine.
  }
  trap exitFunc EXIT
  # Splash Screen
  splashLines=("       SSSS N   N  AAA  K   K EEEEE      "
               "      S     NN  N A   A K  K  E          "
               "      SSSSS N N N AAAAA KKK   EEEE       "
               "          S N  NN A   A K  K  E          "
               "      SSSS  N   N A   A K   K EEEEE      "
               "                                         "
               "M  u  h  a  m  m  a  d   M  o  n  e  i  b")
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
    newElementOrLine="$foodChar"
    newElementOrLineIndex=$(( RANDOM%$numOfPixels )) # Random placement of food.
    backGrid="${backGrid:0:newElementOrLineIndex}$newElementOrLine$backGrid:$(( $newElementOrLineIndex+${#newElementOrLine}  ))" # Add new element to the background grid.
    backGrid="${backGrid:0:$numOfPixels}" # Trim the extra line at the bottom.
    # Boundary Rules
    y=$(( (y+numOfLines)%numOfLines )) # Wrap to the other side of the screen. The addition is for the case where y becomes negative.
    x=$(( (x+numOfCols)%numOfCols )) # Wrap to the other side of the screen. The addition is for the case where x becomes negative.
    # Foreground Layer
    function frame0 {
      balloonGrid=($(( y*numOfCols+x )) $(( y*numOfCols+x+1 )) $(( y*numOfCols+x+2 )) $(( y*numOfCols+x+3 )) $(( y*numOfCols+x-1 )) $(( y*numOfCols+x-2 )) $(( y*numOfCols+x-3 ))
$(( (y-1)*numOfCols+x )) $(( (y-1)*numOfCols+x+1 )) $(( (y-1)*numOfCols+x+2 )) $(( (y-1)*numOfCols+x+3 )) $(( (y-1)*numOfCols+x+4 )) $(( (y-1)*numOfCols+x-1 )) $(( (y-1)*numOfCols+x-2 )) $(( (y-1)*numOfCols+x-3 )) $(( (y-1)*numOfCols+x-4 ))
$(( (y-2)*numOfCols+x )) $(( (y-2)*numOfCols+x+1 )) $(( (y-2)*numOfCols+x+2 )) $(( (y-2)*numOfCols+x+3 )) $(( (y-2)*numOfCols+x+4 )) $(( (y-2)*numOfCols+x-1 )) $(( (y-2)*numOfCols+x-2 )) $(( (y-2)*numOfCols+x-3 )) $(( (y-2)*numOfCols+x-4 ))
$(( (y-3)*numOfCols+x )) $(( (y-3)*numOfCols+x+1 )) $(( (y-3)*numOfCols+x+2 )) $(( (y-3)*numOfCols+x-1 )) $(( (y-3)*numOfCols+x-2 )) $(( (y-3)*numOfCols+x-3 )) $(( (y-3)*numOfCols+x-4 ))
$(( (y-4)*numOfCols+x )) $(( (y-4)*numOfCols+x-1 )) $(( (y-4)*numOfCols+x-2 ))
$(( (y+1)*numOfCols+x )) $(( (y+1)*numOfCols+x+1 )) $(( (y+1)*numOfCols+x+2 )) $(( (y+1)*numOfCols+x+3 )) $(( (y+1)*numOfCols+x-1 ))
)
      basketGrid=($(( (y+2)*numOfCols+x+2 )) $(( (y+2)*numOfCols+x ))
$(( (y+3)*numOfCols+x )) $(( (y+3)*numOfCols+x+1 )) $(( (y+3)*numOfCols+x+2 )) $(( (y+3)*numOfCols+x+3 ))
$(( (y+4)*numOfCols+x+1 )) $(( (y+4)*numOfCols+x+2 ))
)
    }
    function frame1 {
      balloonGrid=($(( y*numOfCols+x )) $(( y*numOfCols+x+1 )) $(( y*numOfCols+x+2 )) $(( y*numOfCols+x+3 )) $(( y*numOfCols+x-1 )) $(( y*numOfCols+x-2 )) $(( y*numOfCols+x-3 ))
$(( (y-1)*numOfCols+x )) $(( (y-1)*numOfCols+x+1 )) $(( (y-1)*numOfCols+x+2 )) $(( (y-1)*numOfCols+x+3 )) $(( (y-1)*numOfCols+x+4 )) $(( (y-1)*numOfCols+x-1 )) $(( (y-1)*numOfCols+x-2 )) $(( (y-1)*numOfCols+x-3 )) $(( (y-1)*numOfCols+x-4 ))
$(( (y-2)*numOfCols+x )) $(( (y-2)*numOfCols+x+1 )) $(( (y-2)*numOfCols+x+2 )) $(( (y-2)*numOfCols+x+3 )) $(( (y-2)*numOfCols+x+4 )) $(( (y-2)*numOfCols+x-1 )) $(( (y-2)*numOfCols+x-2 )) $(( (y-2)*numOfCols+x-3 )) $(( (y-2)*numOfCols+x-4 ))
$(( (y-3)*numOfCols+x )) $(( (y-3)*numOfCols+x+1 )) $(( (y-3)*numOfCols+x+2 )) $(( (y-3)*numOfCols+x+3 )) $(( (y-3)*numOfCols+x-1 )) $(( (y-3)*numOfCols+x-2 )) $(( (y-3)*numOfCols+x-3 ))
$(( (y-4)*numOfCols+x )) $(( (y-4)*numOfCols+x+1 )) $(( (y-4)*numOfCols+x-1 ))
$(( (y+1)*numOfCols+x )) $(( (y+1)*numOfCols+x+1 )) $(( (y+1)*numOfCols+x+2 )) $(( (y+1)*numOfCols+x-1 )) $(( (y+1)*numOfCols+x-2 ))
)
      basketGrid=($(( (y+2)*numOfCols+x+1 )) $(( (y+2)*numOfCols+x-1 ))
$(( (y+3)*numOfCols+x )) $(( (y+3)*numOfCols+x+1 )) $(( (y+3)*numOfCols+x-1 ))
$(( (y+4)*numOfCols+x )) $(( (y+4)*numOfCols+x+1 )) $(( (y+4)*numOfCols+x-1 ))
)
    }
    function frame2 {
      balloonGrid=($(( y*numOfCols+x )) $(( y*numOfCols+x+1 )) $(( y*numOfCols+x+2 )) $(( y*numOfCols+x+3 )) $(( y*numOfCols+x-1 )) $(( y*numOfCols+x-2 )) $(( y*numOfCols+x-3 ))
$(( (y-1)*numOfCols+x )) $(( (y-1)*numOfCols+x+1 )) $(( (y-1)*numOfCols+x+2 )) $(( (y-1)*numOfCols+x+3 )) $(( (y-1)*numOfCols+x+4 )) $(( (y-1)*numOfCols+x-1 )) $(( (y-1)*numOfCols+x-2 )) $(( (y-1)*numOfCols+x-3 )) $(( (y-1)*numOfCols+x-4 ))
$(( (y-2)*numOfCols+x )) $(( (y-2)*numOfCols+x+1 )) $(( (y-2)*numOfCols+x+2 )) $(( (y-2)*numOfCols+x+3 )) $(( (y-2)*numOfCols+x+4 )) $(( (y-2)*numOfCols+x-1 )) $(( (y-2)*numOfCols+x-2 )) $(( (y-2)*numOfCols+x-3 )) $(( (y-2)*numOfCols+x-4 ))
$(( (y-3)*numOfCols+x )) $(( (y-3)*numOfCols+x-1 )) $(( (y-3)*numOfCols+x-2 )) $(( (y-3)*numOfCols+x+1 )) $(( (y-3)*numOfCols+x+2 )) $(( (y-3)*numOfCols+x+3 )) $(( (y-3)*numOfCols+x+4 ))
$(( (y-4)*numOfCols+x )) $(( (y-4)*numOfCols+x+1 )) $(( (y-4)*numOfCols+x+2 ))
$(( (y+1)*numOfCols+x )) $(( (y+1)*numOfCols+x-1 )) $(( (y+1)*numOfCols+x-2 )) $(( (y+1)*numOfCols+x-3 )) $(( (y+1)*numOfCols+x+1 ))
)
      basketGrid=($(( (y+2)*numOfCols+x )) $(( (y+2)*numOfCols+x-2 ))
$(( (y+3)*numOfCols+x )) $(( (y+3)*numOfCols+x-1 )) $(( (y+3)*numOfCols+x-2 )) $(( (y+3)*numOfCols+x-3 ))
$(( (y+4)*numOfCols+x-1 )) $(( (y+4)*numOfCols+x-2 ))
)
    }
    function frame3 { # To close the loop. 
      frame1 
    }
    [ $((iteration%$iterationsPerFrame)) -eq 0 ] && frame=$(( (frame+1)%4 ))
    frame$frame # Polymorphism through functional reference.
    # Merge of State + Collision Rules
    allGrid="$backGrid" # A new layer is needed to avoid mixing up the top layer in the dynamic of the background layer with the next iteration.
    exitAfterPrint=false
    for (( a=0; a<${#balloonGrid[@]}; a++ )); do
      backGridChar="${backGrid:${balloonGrid[$a]}:1}"
      [ "$backGridChar" == "X" ] && allGrid=${allGrid:0:${balloonGrid[$a]}}"$backGridChar"${allGrid:$(( ${balloonGrid[$a]}+1 ))} && exitAfterPrint=true && continue # The flow makes sense so as the puncture is shown graphically and any simultaneous scoring is calculated before exiting.
      allGrid=${allGrid:0:${balloonGrid[$a]}}"$balloonChar"${allGrid:$(( ${balloonGrid[$a]}+1 ))}
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
    [ $exitAfterPrint == true ] && printf "\a" && sleep 1 && printf "\a" && sleep 1 && printf "\a" && sleep 1 && exit
    # Clock + User Interaction + Boundary Rules
    function up {
      y=$(( y-2 ))
    }
    function left {
      x=$(( x-4 )) # More than the vertical displacement due to landscape frame. Displacement is used instead of a logical grid.
    }
    function down {
      y=$(( y+2 ))
    }
    function right {
      x=$(( x+4 )) # More than the vertical displacement due to landscape frame. Displacement is used instead of a logical grid.
    }
    iteration=$(( iteration+1 ))
    read -sn 6 -t $clockSpeed inp # Clocking integrated in read command. 6 is to read 2 buttons.
    case $inp in
      $'\033[A') move="up" ;; # Up
      $'\033[D') move="left" ;; # Left
      $'\033[B') move="down" ;; # Down
      $'\033[C') move="right" ;; # Right
      *) move="$execMove" ;; # Needed to get the move from the previous iteration, for inertia.
    esac
    execMove="$move" # Without this, somehow, move doesn't survive to the next iteration.
    $execMove # Polymorphism through functional calls.
  done
}

initialize
engine
