require 'rubygems'
require 'autotest'

##
# Autotest::Screen displays autotest/autospec progress on GNU Screen's status line.
#
# == FEATURES:
# * Screenshots are available in here[http://f.hatena.ne.jp/yoshuki/autotest_screen/].
#
# == SYNOPSIS
# $HOME/.autotest
#   require 'autotest/screen'
#   # Autotest::Screen.statusline = '%H %`%-w%{=b bw}%n %t%{-}%+w (your statusline)'
#

class Autotest::Screen
  VERSION = '4.0.3'

  DEFAULT_STATUSLINE = '%H %`%-w%{=b bw}%n %t%{-}%+w'
  DEFAULT_SCREEN_CMD = 'screen'

  SCREEN_COLOR = {
    :black  => 'dd',
    :green  => 'gw',
    :yellow => 'yk',
    :red    => 'rw'
  }

  def self.message(msg, color = :black)
    col = SCREEN_COLOR[color]
    msg = %Q[ %{=b #{col}} #{msg} %{-}]
    send_cmd(msg)
  end

  def self.clear
    send_cmd('')
  end

  def self.run_screen_session?
    str = `#{screen_cmd} -ls`
    str.match(/(\d+) Socket/) && ($1.to_i > 0)
  end

  def self.execute?
    !($TESTING || !run_screen_session?)
  end

  @statusline, @screen_cmd = nil
  def self.statusline; @statusline || DEFAULT_STATUSLINE.dup; end
  def self.statusline=(a); @statusline = a; end
  def self.screen_cmd; @screen_cmd || DEFAULT_SCREEN_CMD.dup; end
  def self.screen_cmd=(a); @screen_cmd = a; end

  def self.send_cmd(msg)
    cmd = %(#{screen_cmd} -X eval 'hardstatus alwayslastline "#{(statusline + msg).gsub('"', '\"')}"') #' stupid ruby-mode
    system cmd
    nil
  end

  @last_message = {}

  # All blocks return false, to execute each of following blocks defined in user's own ".autotest".

  # Do nothing.
  #Autotest.add_hook :all_good do |at, *args|
  #  next false
  #end

  Autotest.add_hook :died do |at, *args|
    message "Exception occured. (#{at.class})", :red
    next false
  end

  # Do nothing.
  #Autotest.add_hook :green do |at, *args|
  #  next false
  #end

  Autotest.add_hook :initialize do |at, *args|
    message "Run with #{at.class}" if execute?
    next false
  end

  # Do nothing.
  #Autotest.add_hook :interrupt do |at, *args|
  #  next false
  #end

  Autotest.add_hook :quit do |at, *args|
    clear if execute?
    next false
  end

  Autotest.add_hook :ran_command do |at, *args|
    next false unless execute?

    output = at.results.join

    case at.class.name
    when 'Autotest', 'Autotest::Rails'
      results = output.scan(/(\d+)\s*failures?,\s*(\d+)\s*errors?/).first
      num_failures, num_errors = results.map{|r| r.to_i}

      if num_failures > 0 || num_errors > 0
        @last_message = {:message => "Red F:#{num_failures} E:#{num_errors}", :color => :red}
      else
        @last_message = {:message => 'All Green', :color => :green}
      end
    when 'Autotest::Rspec', 'Autotest::Rspec2', 'Autotest::RailsRspec', 'Autotest::RailsRspec2', 'Autotest::MerbRspec'
      results = output.scan(/(\d+)\s*examples?,\s*(\d+)\s*failures?(?:,\s*(\d+)\s*pendings?)?/).first
      _, num_failures, num_pendings = results.map{|r| r.to_i}

      if num_failures > 0
        @last_message = {:message => "Fail F:#{num_failures} P:#{num_pendings}", :color => :red}
      elsif num_pendings > 0
        @last_message = {:message => "Pend F:#{num_failures} P:#{num_pendings}", :color => :yellow}
      else
        @last_message = {:message => 'All Green', :color => :green}
      end
    end
    next false
  end

  # Do nothing.
  #Autotest.add_hook :red do |at, *args|
  #  next false
  #end

  # Do nothing.
  #Autotest.add_hook :reset do |at, *args|
  #  next false
  #end

  Autotest.add_hook :run_command do |at, *args|
    message 'Running' if execute?
    next false
  end

  # Do nothing.
  #Autotest.add_hook :updated do |at, *args|
  #  next false
  #end

  Autotest.add_hook :waiting do |at, *args|
    message @last_message[:message], @last_message[:color] if execute?
    next false
  end
end
