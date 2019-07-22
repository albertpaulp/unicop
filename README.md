# UniCop
Monitors system memory and scale up/down Unicorn worker servers.

## Setup

*  Clone the repo.
*  Run `ruby unicop.rb`

`ruby unicop.rb --dry-run` will output a report and actions to be performed.

## Compatibility

Runs on standard linux distributions, throws error and exit if tried to run on non-linux environments.

## Logging

Creates log file in same directory with name `unicop.log`.
