class RalphReview < Formula
  desc "Orchestrating coding agents for code review, verification and fixing"
  homepage "https://github.com/kenryu42/ralph-review"
  url "https://github.com/kenryu42/ralph-review/archive/refs/tags/v0.1.4.tar.gz"
  sha256 "c9678bd37ebadc23410c6bd651f1e45f6ea147ed67810848604eddb1787378e7"
  license "MIT"

  depends_on "oven-sh/bun/bun"

  def install
    system "bun", "install", "--frozen-lockfile"
    libexec.install Dir["*"]

    %w[rr ralph-review].each do |cmd|
      (bin/cmd).write <<~EOS
        #!/bin/bash
        exec "#{Formula["oven-sh/bun/bun"].opt_bin}/bun" run "#{libexec}/src/cli.ts" "$@"
      EOS
    end

    (bin/"rrr").write <<~EOS
      #!/bin/bash
      exec "#{Formula["oven-sh/bun/bun"].opt_bin}/bun" run "#{libexec}/src/cli-rrr.ts" "$@"
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/rr --version")
  end
end
