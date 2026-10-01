# Testing Scripts

A spec must never have side effects. Don't run the script as a subprocess, because nothing in it can be mocked there. Instead, `load` it into the spec's process with a stubbed `ARGV`, and stub every side effect first: commands, network calls, and writes outside a temporary directory. The script's top-level code runs on `main`, so stub its calls there.

```ruby
SCRIPT = File.expand_path("<name>.rb", __dir__)

RSpec.describe "<name>" do
  let(:main) { TOPLEVEL_BINDING.receiver }

  def run_script(*arguments)
    stub_const("ARGV", arguments)
    load SCRIPT
  end

  before do
    allow(main).to receive(:system)
    allow($stdout).to receive(:write)
  end

  context "when an argument is not provided" do
    it "prints a usage message" do
      expect { run_script }.to raise_error(SystemExit).and output(/Usage:/).to_stderr
    end
  end

  context "when an argument is provided" do
    it "prints a confirmation" do
      expect { run_script("<argument>") }.to output("Notified.\n").to_stdout
    end

    it "sends a notification" do
      run_script("<argument>")

      expect(main).to have_received(:system).with("osascript", "-e", /display notification/, exception: true)
    end
  end
end
```

`exit` and `abort` raise `SystemExit`, so a spec for a failure path expects that error. Stubbing `$stdout.write` keeps the script's output out of the spec run; `output(...).to_stdout` still captures it.
