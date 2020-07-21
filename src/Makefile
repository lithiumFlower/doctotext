CXXFLAGS = -O2 -I../3rdparty/wv2/include -I../3rdparty/unzip101e -I../3rdparty/htmlcxx/include
LDFLAGS = ../3rdparty/unzip101e/ioapi.o ../3rdparty/unzip101e/unzip.o

COMMON_OBJECTS = data_stream.o doc_parser.o entities.o exception.o list_style.o rtf_parser.o odf_ooxml_parser.o html_parser.o iwork_parser.o metadata.o misc.o xml_fixer.o doctotext_unzip.o \
	oshared.o pdf_parser.o plain_text_extractor.o ppt_parser.o xls_parser.o xlsb_parser.o thread_safe_ole_storage.o thread_safe_ole_stream_reader.o txt_parser.o \
	attachment.o eml_parser.o variant.o link.o odfxml_parser.o common_xml_document_parser.o xml_stream.o
OBJECTS = doctotext.o $(COMMON_OBJECTS)
LIB_OBJECTS = doctotext_c_api.o $(COMMON_OBJECTS)
ALL_OBJECTS = doctotext.o doctotext_c_api.o $(COMMON_OBJECTS)

HEADERS = ../version.h data_stream.h doc_parser.h exception.h html_parser.h iwork_parser.h metadata.h oshared.h rtf_parser.h odf_ooxml_parser.h misc.h \
	xml_fixer.h doctotext_unzip.h pdf_parser.h ppt_parser.h xls_parser.h xlsb_parser.h thread_safe_ole_storage.h thread_safe_ole_stream_reader.h txt_parser.h \
	attachment.h eml_parser.h variant.h doctotext_c_api.h odfxml_parser.h xml_stream.h common_xml_document_parser.h

CXXFLAGS += -D_GLIBCXX_USE_CXX11_ABI=0

ifneq (,$(filter $(ARCH),win32 win64))
	ifeq ($(ARCH),win32)
		STRIP = i686-w64-mingw32-strip
		CXX = i686-w64-mingw32-g++
		LIBDIR = lib
	else
		STRIP = strip
		CXX = x86_64-w64-mingw32-g++
		LIBDIR = lib64
	endif
    EXEEXT = .exe
    SOPRE =
    SOEXT = .dll
    CXXFLAGS += -I../3rdparty/libiconv/include -I../3rdparty/libcharsetdetect/include -I../3rdparty/zlib/include -I../3rdparty/libxml2/include/libxml2 -I../3rdparty/pthreads/include -I../3rdparty/mimetic/include
    LDFLAGS += ../3rdparty/unzip101e/iowin32.o \
        -L../3rdparty/wv2/$(LIBDIR) -lwv2 \
        -L../3rdparty/htmlcxx/$(LIBDIR) -lhtmlcxx \
        -L../3rdparty/libiconv/$(LIBDIR) -liconv \
        -L../3rdparty/libxml2/$(LIBDIR) -llibxml2 \
        -L../3rdparty/zlib/lib -lz \
        -L../3rdparty/libcharsetdetect/lib -lcharsetdetect \
        -L../3rdparty/pthreads/$(LIBDIR) -lpthreadGC2 \
        -L../3rdparty/mimetic/lib -lmimetic
    LDFLAGS += -Wl,--out-implib,libdoctotext.a,--allow-multiple-definition
    SHARED = -shared
else
    EXEEXT =
    CXXFLAGS += -I`xcrun --show-sdk-path`/usr/include/libxml2  -I../3rdparty/libcharsetdetect/include -I../3rdparty/mimetic/include
    SOPRE = lib
    UNAME = $(shell uname)
    ifeq ($(UNAME),Darwin)
        CXX = /usr/local/bin/g++-10
        STRIP = strip -x
        SOEXT = .dylib
        CXXFLAGS += -arch x86_64 -mmacosx-version-min=10.9
        LDFLAGS += -arch x86_64 -mmacosx-version-min=10.9
        SHARED = -dynamiclib
        LDFLAGS += ../3rdparty/mimetic/lib/libmimetic.a  \
                   ../3rdparty/wv2/lib/libwv2.a \
                   ../3rdparty/htmlcxx/lib/libhtmlcxx.a \
                   ../3rdparty/libcharsetdetect/lib/libcharsetdetect.a \
                   /usr/local/opt/libffi/lib/libffi.a \
                   /usr/local/opt/zlib/lib/libz.a \
                   /usr/local/opt/xz/lib/liblzma.a \
                   /usr/lib/libiconv.dylib \
                   /usr/lib/libxml2.dylib \
                   -framework CoreServices \
                   -static-libgcc -static-libstdc++
    else
        CXX = g++
        STRIP = strip
        SOEXT = .so
        SHARED = -shared
        LDFLAGS += -L../3rdparty/mimetic/lib -lmimetic -L../3rdparty/wv2/lib -lwv2 `pkg-config libxml-2.0 --libs` -lz
        ifeq ($(ARCH),x86-linux)
            CXXFLAGS += -m32
            LDFLAGS += -m32
        else
            UNAME_M = $(shell uname -m)
            ifeq ($(UNAME_M),x86_64)
                CXXFLAGS += -fPIC
            endif
        endif
    endif
endif

ifeq ($(DEBUG),1)
    CXXFLAGS += -g -O0 -finstrument-functions -DDEBUG
    COMMON_OBJECTS += tracing.o
    STRIP = touch
endif

all: doctotext$(EXEEXT) $(SOPRE)doctotext$(SOEXT)

doctotext$(EXEEXT): $(OBJECTS)
	$(CXX) -o doctotext$(EXEEXT) $(OBJECTS) $(LDFLAGS)
	$(STRIP) doctotext$(EXEEXT)

$(SOPRE)doctotext$(SOEXT): $(LIB_OBJECTS)
	$(CXX) $(SHARED) -o $(SOPRE)doctotext$(SOEXT) $(LIB_OBJECTS) $(LDFLAGS)
	$(STRIP) $(SOPRE)doctotext$(SOEXT)

$(ALL_OBJECTS): %.o: %.cpp $(HEADERS)
	$(CXX) -c $< $(CXXFLAGS) 

clean:
	rm -f *.o doctotext doctotext.exe libdoctotext.{so,dylib} doctotext.dll libdoctotext.a
