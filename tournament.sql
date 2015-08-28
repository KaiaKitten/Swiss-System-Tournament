-- Table definitions for the tournament project.

CREATE DATABASE tournament;
\c tournament;

-- List of all registered players
-- id: unique identifer of player
-- name: name of player
CREATE TABLE players (
    id serial PRIMARY KEY, 
    name text  
);

-- List of all matches between two players
-- id: uniqu identifer of match
-- winner: id of winning player
-- loser: id of losing player
-- draw: whether or not the mach ended in a draw
CREATE TABLE matches (
    id serial PRIMARY KEY,
    winner integer REFERENCES players(id), 
    loser integer REFERENCES players(id),
    draw boolean
);

-- How many wins a player has
CREATE VIEW winnings AS
    SELECT players.id, COUNT(*) as wins
    FROM players, matches
    WHERE players.id = winner OR draw = TRUE
    GROUP BY players.id;

-- How many matches a player has played in
CREATE VIEW plays AS
    SELECT players.id, COUNT(*) as plays
    FROM players, matches
    WHERE players.id = winner OR players.id = loser
    GROUP BY players.id;
    
-- Players standing in tournament. Combines winnings and plays views.    
CREATE VIEW standings AS
    SELECT players.id, 
           players.name, 
           COALESCE(wins,0) as wins, 
           COALESCE(plays,0) as plays
    FROM players
    LEFT JOIN winnings ON players.id = winnings.id 
    LEFT JOIN plays    ON players.id = plays.id
    GROUP BY players.id, wins, plays
    ORDER BY wins DESC;

-- Temporary view used in parings 
-- Lists every other player with an offset of one ordered by highest standing
CREATE VIEW a AS
    WITH a AS(
        SELECT t.*,ROW_NUMBER() OVER (ORDER BY t.wins DESC) AS rn
        FROM standings as t
        ) SELECT * FROM a WHERE (rn+1) % 2 = 0;
        
-- Temporary view used in parings
-- Lists every other player ordered by highest standing
CREATE VIEW b AS       
    WITH b AS(
        SELECT t.*,ROW_NUMBER() OVER (ORDER BY t.wins DESC) AS rn
        FROM standings as t
        ) SELECT * FROM b WHERE rn % 2 = 0;

-- Pairing of each player used to decide what players play each other next
-- Determined by standing. JOINs view a and view b to obtain pairing.
-- Rematchs are not allowed.        
CREATE VIEW pairings AS
    SELECT DISTINCT a.id as id1, a.name as name1, b.id as id2, b.name as name2
    FROM matches, a LEFT JOIN b ON (a.rn+1) = b.rn
    WHERE (id1, id2) NOT IN (SELECT winner, loser FROM matches)
