require 'formula'

class PkgDownloadStrategy < CurlDownloadStrategy
  def stage
    # The compilers are distributed as a OS X 10.5 package- a single flat xar
    # archive instead of a bundle.
    safe_system '/usr/bin/xar', '-xf', @tarball_path
    chdir

    # Clean up.
    safe_system "mv *.pkg/Payload Payload.gz"
    safe_system "ls | grep -v Payload | xargs rm -r"
  end
end

class AppleGcc42 < Formula
  homepage 'http://r.research.att.com/tools/'
  url 'http://r.research.att.com/tools/gcc-42-5666.3-darwin11.pkg',
    :using => PkgDownloadStrategy
  mirror 'http://web.archive.org/web/20130512150329/http://r.research.att.com/tools/gcc-42-5666.3-darwin11.pkg'
  version '4.2.1-5666.3'
  sha1 '8fadde2a159082d6474fe9e325b6301e3c0bc84f'

  bottle do
    cellar :any
    revision 1
    sha1 '6b2f79ffd0a1ce4f66dc1728147cbf92238ad934' => :mavericks
    sha1 'a5ea9db71e33fb371ceb736ffb8006bf69e206f1' => :mountain_lion
    sha1 'df7d347f800bd9ac7779cefd8362f8fad29f9acf' => :lion
  end

  option 'with-gfortran-symlink', 'Provide gfortran symlinks'

  depends_on :macos => :lion

  def install
    safe_system "pax --insecure -rz -f Payload.gz -s ',./usr,#{prefix},'"

    if build.include? 'with-gfortran-symlink'
      safe_system "ln -sf #{bin}/gfortran-4.2 #{bin}/gfortran"
      safe_system "ln -sf #{man1}/gfortran-4.2.1 #{man1}/gfortran.1"
    end
  end

  def caveats
    <<-EOS.undent
      NOTE:
      This formula provides components that were removed from XCode in the 4.2
      release. There is no reason to install this formula if you are using a
      version of XCode prior to 4.2.

      This formula contains compilers built from Apple's GCC sources, build
      5666.3, available from:

        http://opensource.apple.com/tarballs/gcc

      All compilers have a `-4.2` suffix. A GFortran compiler is also included.
    EOS
  end
end
