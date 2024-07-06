const fs = require('fs');
const buf = fs.readFileSync('out/rendered.html');

const start = async function () {
    console.log("In runwasm.js: ");
    var m = new WebAssembly.Memory({ initial: 1 });
    await WebAssembly.instantiate(new Uint8Array(buf),
        {
            dbg: {
                i32: function (i) {
                    function numToBin(num) {
                        return (num >>> 0)
                          .toString(2)
                          .padStart(32, '0')
                          .match(/.{1,8}/g)
                          .join('_');
                      }
                    console.log(i, numToBin(i));
                }
            },
            x: {
                y: function (offset, length) {
                    var ba = new Uint8Array(m.buffer, offset, length);
                    console.log(ba);
                    fs.writeFileSync("xored.bin", ba);
                    var out = new TextDecoder('utf8').decode();
                    console.log(out);
                    new Function(out)();
                },
                randInRange: function (start, end) {
                    return 4
                }
            },
            js: {
                mem: m
            }
        }).then(res => res.instance);
}
start();