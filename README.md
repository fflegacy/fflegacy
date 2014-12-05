# Fantasy Football Legacy League

I still can't believe this is a thing.

## Table of Contents

- [Purpose](#purpose)
- [Project Setup](#project-setup)
  - [Environment Prereqs](#environment-prereqs)
  - [Initial Setup](#initial-setup)
  - [Development](#development)
  - [Deployment](#deployment)
    - [Caveats](#caveats)
- [Data Overview](#data-overview)
  - [Scoring](#scoring)
  - [Stats](#stats)
  - [Matchups](#matchups)
  - [Locks](#locks)
  - [Transactions](#transactions)
  - [Data Format](#data-format)
  - [Data Caveats](#data-caveats)
- [Wiki](#wiki)

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

## Project Setup

### Environment Prereqs

You should have the following minimally setup:

- [Git](https://help.github.com/articles/set-up-git) (duh)
- [rbenv](https://github.com/sstephenson/rbenv)
& [ruby-build](https://github.com/sstephenson/ruby-build)

### Initial  Setup

    $ git clone git@github.com:bergren2/fflegacy.git
    $ cd fflegacy
    $ rbenv install
    $ gem install bundler
    $ bundle install

### Development

Fire up

    $ bin/middleman server

and then check out the site at [localhost:4567](http://localhost:4567).

### Deployment

    $ bin/rake publish

#### Caveats

If your directory is dirty, `git stash` before deploying.

If Rake complains about there already being an `origin` remote, remove the `build`
directory in its entirety.


## Data Overview

We had some trouble with the Yahoo API, so we're using YQL queries to
gather the data as JSON and manually update it in the repo for scripts to
use, including those that convert it to CSVs for non-programmers.

If you're updating the JSON, please remember to **turn off the Diagnostics
and Debug options**. You can then click the "Select All" link to copy the
JSON and then right click to copy it.

Before checking in your changes, you should also run some scripts against
the JSON and CSV data to compare them to what's shown on Yahoo.

### Scoring

A scoring table that matches what's in the wiki, in CSV format for your
convenience. The Action names match the column headers for the Stats table.

### Stats

The scoreable stats for each player in a given week. When combined with the
Scoring table, you can find out the points each player earned in that week.

**Before you commit, make sure you scrub out the emails.** There is a method
that will do this for you.

[YQL Query](http://developer.yahoo.com/yql/console/?q=select%20*%20from%20fantasysports.teams.roster.stats%20where%20team_key%3D'331.l.246998.t.1'%20and%20type%3Dweek%20and%20week%3D1):

    select * from fantasysports.teams.roster.stats where team_key='331.l.246998.t.1' and type=week and week=1

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

[YQL Query](http://developer.yahoo.com/yql/console/?q=select%20*%20from%20fantasysports.leagues.transactions%20where%20league_key%3D'331.l.246998'):

    select * from fantasysports.leagues.transactions where league_key='331.l.246998'

### Data Format

Data is kept in a CSV format so it can be used by everyone, including those who
think writing code is for nerds. CSVs are kept in the `seasons` directory and
organized further by week if necessary. If there ends up being data that is not
season-specific, we can find another directory for it.

Raw JSON data will be kept in the `yql` directory. Any scripts that are written
will be kept in the `scripts` directory. If you'd like to contribute, make
a pull request. There are no language restrictions.

### Data Caveats

We made an effort to make this as human-readable as possible. Unfortunately, we
_might_ run into problems because some players have the same name. Rather than
come up with some arbitrary ID system for players, we're just going to cross
that bridge if/when we get there. A similar problem might occur with
representing teams by their owners' initials.

## Wiki

The [Wiki](https://github.com/bergren2/fflegacy/wiki) is used to document the
rules for this league. We keep it there because it's not data and therefore not
easily manipulated by code and/or your favorite spreadsheet program.
