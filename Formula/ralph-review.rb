class RalphReview < Formula
  desc "Orchestrating coding agents for code review, verification and fixing"
  homepage "https://github.com/kenryu42/ralph-review"
  url "https://github.com/kenryu42/ralph-review/archive/refs/tags/v0.2.1.tar.gz"
  sha256 "3a1068ca9f247c6d0850e100c16c6f4b6319ead6d8ea3fa5e998ca7c3d43ef61"
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

    %w[rr ralph-review].each do |cmd|
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
    assert_match version.to_s, shell_output("#{bin}/rr --version")
  end
end
