#!/usr/bin/env tclsh
# 
# Script to update/generate the version.h header file for the C firmware files. 
# Author: Prince
# Date: Oct 13th, 2024


set VERSION_TAG [exec git describe --tags]

set	timestamp	[clock format [clock seconds]]


#set SOURCE_FILES_LOCATION ../..

# Open the file for writing (overwrite if it exists) assuming this is run from project dir


set fileId [open "c-code/version.h" "w"]


puts $fileId "// Automatically generated version file at $timestamp, DO NOT MODIFY!!!"
puts $fileId "#ifndef VERSION_H"
puts $fileId "#define VERSION_H"
puts $fileId "#define PROJECT_VERSION \"$VERSION_TAG\""
puts $fileId "#endif // VERSION_H"

close $fileId

puts "New version.h generated with tag $VERSION_TAG"
