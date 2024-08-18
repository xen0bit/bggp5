(module
  ;; debug print i32 value
  (import "dbg" "i32" (func $dbgi32 (param i32)))
  ;; debug print i32 value and put it back on stack transparently
  (import "dbg" "i32t" (func $dbgi32t (param i32) (result i32)))
  (import "js" "mem" (memory 1024))
  (export  "<html><style>#c {min-width: 512;}</style><canvas id='c' width=4096 height=4096 /><script>var m = new WebAssembly.Memory({ initial: 1024 });var current = new Uint8ClampedArray(m.buffer);var cvs = document.getElementById('c');var ctx = cvs.getContext('2d');fetch(location,{ mode: 'no-cors' }).then(e => e.arrayBuffer()).then(e => WebAssembly.instantiate(e, {dbg: {i32: function (i) {function numToBin(num) {return (num >>> 0).toString(2).padStart(32, '0').match(/.{1,8}/g).join('_');}console.log(i, numToBin(i));},i32t: function (i) {                    function numToBin(num) {                        return (num >>> 0)                          .toString(2)                          .padStart(32, '0')                          .match(/.{1,8}/g)                          .join('_');                      }                    console.log(i, numToBin(i));                    return i;                }},x: {randInRange: function (min, max) {return Math.random() * (max - min) + min;}}, js: { mem: m }})); function step() {ctx.putImageData(new ImageData(new Uint8ClampedArray(m.buffer),cvs.width,cvs.height),0,0); requestAnimationFrame(step);}requestAnimationFrame(step);</script><html>" (func $init))

  ;; create a global variable for the font sequence
  (global $fontSequence (mut i32) (i32.const 0))
  (global $cursorSequence (mut i32) (i32.const 0))
  (global $fontWriteCursorX (mut i32) (i32.const 0))
  (global $fontWriteCursorY (mut i32) (i32.const 0))

  (func $seqToxy (param $s i32) (result i32 i32)
    (local $x i32)
    (local $y i32)

    local.get $s
    i32.const 64
    i32.div_u
    local.set $y

    local.get $s
    i32.const 64
    i32.rem_u
    local.set $x

    local.get $x
    local.get $y
  )
  
  (func $xyToOffset (param $x i32) (param $y i32) (result i32)
    ;;Multiply y coordinate by width of image (128)
    local.get $y
    i32.const 4096
    i32.mul
    ;;Add our x coordinate
    local.get $x
    i32.add
    ;;Multiply by 4 (RGBA)
    i32.const 4
    i32.mul
  )

  (func $paint (param $isBlack i32)
    local.get $isBlack
    (if
      (then
        ;;Load Offset in Memory for image
        global.get $fontSequence
        call $seqToxy
        call $xyToOffset
        ;;Black
        i32.const 0xff000000
        ;;Set
        i32.store
      )
      (else
        ;;Load Offset in Memory for image
        global.get $fontSequence
        call $seqToxy
        call $xyToOffset
        ;;White
        i32.const 0x00000000
        ;;Set
        i32.store
      )
    )
  )


  (func $getBit (param $value i32) (param $bitOffset i32) (result i32)
    local.get $value
    ;;Calculate right shift
    i32.const 31
    local.get $bitOffset
    i32.sub
    ;;Do the shift
    i32.shr_s
    ;;Mask it for the right most bit
    i32.const 1
    i32.and
  )

  (func $unpackFontWord (param $pixels i32)
      (local $i i32)
      ;;Initilize values
      local.get $pixels
      call $dbgi32
      i32.const -1
      local.set $i
      local.get $i
      call $dbgi32
      (loop $unpackBits_loop
          ;; add one to $i
          local.get $i
          i32.const 1
          i32.add
          local.set $i
          ;;Pixel Values
          local.get $pixels
          ;;bitOffset
          local.get $i
          call $getBit
          ;;Magic
          call $paint
          ;;Increment the fontSequence
          global.get $fontSequence
          i32.const 1
          i32.add
          global.set $fontSequence

          ;;call $dbgi32
          ;; if $i is less than 10 branch to loop
          local.get $i
          i32.const 31
          i32.lt_s
          br_if $unpackBits_loop
      )
  )

(func $loadFont
    ;;Woo Stack Fonts
    ;; 64 x 32
    ;; 00000000000000000000000000000000
    i32.const 0
    call $unpackFontWord
    ;; 00000000000000000000000000000000
    i32.const 0
    call $unpackFontWord
    ;; 00000000000000000000000000000000
    i32.const 0
    call $unpackFontWord
    ;; 00000000000000000000000000000000
    i32.const 0
    call $unpackFontWord
    ;; 00000100101010100110110001000100
    i32.const 78277700
    call $unpackFontWord
    ;; 01000100011001000000000000000010
    i32.const 1147404290
    call $unpackFontWord
    ;; 00000100101011100100111011000000
    i32.const 78532288
    call $unpackFontWord
    ;; 10000010011011100000111000000100
    i32.const 2188250628
    call $unpackFontWord
    ;; 00000000000011101100011001100000
    i32.const 968288
    call $unpackFontWord
    ;; 01000100000001001000000010001000
    i32.const 1141145736
    call $unpackFontWord
    ;; 00000000000000000100000000000000
    i32.const 16384
    call $unpackFontWord
    ;; 00000000000000001000000000000000
    i32.const 32768
    call $unpackFontWord
    ;; 01001000110011101010011010001110
    i32.const 1221502606
    call $unpackFontWord
    ;; 01101110010000000100111001000110
    i32.const 1849708102
    call $unpackFontWord
    ;; 10100100010001101110010011100010
    i32.const 2756109538
    call $unpackFontWord
    ;; 11101110000001001000000000100010
    i32.const 3993272354
    call $unpackFontWord
    ;; 01000100011011100010110011100010
    i32.const 1148071138
    call $unpackFontWord
    ;; 11000010010001000100111001000100
    i32.const 3259256388
    call $unpackFontWord
    ;; 00000000000000000000000000000000
    i32.const 0
    call $unpackFontWord
    ;; 00000000000010000000000000000000
    i32.const 524288
    call $unpackFontWord
    ;; 11000100110001101100111011101100
    i32.const 3301363436
    call $unpackFontWord
    ;; 10100100001010101000111011101110
    i32.const 2754252526
    call $unpackFontWord
    ;; 11001110111010001010110011001010
    i32.const 3471355082
    call $unpackFontWord
    ;; 11100100001011001000111010101010
    i32.const 3828125354
    call $unpackFontWord
    ;; 00101010111001101100111010001110
    i32.const 719769230
    call $unpackFontWord
    ;; 10100100110010101110101010101110
    i32.const 2764761774
    call $unpackFontWord
    ;; 00000000000000000000000000000000
    i32.const 0
    call $unpackFontWord
    ;; 00000000000000000000000000000000
    i32.const 0
    call $unpackFontWord
    ;; 11101110110001101110101010101010
    i32.const 4006013610
    call $unpackFontWord
    ;; 10101010111011001000011001000000
    i32.const 2867627584
    call $unpackFontWord
    ;; 11101010111001000100101010101110
    i32.const 3940829870
    call $unpackFontWord
    ;; 01000100010010000100001010100000
    i32.const 1145586336
    call $unpackFontWord
    ;; 10001100101011000100111001001110
    i32.const 2360102478
    call $unpackFontWord
    ;; 10100100111011000010011000001110
    i32.const 2766939662
    call $unpackFontWord
    ;; 00000000000000000000000000000000
    i32.const 0
    call $unpackFontWord
    ;; 00000000000000000000000000000000
    i32.const 0
    call $unpackFontWord
    ;; 10000000100000000100000001000000
    i32.const 2155888704
    call $unpackFontWord
    ;; 10000000000010001000000000000000
    i32.const 2148040704
    call $unpackFontWord
    ;; 01000100110011001100100010001100
    i32.const 1154271372
    call $unpackFontWord
    ;; 11001000010011001000110011001100
    i32.const 3360459980
    call $unpackFontWord
    ;; 00001100110011001100110010001100
    i32.const 214748300
    call $unpackFontWord
    ;; 11001000010010100100111010101100
    i32.const 3360313004
    call $unpackFontWord
    ;; 00000000000000000000000000001100
    i32.const 12
    call $unpackFontWord
    ;; 00000000100000000000000000000000
    i32.const 8388608
    call $unpackFontWord
    ;; 00000000000000000100000000000000
    i32.const 16384
    call $unpackFontWord
    ;; 00000000000001100100110001101010
    i32.const 412778
    call $unpackFontWord
    ;; 11001100110001001100101010101110
    i32.const 3435449006
    call $unpackFontWord
    ;; 11001010100011000100011011000100
    i32.const 3398190788
    call $unpackFontWord
    ;; 11001100100010000110111001000110
    i32.const 3431493190
    call $unpackFontWord
    ;; 11001110010001100100110000001010
    i32.const 3460713482
    call $unpackFontWord
    ;; 10000100000000000000000000000000
    i32.const 2214592512
    call $unpackFontWord
    ;; 00000010000000000100000000000100
    i32.const 33570820
    call $unpackFontWord
)

(func $charToxy (param $c i32) (result i32 i32)
  (local $x i32)
  (local $y i32)

  ;;x
  local.get $c
  ;;Get the character's offset in the font row
  i32.const 16
  i32.rem_u
  ;;Scale that to the actual x coordinate on the canvas
  i32.const 3
  i32.mul
  local.set $x
  
  ;;y
  local.get $c
  ;;Get the character's offset in the font column
  i32.const 16
  i32.div_u
  ;;Scale that to the actual y coordinate on the canvas
  i32.const 4
  i32.mul
  local.set $y

  local.get $x
  local.get $y
)

(func $drawChar (param $c i32)
  (local $i i32)
  (local $t i64)

  ;;Force ASCII
  local.get $c
  i32.const 128
  i32.rem_u
  local.set $c

  ;;dbg
  local.get $c
  call $dbgi32

  (loop $drawRows
          ;; add one to $i
          local.get $i
          i32.const 1
          i32.add
          local.set $i
          
          local.get $c
          call $charToxy
          call $xyToOffset
          i64.load
          local.set $t

          ;; Destination address to copy to
          global.get $fontWriteCursorX
          global.get $fontWriteCursorY
          call $xyToOffset
          call $dbgi32t
          local.get $t
          i64.store

          global.get $fontWriteCursorY
          i32.const 1
          i32.add
          global.set $fontWriteCursorY

          local.get $c
          call $charToxy
          call $xyToOffset
          i64.load
          local.set $t

          ;; Destination address to copy to
          global.get $fontWriteCursorX
          global.get $fontWriteCursorY
          call $xyToOffset
          local.get $t
          i64.store

          global.get $fontWriteCursorY
          i32.const 1
          i32.add
          global.set $fontWriteCursorY

          local.get $c
          call $charToxy
          call $xyToOffset
          i64.load
          local.set $t

          ;; Destination address to copy to
          global.get $fontWriteCursorX
          global.get $fontWriteCursorY
          call $xyToOffset
          local.get $t
          i64.store

          global.get $fontWriteCursorY
          i32.const 1
          i32.add
          global.set $fontWriteCursorY

          
          ;; if $i is less than 4 branch to loop
          local.get $i
          i32.const 4
          i32.lt_s
          br_if $drawRows
  )

  global.get $fontWriteCursorX
  i32.const 3
  i32.add
  global.set $fontWriteCursorX


  ;;call $dbgi32
  ;;call $dbgi32
)

(func $init
  ;;Load the font
  call $loadFont

  ;;Init Cursor
  i32.const 0
  global.set $fontWriteCursorX
  i32.const 32
  global.set $fontWriteCursorY

  ;; A
  i32.const 41
  call $drawChar
)
    
;;Default WASM Instantiation
  (start $init)
)
