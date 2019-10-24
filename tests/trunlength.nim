import unittest
import os
from sequtils import repeat

include runlength

suite "encode byte":
  test "normal":
    doAssert @[0'u8].encode == @[0'u8, 1]
    doAssert @[64'u8, 64, 64, 64, 63, 63].encode == @[64'u8, 4, 63, 2]
  test "character length is over 255":
    doAssert 0'u8.repeat(255).encode == @[0'u8, 255]
    doAssert 0'u8.repeat(256).encode == @[0'u8, 255, 0, 1]
    doAssert 0'u8.repeat(257).encode == @[0'u8, 255, 0, 2]
    doAssert 0'u8.repeat(511).encode == @[0'u8, 255, 0, 255, 0, 1]
    doAssert 0'u8.repeat(766).encode == @[0'u8, 255, 0, 255, 0, 255, 0, 1]

suite "decode byte":
  test "normal":
    doAssert @[0'u8] == @[0'u8, 1].decode
    doAssert @[64'u8, 64, 64, 64, 63, 63] == @[64'u8, 4, 63, 2].decode
  test "character length is over 255":
    doAssert 0'u8.repeat(255) == @[0'u8, 255].decode
    doAssert 0'u8.repeat(256) == @[0'u8, 255, 0, 1].decode
    doAssert 0'u8.repeat(257) == @[0'u8, 255, 0, 2].decode
    doAssert 0'u8.repeat(511) == @[0'u8, 255, 0, 255, 0, 1].decode
    doAssert 0'u8.repeat(766) == @[0'u8, 255, 0, 255, 0, 255, 0, 1].decode

const testFile = "tests/testdata.dat"
const data = @[0'u8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
             1, 1, 1, 2, 2, 3, 4]

suite "Encode and decode":
  setup:
    var f = open(testFile, fmWrite)
    discard f.writeBytes(data, 0, data.len)
    f.close()
  teardown:
    removeFile(testFile)

  test "Encode and decode":
    doAssert 0'u8.repeat(511).encode.decode == 0'u8.repeat(511)
  test "Read file":
    var inFile = open(testFile, fmRead)
    var b: array[data.len, byte]
    discard inFile.readBytes(b, 0, data.len)
    doAssert b.encode.len < b.len
    let encoded = b.encode()
    doAssert b == encoded.decode()
    inFile.close()
