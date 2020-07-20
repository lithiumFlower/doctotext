### Why does this repo exist?
SILVERCODERS has worked hard to make a wonderful utility. Unfortunately it was made quite a long time ago and just needs some modern love.

As of 07/14/2020 there were a number of issues with the distributed DocToText on SILVERCODERS website and Sourceforge:

1. It is open source but there is no version control available
2. The last release was 6 years ago
3. The source doesn't compile out of the box.
4. Various crashes, memory leaks
5. The binaries are non-relocatable. 
    - This is fine for using the distributed doctotext executable where we can easily set DYLIB_LIBRARY_PATH, LD_LIBRARY_PATH, etc, however when creating another program and linking against doctotext see the next point -
    - On Linux and Mac the distributed shared libraries will not be properly loaded unless placed in system locations. This prevents anyone who is creating a library that links the doctotext shared lib from distributing it as a standalone package. The shared libraries that doctotext.{dll,dylib,so} load will have to be placed in system locations. For building, for example, a python extension, it is already a challenge to link against and redistribute a chain of shared libs. It is much more work and not a maintainable solution for future releases to have to fix the the rpath entries on Mac and Linux first.
    - There is some manual usage of install_name_tool on mac to make the dylibs redistributable (at least with respect to the executable path), however the distributed binaries do not have the @executable_path/ rpath embedded as would be expected if these scripts had been run

This repo aims to fix the above issues.

### Creating relocatable libraries
Tthe binaries and main program can be made redistributable by simply keeping all distributed shared libraries in the same directory with it.  
On windows we search the loading executable/dll directory first by standard. On Mac and Linux we set both the identity of the main library `libdoctotext` and all supported libraries to `@rpath/<libname>`. Further, all referenced libraries (except system libs) are `@rpath/<libname>` as well. On mac we can simply set the rpath of a host program to `@loader_path` and as long as everything stays in the same directory, all libs will automatically load. Linux will use an rpath of `$ORIGIN`.

### Building
The result of a `make -j` will create a build folder analagous to the tagged releases:
1. The build executable and associated script depending on platform at
2. A shared library to link against should you wish to compile against it
3. The required headers (toplevel in build)
4. build/resrouces - resources for parsing pdfs, currently incomplete
5. the library documentation at build/doc
6. all needed dll, dylib, that the main libdoctotext and or executable needs to be shipped as a standalone library or application
7. VERSION file and ChangeLog

#### Windows
Ensure the following are installed and in the path:
- doxygen
- mingw-64 with sjlj exception handling
    - this must be in the path before any other mingw installations or things can break
- gnu make (can use from any mingw)

Tested in a git-bash shell using mingw64 on windows 10 64bit

`ARCH=win64 make -j`

Note that due to the mingw compilation, if you with to use MSVC toolchain you must use the c api. See the auto-generated `doc` folder for more info.

#### Mac
Install the following through homebrew:
- doxygen, libffi, libxml2, zlib, xz, gcc
libffi, libxml2, zlib, and xz will be statically linked through their /usr/local/opt/ -> /usr/local/Cellar/ symlinks

The Makefile will use the full path to GNU g++ 10 (installed through `brew install gcc` at `/usr/local/bin/g++-10`). If you have different version edit the makefile and change the `src/Makefile` `CXX` setting for Darwin.  
  

Note that the system gcc and g++ *will not work*. The system gcc and g++ compile against Mac's `libc++` which is Mac's implementation of a c++11 compatible standard library. Unfortunately because we are linking with precompiled libs distributed by SILVERCODERS which were compiled pre c++11 with GNU g++ we must use GNU g++ for its ability to be abi compatible with pre c++11 libraries linked against the gnu `libstdc++`. Mac removed their GNU compatibility and distributed headers as of Xcode 10.

Tested on Catalina

`make -j`

#### Linux
TODO


### What is DocToText
From the DocToText website http://silvercoders.com/en/products/doctotext/:

SILVERCODERS DocToText is a powerful utility that can convert documents in many formats to plain text. The package, available to users for free on open source GPL license, includes console application and C/C++ library, that allows embedding text extraction mechanism into other application.

The utility supports MS Office binary formats: MS Word (DOC), MS Excel (XLS, XLSB), MS PowerPoint (PPT), Rich Text Format (RTF), OpenDocument (also known as ODF and ISO/IEC 26300, full name: OASIS Open Document Format for Office Applications): text documents (ODT), spreadsheets (ODS), presentations (ODP), graphics (ODG), Office Open XML (ISO/IEC 29500, also called OOXML, OpenXML or MSOOXML) documents: MS Word (DOCX), MS Excel (XLSX), MS PowerPoint (PPTX), iWork formats (PAGES, NUMBERS, KEYNOTE), OpenDocument Flat XML formats (FODP, FODS, FODT), Portable Document Format (PDF), Email files (EML) and HyperText Markup Language (HTML).

Extracting plain text from doc, xls, ppt, rtf, odt, ods, odp, odg, docx, xlsx, pptx, pages, numbers, keynote, fodp, fods, fodt, pdf, eml and html files can be used for a lot of things like searching, indexing or archiving. DocToText can be also used as a fast console viewer.

DocToText can extract text not only from document body but also from annotations (comments) embedded in odt, doc, docx or rtf files and read metadata like author, last modification date or number of pages.

Complex documents? Other utilities gave up? MS Excel spreadsheet embedded in MS Word document? Charset detection required? OpenDocument formats OLE? No problem.

DocToText is able to convert corrupted OpenDocument and Office Open XML documents. It can be used to recover text even if other recovery methods failed. If you need help with this kind of issues see our document recovery services.

We also offer the possibility to use the library in commercial applications, with full technical support. The utility is constantly used and tested on thousands of documents by customers all around the world. If interested, please contact us for details.

### DocToText original README
/****************************************************************************  
**  
** DocToText - Converts DOC, XLS, XLSB, PPT, RTF, ODF (ODT, ODS, ODP),  
**             OOXML (DOCX, XLSX, PPTX), iWork (PAGES, NUMBERS, KEYNOTE),  
**             ODFXML (FODP, FODS, FODT), PDF, EML and HTML documents to plain text.  
**             Extracts metadata and annotations.   
**  
** Copyright (c) 2006-2013, SILVERCODERS(R)  
** http://silvercoders.com  
**  
** Project homepage: http://silvercoders.com/en/products/doctotext  
**  
** This program may be distributed and/or modified under the terms of the  
** GNU General Public License version 2 as published by the Free Software  
** Foundation and appearing in the file COPYING.GPL included in the  
** packaging of this file.  
**  
** Please remember that any attempt to workaround the GNU General Public  
** License using wrappers, pipes, client/server protocols, and so on  
** is considered as license violation. If your program, published on license  
** other than GNU General Public License version 2, calls some part of this  
** code directly or indirectly, you have to buy commercial license.  
** If you do not like our point of view, simply do not use the product.  
**  
** Licensees holding valid commercial license for this product  
** may use this file in accordance with the license published by  
** SILVERCODERS and appearing in the file COPYING.COM  
**  
** This program is distributed in the hope that it will be useful,  
** but WITHOUT ANY WARRANTY; without even the implied warranty of  
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
**  
*****************************************************************************/  
