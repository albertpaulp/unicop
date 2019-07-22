class Unicop
  require 'logger'

  SCALE_UP_TRIGGER_MEM_PER = 30
  SCALE_DOWN_TRIGGER_MEM_PER = 5
  MAX_WORKERS = 3
  MIN_WORKERS = 2

  def new
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
    return available_mem_percent > SCALE_UP_TRIGGER_MEM_PER unless max_worker_threshold?

    false
  end

  def can_scale_down?
    return available_mem_percent < SCALE_DOWN_TRIGGER_MEM_PER unless min_worker_threshold?

    false
  end

  def max_worker_threshold?
    active_worker_count >= MAX_WORKERS
  end

  def min_worker_threshold?
    active_worker_count <= MIN_WORKERS
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
    log("MAX_WORKERS: #{MAX_WORKERS}", false)
    log("MIN_WORKERS: #{MIN_WORKERS}", false)
    log("SCALE_UP_TRIGGER_MEM_PER: #{SCALE_UP_TRIGGER_MEM_PER}%", false)
    log("SCALE_DOWN_TRIGGER_MEM_PER: #{SCALE_DOWN_TRIGGER_MEM_PER}%", false)
    log("Can increase worker: #{can_scale_up?}", false)
    log("Can decrease worker: #{can_scale_down?}", false)
  end
end

Unicop.new.perform
