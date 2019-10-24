## See also
## ========
## * `連超圧縮 (ランレングス法) - Wikipedia <https://ja.wikipedia.org/wiki/%E9%80%A3%E9%95%B7%E5%9C%A7%E7%B8%AE>`_

import unicode
from sequtils import repeat, concat
from strutils import join, parseInt

proc encode*(bs: openArray[byte]): seq[byte] =
  ## 文字列を圧縮して返す。
  ## 圧縮の際の「何文字連続しているか」のカウンタが255(1byte)まで。
  ## 255文字以上連続する場合は、一旦255で文字を区切り、
  ## カウンタを初期化してカウントし直す。
  var continuumLen = 1
  for i, b in bs:
    let i2 = i + 1
    if bs.len <= i2:
      while 255 < continuumLen:
        result.add(b)
        result.add(255'u8)
        dec(continuumLen, 255)
      result.add(b)
      result.add(byte(continuumLen))
      break 
    let nextByte = bs[i2]
    if b == nextByte:
      inc(continuumLen)
      continue

    while 255 < continuumLen:
      result.add(b)
      result.add(255'u8)
      dec(continuumLen, 255)
    result.add(b)
    result.add(byte(continuumLen))
    continuumLen = 1

proc decode*(bs: openArray[byte]): seq[byte] =
  ## 文字列を解凍して返す。
  ## 圧縮の際の「何文字連続しているか」のカウンタは255以下でなければならない。
  for i, v in bs:
    if i mod 2 == 0:
      let cnt = int(bs[i+1])
      result = result.concat(v.repeat(cnt))
