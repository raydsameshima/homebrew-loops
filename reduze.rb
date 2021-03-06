class Reduze < Formula
  desc "Distributed Feynman Integral Reduction"
  homepage "https://reduze.hepforge.org/"
  url "https://reduze.hepforge.org/download/reduze-2.2.tar.gz"
  sha256 "8e747591fed9402aec260b9b0fc33d62df65a532678ddf2614b6ff02abc3c9ba"

  option "with-yaml-cpp", "Build with brewed yaml-cpp"
  option "without-test", "Skip build-time tests"

  depends_on "cmake" => :build
  depends_on "ginac"
  depends_on "berkeley-db" => :optional
  depends_on "yaml-cpp" => :optional
  depends_on "open-mpi" => [:optional, "--with-cxx-bindings"]

  def install
    ENV.append "LDFLAGS", "-Wl,-rpath,#{Formula["berkeley-db"].opt_lib}" if build.with? "berkeley-db"

    args = std_cmake_args
    args << "-DUSE_DATABASE=ON" if build.with? "berkeley-db"
    args << "-DUSE_MPI=ON" if build.with? "open-mpi"
    system "cmake", *args
    system "make"
    system "make", "check" if build.with? "test"
    system "make", "check_mpi" if build.with?("test") && build.with?("open-mpi")
    system "make", "install"
  end

  test do
    system "#{bin}/reduze"
  end
end
