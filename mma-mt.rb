class MmaMt < Formula
  desc "Mathematica package to compute convolutions"
  homepage "http://arxiv.org/abs/1307.6925"
  url "http://www.ttp.kit.edu/Progdata/ttp13/ttp13-027/MT-1.0.tar.gz"
  sha256 "002b37a0a6a9a26825ae4450ce60661b19e09e2f1cd4a5cce749a22d5add4fa7"

  option "with-weight7", "Install up to weight 7 tables"
  option "with-weight8", "Install up tp weight 8 tables"
  option "with-dump",    "Build binary tables"

  depends_on "mma-hpl"

  resource "MTtable7" do
    url "http://www.ttp.kit.edu/Progdata/ttp13/ttp13-027/MTtable7.tar.gz"
    sha256 "fdf388330efc14953dbb5ee4bb0e534cc44bf207cb375293a9741d4dc95949b5"
  end

  resource "MTtable8" do
    url "http://www.ttp.kit.edu/Progdata/ttp13/ttp13-027/MTtable8.tar.gz"
    sha256 "ec0f614775b1fd50cf6c28080da466a48f9b19517056ef8ee90e4317aebe79cc"
  end

  def env_math
    s = ENV["HOMEBREW_MATH"]
    if s.nil? || s.empty?
      if OS.mac?
        s = "/Applications/Mathematica.app/Contents/MacOS/MathKernel"
      else
        s = "math"
      end
      ENV["HOMEBREW_MATH"] = s
    end
    if which s
      ohai "Mathematica path: #{s}"
    else
      onoe "Mathematica (#{s}) not found."
    end
  end

  def install_tables(installpath, depth)
    if build.with? "dump"
      env_math
      if buildpath != Pathname.pwd
        cp buildpath/"MakeDump.m", Dir.pwd
      end
      system ENV["HOMEBREW_MATH"], "-run", \
             "MaxWeight=#{depth};<<MakeDump`;Quit[]'"
      File.chmod 0644, "MTtab#{depth}.mx" # 666 -> 644
      File.chmod 0644, "MTitab#{depth}.mx"
      installpath.install ["MTtab#{depth}.mx",
                           "MTitab#{depth}.mx"]
    end
    installpath.install ["MTtab#{depth}.m",
                         "MTitab#{depth}.m"]
  end

  def install
    installpath = share/"Mathematica"/"Applications"/"MT-#{version}"
    installpath.install "MT.m"

    if build.with? "weight8"
      resource("MTtable8").stage do
        install_tables(installpath, 8)
      end
    elsif build.with? "weight7"
      resource("MTtable7").stage do
        install_tables(installpath, 7)
      end
    else
      install_tables(installpath, 6)
    end

    (pkgshare/"examples").install "example.nb"

    (buildpath/"MT.m").write <<~EOS
      If[!MemberQ[$Path, "#{installpath}"],
        AppendTo[$Path, "#{installpath}"];
      ];
      Get["#{installpath/"MT.m"}"]
    EOS
    (share/"Mathematica"/"Applications").install "MT.m"
  end

  def caveats; <<~EOS
    MT.m has been copied to
      #{HOMEBREW_PREFIX}/share/Mathematica/Applications/MT.m
    You can add it to your Mathematica $Path by adding a line
      AppendTo[$Path, "#{HOMEBREW_PREFIX}/share/Mathematica/Applications"]]
    to the file obtained by
      FileNameJoin[{$UserBaseDirectory, "Kernel", "init.m"}]
    Or run the following command in Mathematica:
      (Import["https://git.io/AppendPath.m"];AppendPath["#{HOMEBREW_PREFIX}/share/Mathematica/Applications"])

    Examples have been copied to
      #{HOMEBREW_PREFIX}/share/mma-mt/examples/

    Mathematica executable to build binary tables (--with-dump) can be specified
    by the environment variable $HOMEBREW_MATH.
    EOS
  end

  test do
  end
end
