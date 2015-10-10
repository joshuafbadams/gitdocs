# -*- encoding : utf-8 -*-

require 'thread'
require 'dante'
require 'socket'
require 'shell_tools'
require 'guard'
require 'grit'
require 'rugged'
require 'table_print'

require 'gitdocs/version'
require 'gitdocs/initializer'
require 'gitdocs/share'
require 'gitdocs/configuration'
require 'gitdocs/runner'
require 'gitdocs/server'
require 'gitdocs/cli'
require 'gitdocs/manager'
require 'gitdocs/notifier'
require 'gitdocs/git_notifier'
require 'gitdocs/repository'
require 'gitdocs/repository/path'
require 'gitdocs/repository/invalid_error'
require 'gitdocs/repository/committer'
require 'gitdocs/search'

module Gitdocs
  # @param [nil, Integer] override_web_port
  def self.start(override_web_port)
    @manager.stop if @manager
    @manager = Manager.new
    @manager.start(override_web_port)
  end

  def self.restart
    @manager.restart
  end

  def self.stop
    @manager.stop
  end

  # @param [String] message
  # @return [void]
  def self.log_debug(message)
    logger.debug(message)
  end

  # @param [String] message
  # @return [void]
  def self.log_info(message)
    logger.info(message)
  end

  # @param [String] message
  # @return [void]
  def self.log_warn
    logger.warn(message)
  end

  # @param [String] message
  # @return [void]
  def self.log_error
    logger.error(message)
  end

  ##############################################################################

  private_class_method

  # @return [Logger]
  def self.logger
    return @logger if @logger

    output =
      if Initializer.foreground
        STDOUT
      else
        File.expand_path('log', Initializer.root_dirname)
      end
    @logger = Logger.new(output)
    @logger.level = Initializer.verbose ? Logger::DEBUG : Logger::INFO
    @logger
  end
end
