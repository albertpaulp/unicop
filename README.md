# UniCop
Monitors system memory and scale up/down Unicorn workers.

## Setup

*  Clone the repo.
*  Run `ruby unicop.rb`
 
`ruby unicop.rb --dry-run` will output a report and actions to be performed.

Can be used with cron to run in every n minutes.

eg. `*/10 * * * * /home/ubuntu/unicop/start.sh` (Runs in every 10 minutes)

## Configuration

Configuration is read from `config.yml` in project directory.

**scale_up_trigger_mem_per**: Percentage of memory when new worker gets spawned(Scale Up).

**scale_down_trigger_mem_per**: Percentage of memory when existing worker gets killed(Scale Down).

**max_workers**: Maximum number of workers allowed.

**min_workers**: Minimum number of workers allowed.

## Compatibility

Runs on standard linux distributions, throws error and exit if tried to run on non-linux environments.

## Logging

Creates log file in same directory with name `unicop.log`.

## Contributing

You can contribute to this project by adding issues and raising MRs.

1. Fork it ( https://github.com/albertpaulp/unicop/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
