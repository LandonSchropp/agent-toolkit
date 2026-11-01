# frozen_string_literal: true

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rspec", "~> 3.13"
end

require "rspec/autorun"
require "fileutils"
require "open3"
require "tmpdir"

SCRIPT = File.expand_path("build-skill-zips.rb", __dir__)
AGENT_TOOLKIT = File.expand_path("~/Development/agent-toolkit")
PERSONAL_AGENT_TOOLKIT = File.expand_path("~/Development/personal-agent-toolkit")

RSpec.describe "build-skill-zips" do
  let(:main) { TOPLEVEL_BINDING.receiver }
  let(:temporary_directory) { Dir.mktmpdir }
  let(:output_directory) { File.join(temporary_directory, "output") }

  let(:fixtures) do
    {
      AGENT_TOOLKIT => File.join(temporary_directory, "agent-toolkit"),
      PERSONAL_AGENT_TOOLKIT => File.join(temporary_directory, "personal-agent-toolkit")
    }
  end

  def run(*command)
    stdout, status = Open3.capture2(*command)
    raise "#{command.join(" ")} failed" unless status.success?

    stdout
  end

  def commit(repository, files, executables = [])
    directory = fixtures.fetch(repository)

    files.each do |path, content|
      FileUtils.mkdir_p(File.dirname(File.join(directory, path)))
      File.write(File.join(directory, path), content)
    end

    executables.each { FileUtils.chmod(0o755, File.join(directory, _1)) }
    run("git", "-C", directory, "add", "--all")
    run("git", "-C", directory, "-c", "user.name=Spec", "-c", "user.email=spec@example.com", "commit", "--quiet", "--message=Commit")
    run("git", "-C", directory, "rev-parse", "HEAD").strip
  end

  def run_script(*arguments)
    stub_const("ARGV", arguments)
    load SCRIPT
  end

  def zip_file(name, path)
    run("unzip", "-p", File.join(output_directory, "#{name}.zip"), "#{name}/#{path}")
  end

  before do
    fixtures.each_value { run("git", "init", "--quiet", "--initial-branch=main", _1) }

    commit(AGENT_TOOLKIT, {
      "plugins/ls-browser/skills/browser/SKILL.md" => "Use the `ls-notes:note` skill.\n",
      "plugins/ls-git/skills/git-commit/SKILL.md" => "Commit.\n"
    })

    commit(PERSONAL_AGENT_TOOLKIT, {
      "plugins/ls-health/skills/coach/SKILL.md" => "Use the `ls-browser:browser` skill.\n",
      "plugins/ls-health/skills/coach/scripts/run.rb" => "puts 1\n",
      "plugins/ls-ynab/skills/ynab/SKILL.md" => "Budget.\n"
    }, ["plugins/ls-health/skills/coach/scripts/run.rb"])

    allow(main).to receive(:git) do |repository, *arguments|
      run("git", "-C", fixtures.fetch(repository), *arguments)
    end

    allow($stdout).to receive(:write)
  end

  after do
    FileUtils.remove_entry(temporary_directory)
    %i[SKILLS PLUGIN_PREFIX].each { Object.send(:remove_const, _1) if Object.const_defined?(_1) }
  end

  context "when the --output flag is missing" do
    it "prints an error" do
      expect { run_script }.to raise_error(SystemExit).and output(/Error: The --output flag is required/).to_stderr
    end
  end

  context "when an option is invalid" do
    it "prints an error" do
      expect { run_script("--unknown") }.to raise_error(SystemExit).and output(/Error: The option --unknown is invalid/).to_stderr
    end
  end

  context "when --since is not provided" do
    it "prints a zip path for every matched skill" do
      expect { run_script("--output", output_directory) }.to output(<<~OUTPUT).to_stdout
        #{output_directory}/browser.zip
        #{output_directory}/coach.zip
        #{output_directory}/ynab.zip
      OUTPUT
    end

    it "rewrites plugin-qualified skill references to bare names" do
      run_script("--output", output_directory)

      expect(zip_file("coach", "SKILL.md")).to eq("Use the `browser` skill.\n")
    end

    it "keeps the executable bit" do
      run_script("--output", output_directory)

      expect(run("zipinfo", File.join(output_directory, "coach.zip"), "coach/scripts/run.rb")).to start_with("-rwxr-xr-x")
    end
  end

  context "when --since is a commit in one of the repositories" do
    let!(:since) { commit(PERSONAL_AGENT_TOOLKIT, { "plugins/ls-health/skills/coach/SKILL.md" => "Old.\n" }) }

    before do
      commit(PERSONAL_AGENT_TOOLKIT, { "plugins/ls-health/skills/coach/SKILL.md" => "New.\n" })
    end

    it "prints only the skills that changed since that commit" do
      expect { run_script("--output", output_directory, "--since", since) }.to output("#{output_directory}/coach.zip\n").to_stdout
    end
  end

  context "when --since is not a commit in either repository" do
    it "prints an error" do
      expect { run_script("--output", output_directory, "--since", "0" * 40) }
        .to raise_error(SystemExit).and output(/Error: The commit 0{40} is not in either repository/).to_stderr
    end
  end

  context "when two matched skills share a bare name" do
    before do
      commit(PERSONAL_AGENT_TOOLKIT, { "plugins/ls-assistant/skills/browser/SKILL.md" => "Browse.\n" })
    end

    it "prints an error" do
      expect { run_script("--output", output_directory) }
        .to raise_error(SystemExit).and output(/Error: More than one skill is named browser/).to_stderr
    end
  end
end
