Swiss-System Tournament
=======================

A Swiss-System Tournament implemented in Python and PostgreSQL.

Requirements
------------
* Pythong >= 3
* PostgresQL >= 9.3.9

Setup
-----

Set up or use an existing PostgreSQL server and user.

Run `\i tournament.sql` in the psql prompt to create the Database, Tables, and Views.

Usage
-----

The `tournament.py` python script containts the functions and their documentation to communicate with the database, import these into your project. 

Run `tournament_test.py` for unit testing. **This WILL DROP your tables and overwrite them.**

Credits
-------

* Udacity for a great course
