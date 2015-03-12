
# Determine where the install directory is located.
TARGET?=$(HOME)/local

# Determines the number of parallel jobs that will be used to build each of the submodules
JOBS?=8


all: install_node install_boost install_userspacercu install_hiredis install_snappy install_cityhash install_zeromq install_libssh2 install_libcurl install_curlpp install_protobuf install_gperftools install_zookeeper install_redis install_mongodb_cxx_driver instal
l_cairomm install_libgit

# dependencies used internally by Datacratic
dc_internal: all install_libhdfs3


.PHONY: install_node install_boost install_userspacercu install_hiredis install_snappy install_cityhash install_zeromq install_libssh2 install_libcurl install_curlpp install_protobuf install_gperftools install_zookeeper install_redis install_mongodb_cxx_driver install_jq install_libhdfs3

install_node:
	JOBS=$(JOBS) cd node && ./recoset_build_node.sh

install_boost:
	if [ ! -f boost-svn/b2 ] ; then cd boost-svn && ./bootstrap.sh --prefix=$(TARGET) ; fi
	cd boost-svn && ./b2 -j$(JOBS) variant=release link=shared threading=multi runtime-link=shared toolset=gcc --without=graph --without-graph_parallel --without-mpi install
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

install_libgit:
	cd libgit2 && mkdir -p build && cd build && cmake .. -DCMAKE_INSTALL_PREFIX=$(TARGET) && cmake --build . --target install

DISABLE_SSE42 ?= 0
ifneq ($(DISABLE_SSE42),0)
CITYHASH_CXXFLAGS := -mno-sse4.2
else
CITYHASH_CONFIGURE_FLAGS := --enable-sse4.2
endif

install_cityhash:
	cd cityhash && ./configure $(CITYHASH_CONFIGURE_FLAGS) --prefix $(TARGET) && make all check CXXFLAGS="-g -O3 $(CITYHASH_CXXFLAGS)" && make install

install_zeromq:
	cd zeromq3-x && ./autogen.sh && CXX="ccache g++" CC="ccache gcc" ./configure --prefix $(TARGET) && CXX="ccache g++" CC="ccache gcc" make -j$(JOBS) -k && make install

install_libssh2:
	cd libssh2 && ./buildconf && ./configure --prefix $(TARGET) && make -j$(JOBS) -k && make install

install_libcurl:
	cd curl && ./buildconf && ./configure --prefix $(TARGET) --with-libssh2=$(TARGET) && make -j$(JOBS) -k && make install

install_curlpp:
	cd curlpp && ./autogen.sh && CXX="ccache g++" CXXFLAGS="-I$(TARGET)/include" CFLAGS="-I$(TARGET)/include" CC="ccache gcc" ./configure --prefix $(TARGET) --with-curl=$(TARGET) --with-boost=$(TARGET)/ && CXX="ccache g++" CC="ccache gcc" make -j$(JOBS) -k && make install
	rm -f $(TARGET)/include/curlpp/config.win32.h
	cp curlpp/include/curlpp/config.h $(TARGET)/include/curlpp/config.h
	echo '#include "curlpp/config.h"' > $(TARGET)/include/curlpp/internal/global.h

install_gperftools:
	cd gperftools && ./configure --prefix $(TARGET) --enable-frame-pointers && make all CXXFLAGS="-g -O3" && make install

install_zookeeper:
	cd zookeeper && (ulimit -v unlimited; JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/ ant compile) && cd src/c && autoreconf -if && ./configure --prefix $(TARGET) && make -j$(JOBS) -k install && make doxygen-doc && rm -f ~/local/bin/zookeeper && cd ../.. && ln -s `pwd` ~/local/bin/zookeeper

install_redis:
	cd redis && make -j$(JOBS) -k PREFIX=$(TARGET) install

install_mongodb_cxx_driver:
	rm -rf $(TARGET)/include/mongo
	cd mongo-cxx-driver && scons -j$(JOBS) install --prefix $(TARGET)

install_jq:
	cd jq && make -k install prefix=$(TARGET)

install_cairomm:
	cd cairomm && ./autogen.sh && ./configure --prefix=$(TARGET) && make install

install_libhdfs3:
	mkdir -p libhdfs3/build; cd libhdfs3/build; ../bootstrap --prefix=$(TARGET) && make -j$(JOBS) -k PREFIX=$(TARGET) install

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
