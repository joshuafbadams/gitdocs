# -*- encoding : utf-8 -*-

require 'active_record'

module Gitdocs
  # @!attribute path
  #   @return [String]
  # @!attribute polling_interval
  #   @return [Double] defaults to 15.0
  # @!attribute notification
  #   @return [Boolean] default to true
  # @!attribute remote_name
  #   @return [String] default to 'origin'
  # @!attribute branch_name
  #   @return [String] default to 'master'
  # @attribute sync_type
  #   @return ['full','fetch'] default to 'full'
  class Share < ActiveRecord::Base
    # @return [Array<String>]
    def self.paths
      all.map(&:path)
    end

    # @param [#to_i] index
    #
    # @return [Share]
    def self.at(index)
      all[index.to_i]
    end

    # @param [String] path
    #
    # @return [Share]
    def self.find_by_path(path)
      where(path: File.expand_path(path)).first
    end

    # @overload create_by_path!(path)
    #   @param [String] path
    #
    # @overload create_by_path(path, attributes)
    #   @param [String] path
    #   @param [Hash] attributes
    #
    # @return [Share]
    def self.create_by_path!(path, attributes = {})
      create!(attributes.merge(path: File.expand_path(path)))
    end

    # @param [Hash] updated_shares
    #
    # @return [void]
    def self.update_all(updated_shares)
      updated_shares.each do |index, share_config|
        # Skip the share update if there is no path specified.
        next unless share_config['path'] && !share_config['path'].empty?

        # Split the remote_branch into remote and branch
        remote_branch = share_config.delete('remote_branch')
        share_config['remote_name'], share_config['branch_name'] =
          remote_branch.split('/', 2) if remote_branch

        at(index).update_attributes(share_config)
      end
    end

    # @param [Integer] id of the share to remove
    #
    # @return [Boolean] whether the share was deleted
    def self.remove_by_id(id)
      find(id).destroy
      true
    rescue ActiveRecord::RecordNotFound
      false
    end

    # @param [String] path of the share to remove
    #
    # @return [void]
    def self.remove_by_path(path)
      where(path: File.expand_path(path)).destroy_all
    end
  end
end
