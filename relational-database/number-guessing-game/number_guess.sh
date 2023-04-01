#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guessing_game -t --no-align -c"

echo "Enter your username: "
read USERNAME_INPUT

USER=$($PSQL "SELECT * FROM scores WHERE username = '$USERNAME_INPUT'")
if [[ -z $USER ]]
then
  # user's first time, add to database
  echo "Welcome, $USERNAME_INPUT! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO scores(username) VALUES('$USERNAME_INPUT')")
  USER_INFO=($USERNAME_INPUT 0 -1)
else
  IFS='|' read -r -a USER_INFO <<< "$USER"
  echo "Welcome back, ${USER_INFO[0]}! You have played ${USER_INFO[1]} games, and your best game took ${USER_INFO[2]} guesses."
fi

SECRET_NUMBER=$(( ( RANDOM % 1000 )  + 1 ));
ATTEMPTS=1;
echo "Guess the secret number between 1 and 1000: "

while true
do
  read INPUT

  if [[ ! $INPUT =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again: "
  elif [[ $INPUT == $SECRET_NUMBER ]]
  then
    echo "You guessed it in $ATTEMPTS tries. The secret number was $SECRET_NUMBER. Nice job!"

    # update database
    NUM_GAMES=$((${USER_INFO[1]}+1))
    if [[ ${USER_INFO[2]} == -1 ]] || [[ $ATTEMPTS < ${USER_INFO[2]} ]] # -1 means this is the first game
    then
      # new top score
      UPDATE_USER_RESULT=$($PSQL "UPDATE scores SET games_played = $NUM_GAMES, best_game_guesses = $ATTEMPTS WHERE username = '${USER_INFO[0]}'")
    else
      UPDATE_USER_RESULT=$($PSQL "UPDATE scores SET games_played = $NUM_GAMES WHERE username = '${USER_INFO[0]}'")
    fi

    break;
  elif [[ $INPUT > $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again: "
    ((ATTEMPTS=ATTEMPTS+1))
  elif [[ $INPUT < $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again: "
    ((ATTEMPTS=ATTEMPTS+1))
  fi
done
