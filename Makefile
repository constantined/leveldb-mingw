# Copyright (c) 2011 The LevelDB Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file. See the AUTHORS file for names of contributors.

# Inherit some settings from environment variables, if available
INSTALL_PATH ?= $(CURDIR)

#-----------------------------------------------
# Uncomment exactly one of the lines labelled (A), (B), and (C) below
# to switch between compilation modes.

OPT ?= -O2 -DNDEBUG       # (A) Production use (optimized mode)
# OPT ?= -g2              # (B) Debug mode, w/ full line-level debugging symbols
# OPT ?= -O2 -g2 -DNDEBUG # (C) Profiling mode: opt, but w/debugging symbols
#-----------------------------------------------

# detect what platform we're building on
$(shell ./build_detect_platform build_config.mk)
# this file is generated by the previous line to set build flags and sources
include build_config.mk

CFLAGS += -I. -I./include $(PLATFORM_CCFLAGS) $(OPT)
CXXFLAGS += -I. -I./include $(PLATFORM_CXXFLAGS) $(OPT)

LDFLAGS += $(PLATFORM_LDFLAGS)

LIBOBJECTS = $(SOURCES:.cc=.o)
MEMENVOBJECTS = $(MEMENV_SOURCES:.cc=.o)

TESTUTIL = ./util/testutil.o
TESTHARNESS = ./util/testharness.o $(TESTUTIL)

TESTS = \
	arena_test \
	bloom_test \
	c_test \
	cache_test \
	coding_test \
	corruption_test \
	crc32c_test \
	db_test \
	dbformat_test \
	env_test \
	filename_test \
	filter_block_test \
	log_test \
	memenv_test \
	skiplist_test \
	table_test \
	version_edit_test \
	version_set_test \
	write_batch_test

PROGRAMS = db_bench $(TESTS)
BENCHMARKS = db_bench_sqlite3 db_bench_tree_db

LIBRARY = libleveldb.a
MEMENVLIBRARY = libmemenv.a

default: all

# Should we build shared libraries?
ifneq ($(PLATFORM_SHARED_EXT),)

ifneq ($(PLATFORM_SHARED_VERSIONED),true)
SHARED1 = libleveldb.$(PLATFORM_SHARED_EXT)
SHARED2 = $(SHARED1)
SHARED3 = $(SHARED1)
SHARED = $(SHARED1)
else
# Update db.h if you change these.
SHARED_MAJOR = 1
SHARED_MINOR = 5
SHARED1 = libleveldb.$(PLATFORM_SHARED_EXT)
SHARED2 = $(SHARED1).$(SHARED_MAJOR)
SHARED3 = $(SHARED1).$(SHARED_MAJOR).$(SHARED_MINOR)
SHARED = $(SHARED1) $(SHARED2) $(SHARED3)
$(SHARED1): $(SHARED3)
	ln -fs $(SHARED3) $(SHARED1)
$(SHARED2): $(SHARED3)
	ln -fs $(SHARED3) $(SHARED2)
endif

$(SHARED3):
	$(CXX) $(LDFLAGS) $(PLATFORM_SHARED_LDFLAGS)$(SHARED2) $(CXXFLAGS) $(PLATFORM_SHARED_CFLAGS) $(SOURCES) $(PLATFORM_EXTRALIBS) -o $(SHARED3)

endif  # PLATFORM_SHARED_EXT

all: $(SHARED) $(LIBRARY)

check: all $(PROGRAMS) $(TESTS)
	for t in $(TESTS); do echo "***** Running $$t"; ./$$t || exit 1; done

clean:
	-rm -f $(PROGRAMS) $(BENCHMARKS) $(LIBRARY) $(SHARED) $(MEMENVLIBRARY) */*.o */*/*.o ios-x86/*/*.o ios-arm/*/*.o build_config.mk
	-rm -rf ios-x86/* ios-arm/*

$(LIBRARY): $(LIBOBJECTS)
	rm -f $@
	$(AR) -rs $@ $(LIBOBJECTS)

db_bench: db/db_bench.o $(LIBOBJECTS) $(TESTUTIL)
	$(CXX) db/db_bench.o $(LIBOBJECTS) $(TESTUTIL) -o $@  $(LDFLAGS) $(PLATFORM_EXTRALIBS)

db_bench_sqlite3: doc/bench/db_bench_sqlite3.o $(LIBOBJECTS) $(TESTUTIL)
	$(CXX) doc/bench/db_bench_sqlite3.o $(LIBOBJECTS) $(TESTUTIL) -o $@ $(LDFLAGS) $(PLATFORM_EXTRALIBS) -lsqlite3

db_bench_tree_db: doc/bench/db_bench_tree_db.o $(LIBOBJECTS) $(TESTUTIL)
	$(CXX) doc/bench/db_bench_tree_db.o $(LIBOBJECTS) $(TESTUTIL) -o $@ $(LDFLAGS) $(PLATFORM_EXTRALIBS) -lkyotocabinet

arena_test: util/arena_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) util/arena_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@ $(LDFLAGS) $(PLATFORM_EXTRALIBS)

bloom_test: util/bloom_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) util/bloom_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@ $(LDFLAGS) $(PLATFORM_EXTRALIBS)

c_test: db/c_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) db/c_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@ $(LDFLAGS) $(PLATFORM_EXTRALIBS)

cache_test: util/cache_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) util/cache_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@ $(LDFLAGS) $(PLATFORM_EXTRALIBS)

coding_test: util/coding_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) util/coding_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@ $(LDFLAGS) $(PLATFORM_EXTRALIBS)

corruption_test: db/corruption_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) db/corruption_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@ $(LDFLAGS) $(PLATFORM_EXTRALIBS)

crc32c_test: util/crc32c_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) util/crc32c_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@ $(LDFLAGS) $(PLATFORM_EXTRALIBS)

db_test: db/db_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) db/db_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@ $(LDFLAGS) $(PLATFORM_EXTRALIBS)

dbformat_test: db/dbformat_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) db/dbformat_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@ $(LDFLAGS) $(PLATFORM_EXTRALIBS)

env_test: util/env_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) util/env_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@ $(LDFLAGS) $(PLATFORM_EXTRALIBS)

filename_test: db/filename_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) db/filename_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@ $(LDFLAGS) $(PLATFORM_EXTRALIBS)

filter_block_test: table/filter_block_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) table/filter_block_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@ $(LDFLAGS) $(PLATFORM_EXTRALIBS)

log_test: db/log_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) db/log_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@ $(LDFLAGS) $(PLATFORM_EXTRALIBS)

table_test: table/table_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) table/table_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@ $(LDFLAGS) $(PLATFORM_EXTRALIBS)

skiplist_test: db/skiplist_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) db/skiplist_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@ $(LDFLAGS) $(PLATFORM_EXTRALIBS)

version_edit_test: db/version_edit_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) db/version_edit_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@ $(LDFLAGS) $(PLATFORM_EXTRALIBS)

version_set_test: db/version_set_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) db/version_set_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@ $(LDFLAGS) $(PLATFORM_EXTRALIBS)

write_batch_test: db/write_batch_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) db/write_batch_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@ $(LDFLAGS) $(PLATFORM_EXTRALIBS)

$(MEMENVLIBRARY) : $(MEMENVOBJECTS)
	rm -f $@
	$(AR) -rs $@ $(MEMENVOBJECTS)

memenv_test : helpers/memenv/memenv_test.o $(MEMENVLIBRARY) $(LIBRARY) $(TESTHARNESS)
	$(CXX) helpers/memenv/memenv_test.o $(MEMENVLIBRARY) $(LIBRARY) $(TESTHARNESS) -o $@ $(LDFLAGS) $(PLATFORM_EXTRALIBS)

ifeq ($(PLATFORM), IOS)
# For iOS, create universal object files to be used on both the simulator and
# a device.
PLATFORMSROOT=/Applications/Xcode.app/Contents/Developer/Platforms
SIMULATORROOT=$(PLATFORMSROOT)/iPhoneSimulator.platform/Developer
DEVICEROOT=$(PLATFORMSROOT)/iPhoneOS.platform/Developer
IOSVERSION=$(shell defaults read $(PLATFORMSROOT)/iPhoneOS.platform/version CFBundleShortVersionString)

.cc.o:
	mkdir -p ios-x86/$(dir $@)
	$(SIMULATORROOT)/usr/bin/$(CXX) $(CXXFLAGS) -isysroot $(SIMULATORROOT)/SDKs/iPhoneSimulator$(IOSVERSION).sdk -arch i686 -c $< -o ios-x86/$@
	mkdir -p ios-arm/$(dir $@)
	$(DEVICEROOT)/usr/bin/$(CXX) $(CXXFLAGS) -isysroot $(DEVICEROOT)/SDKs/iPhoneOS$(IOSVERSION).sdk -arch armv6 -arch armv7 -c $< -o ios-arm/$@
	lipo ios-x86/$@ ios-arm/$@ -create -output $@

.c.o:
	mkdir -p ios-x86/$(dir $@)
	$(SIMULATORROOT)/usr/bin/$(CC) $(CFLAGS) -isysroot $(SIMULATORROOT)/SDKs/iPhoneSimulator$(IOSVERSION).sdk -arch i686 -c $< -o ios-x86/$@
	mkdir -p ios-arm/$(dir $@)
	$(DEVICEROOT)/usr/bin/$(CC) $(CFLAGS) -isysroot $(DEVICEROOT)/SDKs/iPhoneOS$(IOSVERSION).sdk -arch armv6 -arch armv7 -c $< -o ios-arm/$@
	lipo ios-x86/$@ ios-arm/$@ -create -output $@

else
.cc.o:
	$(CXX) $(CXXFLAGS) -c $< -o $@

.c.o:
	$(CC) $(CFLAGS) -c $< -o $@
endif
