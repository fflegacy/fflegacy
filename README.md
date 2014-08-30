# Fantasy Football Legacy League

## Purpose

This repository is used as an official record for player transactions, matchups,
and other statistics. Over time, we can use this data to analyze how our fantasy
teams perform in their fantasy league, _treating this league as if it were
real_.

That last part is included not because we're hardcore role-players, but because
including ALL relevant stats of ALL players is beyond the scope of this project.
It's sufficient enough to be able to look in the archives and remind someone
they had a terrible draft or that they left points on their bench; there's no
need to analyze how good someone is at the waiver wire or how good players
actually are IRL. That's what [Google](https://www.google.com) is for.

## Data Overview

### Scoring

A scoring table that matches what's in the wiki, in CSV format for your
convenience. The Action names match the column headers for the Stats table.

### Stats

The scoreable stats for each player in a given week. When combined with the
Scoring table, you can find out the points each player earned in that week.

### Matchups

The matchups for the season. This includes Home and Away teams, which you may
find surprising.

### Locks

These are the list of players and the positions they are locked into each week
by their owners. Combined with the Stats and Scoring tables, you can calculate
how many points a team scored in a week.

### Transactions

A list of all player transactions that occur during the season, from Draft Day
until the Super Bowl.

## Data Format

Data is kept in a CSV format so it can be used by everyone, including those who
think writing code is for nerds. CSVs are prepended with the season year they
are for, and are currently kept in the `seasons` directory. If there ends up
being data that is not season-specific, we can find another directory for it.

Any scripts that are written will be kept in the `scripts` directory. If you'd
like to contribute, make a pull request. There are no language restrictions.

## Data Caveats

We made an effort to make this as human-readable as possible. Unfortunately, we
_might_ run into problems because some players have the same name. Rather than
come up with some arbitrary ID system for players, we're just going to cross
that bridge if/when we get there. A similar problem might occur with
representing teams by their owners' initials.

## Wiki

The [Wiki](https://github.com/bergren2/fflegacy/wiki) is used to document the
rules for this league. We keep it there because it's not data and therefore not
easily manipulated by code and/or your favorite spreadsheet program.
