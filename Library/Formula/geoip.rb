require 'formula'

class Geoip < Formula
  homepage 'https://github.com/maxmind/geoip-api-c'
  url 'https://github.com/maxmind/geoip-api-c/releases/download/v1.6.0/GeoIP-1.6.0.tar.gz'
  sha1 '41ed21fb2d40e54648cae2a1f73e8a5210676def'
  head 'https://github.com/maxmind/geoip-api-c.git'

  # These are needed for the autoreconf it always tries to run.
  depends_on :autoconf
  depends_on :automake
  depends_on :libtool

  option :universal

  def patches
    # Download test data so `make check` works. Fixed in HEAD.
    # See https://github.com/maxmind/geoip-api-c/commit/722707cc3a0adc06aec3e98bc36e7262f67ec0da
    DATA unless build.head?
  end

  def install
    ENV.universal_binary if build.universal?

    # Fixes a build error on Lion when configure does a variant of autoreconf
    # that results in a botched Makefile, causing this error:
    # No rule to make target '../libGeoIP/libGeoIP.la', needed by 'geoiplookup'
    # This works on Snow Leopard also when it tries but fails to run autoreconf.
    # Also fixes the tests by downloading required data file
    system "./bootstrap"

    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "check"
    system "make", "install"
  end

  test do
    system "curl", "-O", "http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz"
    system "gunzip", "GeoIP.dat.gz"
    system "#{bin}/geoiplookup", "-f", "GeoIP.dat", "8.8.8.8"
  end
end

__END__
diff --git a/bootstrap b/bootstrap
index 30fc0f9..f20f095 100755
--- a/bootstrap
+++ b/bootstrap
@@ -1,5 +1,14 @@
 #!/bin/sh
 
+# dl the dat file if needed
+DIR="$( cd "$( dirname "$0"  )" && pwd  )"
+
+# download geolite database for the tests
+mkdir -p $DIR/data
+if [ ! -f $DIR/data/GeoIP.dat  ]; then
+      curl http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz | gzip -d > $DIR/data/GeoIP.dat
+fi
+
 # make sure  to use the installed libtool
 rm -f ltmain.sh
 autoreconf -fiv
