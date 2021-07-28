# frozen_string_literal: true

require "thor"
require "logger"
require_relative "renaming/version"
require_relative "cli"
require_relative "constant"

module Github
  class Renaming < Thor
    class_option :token, type: :string, aliases: '-t', desc: "User's Github Token at github.com"
    class_option :repo, type: :string, aliases: '-r', desc: "User's Repo at at github.com"
    
    desc "default-branch <old-branch> <new-branch>", "Rename default branch on GitHub"
    map "-d" => :default_branch
    def default_branch(*args)
      prepare(*args)
      Github.rename_default_branch(*args, options)
    end
    
    desc "version", "Show github-renaming version number and quit (aliases: `v`)."
    map ["v", "-v", "--version"] => :version
    def version
      say "github-renaming #{Github::VERSION}"
    end

    private
    def prepare(*args)
      Github.check_token(*args, options)
    end
  end
end