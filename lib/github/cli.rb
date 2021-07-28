# frozen_string_literal: true

require "octokit"
require "thor"
require "httparty"
require "highline"
require_relative "constant"
require_relative "repox"

module Github
  module CLI
    include Logging
    
    def check_token(*args, options)
      token = options[:token] || ""
      _assert_not_nil_token(token)
      
      url = "https://api.github.com/users/codertocat"
      res = HTTParty.get(url, headers: { 
      "Authorization" => "token #{token}"})
      data = JSON.parse(res.body)
      return unless !data.member?("login")
      logger.error "Github token is invalid."
      exit 1
    end
    
    def rename_default_branch(*args, options)
      token = options[:token]
      
      repo_path = options[:repo] || ""
      _assert_not_nil_repo(repo_path)
      
      old_branch = args[0] || "master"
      new_branch = args[1] || "main"
      if old_branch == new_branch
        logger.error "Branch #{branch} is the same as #{based_on_branch}"
        exit 1
      end
      
      _rename_prompt(repo_path, token, old_branch, new_branch)
      
      repo = Github::RepoX.new(token, repo_path)
      # get the sha
      old_branch_sha = repo.branch_sha(old_branch)
      # create new branch
      logger.debug "Creating branch #{new_branch} based on #{old_branch}."
      repo.create_branch(new_branch, old_branch_sha) {
        _delete_branch_prompt(repo_path, token, new_branch)
        logger.debug "Deleting branch #{new_branch}."
        repo.delete_branch(new_branch)
      }
      # set default branch
      logger.debug "Setting #{new_branch} as default branch."
      repo.set_default_branch(new_branch)
      # delete old branch
      logger.debug "Deleting #{old_branch}."
      repo.delete_branch(old_branch)

      # local
      if new_branch == "main"
        global_default_branch = `git config --global init.defaultBranch`.strip
        if global_default_branch != new_branch
          `git config --global init.defaultBranch #{new_branch}`
          logger.debug "Setting #{new_branch} as global default branch."
        end
      end
      
      logger.info "Finished."
    end
    
    private
    def _rename_prompt(repo_path, token, old_branch, new_branch)
      answer = HighLine.agree("
------------------------------------
Action: Renaming branch
Repo: #{repo_path}
Token: #{token}
Create new branch: #{new_branch}
Delete old branch: #{old_branch}
Rename default branch: #{old_branch} -> #{new_branch}
------------------------------------
Continue? (y/n) ")
      if answer == false
        exit 1
      end
    end

    def _delete_branch_prompt(repo_path, token, branch)
      answer = HighLine.agree("
------------------------------------
Action: Deleting branch
Repo: #{repo_path}
Token: #{token}
Delete branch: #{branch}
------------------------------------
Continue? (y/n) ")
      if answer == false
        exit 1
      end
    end
    
    def _assert_not_nil_token(token)
      return unless token.empty?
      logger.error "You must provide a GitHub token to use this command. See 'github-renaming --help'.
      
Creating a personal access token
https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token"
      exit 1
    end
    
    def _assert_not_nil_repo(repo)
      return unless repo.empty?
      logger.error "You must provide a GitHub repo to use this command. See 'github-renaming --help'."
      exit 1
    end
  end
end

module Github
  extend CLI
end