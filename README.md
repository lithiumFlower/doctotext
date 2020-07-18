### Why does this repo exist?
By no means, with the following list, do I mean to say anything bad about SILVERCODERS. They've made quite a useful utility. Unfortunately it was made quite a long time ago and just needs some modern love.

As of 07/14/2020 there were a number of issues with the distributed DocToText on SILVERCODERS website and Sourceforge:

1. It is open source but there is no version control available
2. The last release was 6 years ago
3. The source doesn't compile out of the box. Why? Presumably because of old machines using old compilers and builds being ran by hand such that they're non-repeatable.
    - The 3rd party Makefile does not download shasums
    - There are pointer to nonpointer comparisons
    - cxx11 abi compatibility issues
    - Duplicate exception symbols
    - Missing return statement causing segfault
    - 3rdparty/mimetic includes attempts to use member access through . on a pointer (will crash)
        - The shipped 3rdparty mimetic headers have been fixed and repackaged under version 0.9.7-fixed. The original ws 0.9.7.
    - pkg-config on Mac does not find libxml2 includes for modern OS versions
4. The binaries are non-relocatable. 
    - This is fine for using the distributed doctotext executable where we can easily set DYLIB_LIBRARY_PATH, LD_LIBRARY_PATH, etc, however when creating another program and linking against doctotext see the next point -
    - On Linux and Mac the distributed shared libraries will not be properly loaded unless placed in system locations. This prevents anyone who is creating a library that links the doctotext shared lib from distributing it as a standalone package. The shared libraries that doctotext.{dll,dylib,so} load will have to be placed in system locations. For building, for example, a python extension, it is already a challenge to link against and redistribute a chain of shared libs. It is much more work and not a maintainable solution for future releases to have to fix the the rpath entries on Mac and Linux first.
    - There is some manual usage of install_name_tool on mac to make the dylibs redistributable (at least with respect to the executable path), however the distributed binaries do not have the @executable_path/ rpath embedded as would be expected if these scripts had been run
5. There are memory leaks in the distributed OLE reader
6. The 3rdparty buildsystem relies on SILVERCODERS distribution servers remaining online and the packages places there to not change. 3rdparty/Makefile downlods a numbers of precompiles packages for each platform from SILVERCODERS hosting.
    - The current quick-and-dirty solution to this is to host all SILVERCODERS downloads in the repo here, adding about 30 MB to the repo size. These are the .bz2 and .bz2.sha1 files in 3rdparty.

### Building
#### Windows
Ensure the following are installed and in the path:
- doxygen
- mingw-64 with sljl exception handling
    - this must be in the path before any other mingw installations or things can break
- gnu make (can use from any mingw)

The most recent compilation was done in a git-bash shell using mingw64

#### Mac


#### Linux


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
