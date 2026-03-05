class RalphReview < Formula
  desc "Orchestrating coding agents for code review, verification and fixing"
  homepage "https://github.com/kenryu42/ralph-review"
  url "https://github.com/kenryu42/ralph-review/archive/refs/tags/v0.1.4.tar.gz"
  sha256 "c9678bd37ebadc23410c6bd651f1e45f6ea147ed67810848604eddb1787378e7"
  license "MIT"

  depends_on "oven-sh/bun/bun"

  def install
    system "bun", "install", "--frozen-lockfile"

    # Temporarily rename native dylibs so Homebrew's post-install relocation
    # step skips them (install_name_tool fails because the header lacks padding
    # for the longer Cellar path). They are restored in post_install.
    Dir.glob("node_modules/**/*.dylib").each { |f| File.rename(f, "#{f}.raw") } if OS.mac?

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
    Dir.glob("#{libexec}/**/*.dylib.raw").each do |f|
      File.rename(f, f.delete_suffix(".raw"))
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/rr --version")
  end
end
