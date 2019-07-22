class Unicop
  require 'logger'
  require 'yaml'

  attr_reader :config

  def initialize
    load_config
  end

  def perform
    return compatibility_error! unless system_compatible?
    return report if dry_run?

    return increase_worker if can_scale_up?
    return decrease_worker if can_scale_down?
    log("No action to be performed.")
  end


  private

  def can_scale_up?
    return available_mem_percent > config['scale_up_trigger_mem_per'] unless max_worker_threshold?

    false
  end

  def can_scale_down?
    return available_mem_percent < config['scale_down_trigger_mem_per'] unless min_worker_threshold?

    false
  end

  def max_worker_threshold?
    active_worker_count >= config['max_workers']
  end

  def min_worker_threshold?
    active_worker_count <= config['min_workers']
  end

  def increase_worker
    `kill -TTIN #{pid_of_unicorn_master}`
    log("Spawned a worker ! ↑↑↑")
  end

  def decrease_worker
    `kill -TTOU #{pid_of_unicorn_master}`
    log("Killed a worker ! ↓↓↓")
  end

  def active_worker_count
    `ps --ppid #{pid_of_unicorn_master} --no-headers | wc --lines`.strip.to_i
  end

  def pid_of_unicorn_master
    chars_to_number(`ps aux | grep "unicorn_rails master" | grep -v "grep" | cut -d " " -f 2-`)
  end

  def available_memory
    chars_to_mbs(`grep "MemAvailable" /proc/meminfo`)
  end

  def total_memory
    chars_to_mbs(`grep "MemTotal" /proc/meminfo`)
  end

  def available_mem_percent
    (available_memory/total_memory*100).to_i
  end

  def load_config
    @config ||= YAML.load_file('config.yml')
  end

  def chars_to_number(chars)
    chars.match('\d+').to_s.to_i
  end

  def chars_to_mbs(chars)
    chars.match('\d+').to_s.to_f/1024
  end

  def system_compatible?
    Gem::Platform.local.os == 'linux'
  end

  def compatibility_error!
    log("UniCop is only compatible with Linux ! Exiting...")
    exit
  end

  def logger
    @log ||= Logger.new('unicop.log', 'daily')
  end

  def log(message, file = true)
    puts(message)
    logger.info(message)
  end

  def dry_run?
    ARGV[0] == '--dry-run'
  end

  def report
    log("----Report----", false)
    log("Total Memory Memory: #{total_memory} MB", false)
    log("Available Memory: #{available_memory} MB", false)
    log("Available Memory Percentage: #{available_mem_percent} %", false)
    log("Number of workers: #{active_worker_count}", false)
    log("PID of unicorn master: #{pid_of_unicorn_master}", false)
    log("MAX_WORKERS: #{config['max_workers']}", false)
    log("MIN_WORKERS: #{config['min_workers']}", false)
    log("SCALE_UP_TRIGGER_MEM_PER: #{config['scale_up_trigger_mem_per']}%", false)
    log("SCALE_DOWN_TRIGGER_MEM_PER: #{config['scale_down_trigger_mem_per']}%", false)
    log("Can increase worker: #{can_scale_up?}", false)
    log("Can decrease worker: #{can_scale_down?}", false)
  end
end

Unicop.new.perform
