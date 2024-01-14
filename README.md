# Welcome to My Sqlite
***

## Task

### Part 00

Create a class called MySqliteRequest in my_sqlite_request.rb. It will have a similar behavior than a request on the real sqlite.

All methods, except run, will return an instance of my_sqlite_request. You will build the request by progressive call and execute the request by calling run.

Each row must have an ID.

We will do only 1 join and 1 where per request.

### Part 01

Create a program which will be a Command Line Interface (CLI) to your MySqlite class.
It will use readline and we will run it with ruby my_sqlite_cli.rb.

It will accept request with:

```
SELECT|INSERT|UPDATE|DELETE
FROM
WHERE (max 1 condition)
JOIN ON (max 1 condition) Note, you can have multiple WHERE
```

## Description

Used the CSV library for retrieving and manipulating data within them.

Used Readline to get prompts from the CLI, parsing them into an object that is to be used in different requests.

## Installation

N/a

## Usage

### CLI requests

`ruby my_sqlite_cli.rb` to open cli prompt

perform various queries such as:

`SELECT * FROM nba_player_data.csv;`
`SELECT name, age FROM nba_player_data.csv;`
`SELECT name, birth_city FROM nba_player_data.csv JOIN nba_players.csv ON name=Player;`

`INSERT INTO nba_player_data.csv VALUES (name, year_start, year_end, position, height, weight, birth_date, college);`

### Running tests

`ruby my_sqlite_request_test.rb && TEST=true ruby my_sqlite_cli_test.rb`

Should result in a total of 13 tests and 27 test assertions for coverage of each type of request.

### The Core Team


<span><i>Made at <a href='https://qwasar.io'>Qwasar SV -- Software Engineering School</a></i></span>
<span><img alt='Qwasar SV -- Software Engineering School's Logo' src='https://storage.googleapis.com/qwasar-public/qwasar-logo_50x50.png' width='20px' /></span>
