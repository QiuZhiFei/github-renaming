# frozen_string_literal: true

require "octokit"
require_relative "constant"

module Github
  class RepoX
    include Logging

    def initialize(token, repo_path)
      @client = Octokit::Client.new(access_token: token)

      begin
        @repo = @client.repo(repo_path)
      rescue Octokit::Error => e
        logger.error "Repo #{repo_path} does not exist."
        exit 1
      end
    end
    
    # description
    def description
      puts <<-EOS
--------------------------------------
Repo description

name: 
#{@repo.full_name}

default_branch:
#{default_branch}

branches:
#{branches.map { |value| value.name }}
--------------------------------------
      EOS
    end

    # get name
    def name
      @repo.full_name
    end
    
    # get default branch
    def default_branch
      @repo.default_branch
    end
    
    # get all branches
    def branches
      @client.branches(@repo.full_name)
    end
    
    # get branch sha
    def branch_sha(branch)
      begin
        ref = @client.ref(@repo.full_name, "heads/#{branch}")
      rescue Octokit::Error => e
        logger.error "Branch #{branch} does not exist."
        exit 1
      end
      if ref.key?(:object)
        return ref.object.sha
      end
      logger.error "Branch #{branch} does not exist."
      exit 1
    end
    
    # create a new branch
    def create_branch(branch, sha, &block)
      begin
        @client.create_ref(@repo.full_name, "heads/#{branch}", sha)
      rescue Octokit::Error => e
        if e.message.include?("422 - Reference already exists")
          logger.debug "Branch #{branch} already exists."
          block.call if block_given?
        else
          logger.error "Branch #{branch} already exists."
          exit 1
        end
      end
    end
    
    # delete a branch
    def delete_branch(branch)
      @repo.delete_ref("heads/#{branch}")
    end
    
    # set default branch
    def set_default_branch(branch)
      @client.edit_repository(@repo.full_name, default_branch: branch)
    end
  end
end