#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
CLEAR_DATABASE=$($PSQL "TRUNCATE TABLE games, teams;")

declare -A TEAMS
declare -A GAMES

while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
	if [[ $WINNER != "winner" ]]
	then
		TEAMS["('$WINNER')"]=1
		TEAMS["('$OPPONENT')"]=1
	fi
done < games.csv
if [[ ! -z ${TEAMS[@]} ]]
then
	TEAM_LIST=$(echo "${!TEAMS[*]}" | sed "s/ (/,(/g")
	INSERT_TEAMS=$($PSQL "INSERT INTO teams(name) values $TEAM_LIST;")
fi

while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
	if [[ $YEAR != "year" ]]
	then
		WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
		OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
		GAMES["($YEAR,'$ROUND',$WINNER_ID,$OPPONENT_ID,$WINNER_GOALS,$OPPONENT_GOALS)"]=1
	fi
done < games.csv
if [[ ! -z ${GAMES[@]} ]]
then
	GAME_LIST=$(echo "${!GAMES[*]}" | sed "s/ /,/g")
	INSERT_GAMES=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) values $GAME_LIST;")
fi
