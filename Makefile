ifneq (,$(filter $(ARCH),win32 win64))
	ifeq ($(ARCH),win32)
		STRIP = i686-w64-mingw32-strip
	else
		STRIP = strip
	endif
	EXEEXT=.exe
	SOPRE =
	SOEXT = .dll
	WIN = 1
else
ifeq ($(ARCH),x86-linux)
	STRIP = strip
	EXEEXT =
	SOEXT = .so
	SOPRE = lib
	WIN = 0
else
	UNAME = $(shell uname)
	ifeq ($(UNAME),Darwin)
	    STD_LIB = libstdc++.6.dylib
	    GCC_LIB = libgcc_s.1.dylib
		STD_LIB_PATH = /usr/local/opt/gcc/lib/gcc/10/$(STD_LIB)
		GCC_LIB_PATH = /usr/local/lib/gcc/10/$(GCC_LIB)
		STRIP = strip -x
		ARCH = i386-x86_64-macosx
		SOEXT = .dylib
	else
		STRIP = strip
		UNAME_M = $(shell uname -m)
		ifeq ($(UNAME_M),x86_64)
			ARCH = x86_64-linux
		else
			ARCH = x86-linux
		endif
		SOEXT = .so
	endif
	EXEEXT=
	SOPRE = lib
	WIN = 0
endif
endif

ifeq ($(DEBUG),1)
override ARCH := $(ARCH)-debug
STRIP = touch
endif

build: version.h src doc/html
	$(MAKE) -C 3rdparty htmlcxx
	$(MAKE) -C 3rdparty wv2
	$(MAKE) -C 3rdparty unzip
	#$(MAKE) -C 3rdparty aj16
	#$(MAKE) -C 3rdparty ak12
	#$(MAKE) -C 3rdparty ag15
	#$(MAKE) -C 3rdparty ac16
	#$(MAKE) -C 3rdparty ToUnicode
	$(MAKE) -C 3rdparty libcharsetdetect
	$(MAKE) -C 3rdparty mimetic
ifeq ($(WIN),1)
	$(MAKE) -C 3rdparty pthreads
	$(MAKE) -C 3rdparty libxml2
endif
	$(MAKE) -C src
	rm -rf build
	mkdir build
	cp src/doctotext$(EXEEXT) build
	cp src/$(SOPRE)doctotext$(SOEXT) build/
ifeq ($(WIN),1)
	cp 3rdparty/libiconv/bin/libiconv-2.dll build
	cp 3rdparty/pthreads/bin/pthreadGC2.dll build
	cp 3rdparty/libxml2/bin/libxml2-2.dll build
	cp 3rdparty/zlib/bin/zlib1.dll build
	cp 3rdparty/wv2/bin/libwv2-1.dll build
	IFS=: && for f in $$PATH; do \
		if test -f "$$f/libgcc_s_sjlj-1.dll"; then \
			cp "$$f/libgcc_s_sjlj-1.dll" build/; \
			break; \
		fi \
	done
	IFS=: && for f in $$PATH; do \
		if test -f "$$f/libstdc++-6.dll"; then \
			cp "$$f/libstdc++-6.dll" build/; \
			break; \
		fi \
	done
	cp src/libdoctotext.a build
	$(STRIP) build/*.dll
else
ifeq ($(UNAME),Darwin)
	$(STRIP) build/*.dylib
	cp $(STD_LIB_PATH) build/
	cp $(GCC_LIB_PATH) build/
	chmod +xwr build/*.dylib
	install_name_tool \
		-change $(STD_LIB_PATH) @rpath/$(STD_LIB) \
		-change $(GCC_LIB_PATH) @rpath/$(GCC_LIB) \
		build/libdoctotext.dylib
	install_name_tool \
	    -change $(GCC_LIB_PATH) @rpath/$(GCC_LIB) \
	    build/$(STD_LIB)
	install_name_tool -id @rpath/$(STD_LIB) build/$(STD_LIB)
	install_name_tool -id @rpath/$(GCC_LIB) build/$(GCC_LIB)
	install_name_tool -id @rpath/libdoctotext.dylib build/libdoctotext.dylib
	echo './doctotext "$$@"' > build/doctotext.sh
else
	cp 3rdparty/libcharsetdetect/lib/libcharsetdetect.so build
	cp 3rdparty/wv2/lib/libwv2.so.1 build
	cp 3rdparty/mimetic/lib/libmimetic.so.0 build
	$(STRIP) build/*.so*
	echo 'LD_LIBRARY_PATH=.:$$LD_LIBRARY_PATH ./doctotext "$$@"' > build/doctotext.sh
endif
	chmod u+x build/doctotext.sh
endif
	cp $(foreach f,plain_text_extractor formatting_style metadata doctotext_c_api link exception attachment variant,src/${f}.h) build/
	mkdir build/doc
	mkdir build/resources
#	cp ./3rdparty/ac16/CMap/*  build/resources
#	cp ./3rdparty/ag15/CMap/*  build/resources
#	cp ./3rdparty/aj16/CMap/*  build/resources
#	cp ./3rdparty/ak12/CMap/*  build/resources
#	cp ./3rdparty/ToUnicode/*  build/resources
	cp ./3rdparty/pdf_font_metrics.txt build/resources
	cp -r doc/html doc/index.html build/doc
	cp ChangeLog VERSION build
	$(MAKE) -C tests

version.h: VERSION
	echo "#define VERSION \"`cat VERSION`\"" > version.h

.PHONY: 

doc/html: doc/Doxyfile src
	cd doc && \
	rm -rf html && \
	cat Doxyfile | sed s/VERSION/`cat ../VERSION`/ | doxygen -

clean:
	rm -rf build
	rm -f version.h
	rm -rf doc/html
	$(MAKE) -C 3rdparty clean
	$(MAKE) -C src clean
	$(MAKE) -C tests clean

snapshot: clean
	snapshot_fn=$$TMPDIR/doctotext-`date +%Y%m%d`.tar.bz2 && \
	tar -cjvf $$snapshot_fn ../doctotext --exclude .svn --exclude "*.kdev*" --exclude ".DS_Store" --exclude "*.tar.*" --exclude "*.zip" --exclude "VERSION" && \
	mv $$snapshot_fn .

release: clean 
	release_fn=$$TMPDIR/doctotext-`cat VERSION | cut -f1,2 -d.`-`date +%Y%m%d`.tar.bz2 && \
	tar -cjvf $$release_fn ../doctotext --exclude .svn --exclude "*.kdev*" --exclude ".DS_Store" --exclude "*.tar.*" --exclude "*.zip" --exclude "generate*.sh" --exclude "VERSION" && \
	mv $$release_fn .

snapshot-bin: build
	mv build doctotext
	tar -cjvf doctotext-`date +%Y%m%d`-$(ARCH).tar.bz2 doctotext
	mv doctotext build

release-bin: build
	mv build doctotext
	tar -cjvf doctotext-`cat VERSION`-$(ARCH).tar.bz2 doctotext
	mv doctotext build

unzip101e/.unpacked: unzip101e.zip
	tar -xjvf unzip101e.zip
	touch unzip101e.zip/.unpacked

unzip101e.zip:
	wget http://www.winimage.com/zLibDll/unzip101e.zip

	rm -rf unzip101e
