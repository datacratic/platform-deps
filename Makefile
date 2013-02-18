TARGET?=$(HOME)/local

.PHONY: install_node install_boost clean_boost install_userspacercu install_hiredis install_snappy install_cityhash

install_node:
	cd node && ./recoset_build_node.sh

install_boost:
	if [ ! -f boost-svn/b2 ] ; then cd boost-svn && ./bootstrap.sh --prefix=$(TARGET) ; fi
	cd boost-svn && ./b2 -j8 variant=release link=shared threading=multi runtime-link=shared toolset=gcc --without=graph --without-graph_parallel --without-mpi install
clean_boost:
	cd boost-svn && rm -rf ./b2 ./bin.v2 ./bjam ./bootstrap.log ./project-config.jam ./tools/build/v2/engine/bootstrap/ ./tools/build/v2/engine/bin.linuxx86_64/


install_userspacercu:
	cd userspace-rcu/ && ./bootstrap && ./configure --prefix=$(TARGET) && make install

install_hiredis:
	cd hiredis && PREFIX=$(TARGET) LIBRARY_PATH=lib make install

install_snappy:
	cd snappy && ./autogen.sh && ./configure --prefix $(TARGET) && make install

install_protobuf:
	cd protobuf && ./autogen.sh && ./configure --prefix $(TARGET) && make install

install_cityhash:
	cd cityhash && ./configure --enable-sse4.2 --prefix $(TARGET) && make all check CXXFLAGS="-g -O3 -msse4.2" && make install

install_zeromq:
	cd zeromq3-x && ./autogen.sh && CXX="ccache g++" CC="ccache gcc" ./configure --prefix $(TARGET) && CXX="ccache g++" CC="ccache gcc" make -j8 -k && make install

install_libssh2:
	cd libssh2 && ./buildconf && ./configure --prefix $(TARGET) && make -j8 -k && make install

install_libcurl:
	cd curl && ./buildconf && ./configure --prefix $(TARGET) --with-libssh2=$(TARGET) && make -j8 -k && make install

install_curlpp:
	cd curlpp && ./autogen.sh && CXX="ccache g++" CXXFLAGS="-I$(TARGET)/include" CFLAGS="-I$(TARGET)/include" CC="ccache gcc" ./configure --prefix $(TARGET) --with-curl=$(TARGET) --with-boost=$(TARGET)/ && CXX="ccache g++" CC="ccache gcc" make -j8 -k && make install
	rm -f $(TARGET)/include/curlpp/config.win32.h
	cp curlpp/include/curlpp/config.h $(TARGET)/include/curlpp/config.h
	echo '#include "curlpp/config.h"' > $(TARGET)/include/curlpp/internal/global.h

install_thrift:
	cd thrift && ./bootstrap.sh && CXX="ccache g++" CC="ccache gcc" ./configure --prefix $(TARGET) --without-ruby --without-python --without-erlang --without-php --with-boost=$(TARGET)/ && (CXX="ccache g++" CC="ccache gcc" make -j8 -k install;  CXX="ccache g++" CC="ccache gcc" make -j8 -k install)

install_gperftools:
	cd gperftools && ./configure --prefix $(TARGET) --enable-frame-pointers && make all CXXFLAGS="-g -O3" && make install

install_zookeeper:
	cd zookeeper-3.4.5 && (ulimit -v unlimited; JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/ ant compile_jute) && cd src/c && autoreconf -if && ./configure --prefix $(TARGET) && make -j8 -k install && make doxygen-doc

install_redis:
	cd redis && make -j8 -k PREFIX=$(TARGET) install

install_mongodb_cxx_driver:
	rm -rf $(TARGET)/include/mongo
	cd mongo-cxx-driver && scons -j8 install --prefix $(TARGET)

install_jq:
	cd jq && make -k install prefix=$(TARGET)

all: install_node install_boost install_userspacercu install_hiredis install_snappy install_cityhash install_zeromq install_libssh2 install_libcurl install_curlpp install_thrift install_protobuf install_gperftools install_zookeeper install_redis install_mongodb_cxx_driver install_jq



# Helps troubleshooting deployments via scripts.
.PHONY: test-deploy
test-deploy:
	@echo "=== test-deploy ==="
	@whoami
	@echo "HOME=$(HOME)"
	@echo "TARGET=$(TARGET)"
	@echo
	@env | sort
	@echo "=== test-deploy ==="
