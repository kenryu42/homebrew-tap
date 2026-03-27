class Autoreview < Formula
  desc "AI code review orchestrator for review, verification, and fixing"
  homepage "https://github.com/kenryu42/autoreview"
  url "https://github.com/kenryu42/autoreview/archive/refs/tags/v0.1.12.tar.gz"
  sha256 "d8d91ddf5f439f8fb5c55f2ad3ce2a3c02a3732aac50f2bbaa159c2e5d50d513"
  license "MIT"

  depends_on "oven-sh/bun/bun"

  def install
    system "bun", "install", "--frozen-lockfile"

    # Compress native dylibs so Homebrew's post-install relocation step
    # cannot detect them as Mach-O files (install_name_tool fails because
    # the header lacks padding for the longer Cellar path).
    # They are decompressed in post_install.
    if OS.mac?
      Dir.glob("node_modules/**/*.dylib").each do |f|
        system "gzip", "-9", f
      end
    end

    libexec.install Dir["*"]

    bun = Formula["oven-sh/bun/bun"].opt_bin/"bun"

    %w[autoreview rr].each do |cmd|
      (bin/cmd).write <<~EOS
        #!/bin/bash
        exec "#{bun}" run "#{libexec}/src/cli.ts" "$@"
      EOS
    end

    (bin/"rrr").write <<~EOS
      #!/bin/bash
      exec "#{bun}" run "#{libexec}/src/cli-rrr.ts" "$@"
    EOS
  end

  def post_install
    Dir.glob("#{libexec}/**/*.dylib.gz").each do |f|
      system "gunzip", f
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/autoreview --version")
  end
end
