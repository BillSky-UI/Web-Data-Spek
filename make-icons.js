// Generate simple PNG icons for the PWA (no external deps)
const zlib = require('zlib');
const fs = require('fs');
const path = require('path');

function crc32(buf) {
  let c, table = [];
  for (let n = 0; n < 256; n++) {
    c = n;
    for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
    table[n] = c >>> 0;
  }
  let crc = 0xffffffff;
  for (let i = 0; i < buf.length; i++) crc = (crc >>> 8) ^ table[(crc ^ buf[i]) & 0xff];
  return (crc ^ 0xffffffff) >>> 0;
}

function chunk(type, data) {
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length, 0);
  const typeBuf = Buffer.from(type, 'ascii');
  const crcBuf = Buffer.alloc(4);
  crcBuf.writeUInt32BE(crc32(Buffer.concat([typeBuf, data])), 0);
  return Buffer.concat([len, typeBuf, data, crcBuf]);
}

function makePng(size, bg, fg) {
  const raw = Buffer.alloc(size * (size * 4 + 1));
  for (let y = 0; y < size; y++) {
    raw[y * (size * 4 + 1)] = 0; // filter none
    for (let x = 0; x < size; x++) {
      const o = y * (size * 4 + 1) + 1 + x * 4;
      // background
      let r = bg.r, g = bg.g, b = bg.b, a = 255;
      // draw monitor rectangle in lower-left area and a stand
      const margin = size * 0.18;
      const mw = size * 0.6;
      const mh = size * 0.42;
      const mx = margin;
      const my = margin;
      const inside = (x >= mx && x <= mx + mw && y >= my && y <= my + mh);
      // stand
      const stand = (x >= size * 0.4 && x <= size * 0.6 && y >= my + mh && y <= my + mh + size * 0.08);
      const base = (x >= size * 0.28 && x <= size * 0.72 && y >= my + mh + size * 0.08 && y <= my + mh + size * 0.16);
      if (inside) { r = fg.r; g = fg.g; b = fg.b; }
      if (stand || base) { r = fg.r; g = fg.g; b = fg.b; }
      raw[o] = r; raw[o + 1] = g; raw[o + 2] = b; raw[o + 3] = a;
    }
  }
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(size, 0);
  ihdr.writeUInt32BE(size, 4);
  ihdr[8] = 8;  // bit depth
  ihdr[9] = 6;  // color type RGBA
  ihdr[10] = 0; ihdr[11] = 0; ihdr[12] = 0;
  const idat = zlib.deflateSync(raw, { level: 9 });
  return Buffer.concat([
    Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
    chunk('IHDR', ihdr),
    chunk('IDAT', idat),
    chunk('IEND', Buffer.alloc(0))
  ]);
}

const bg = { r: 15, g: 23, b: 42 };   // #0f172a
const fg = { r: 34, g: 197, b: 94 };  // #22c55e green accent

const outDir = path.join(__dirname, 'public', 'icons');
fs.writeFileSync(path.join(outDir, 'icon-192.png'), makePng(192, bg, fg));
fs.writeFileSync(path.join(outDir, 'icon-512.png'), makePng(512, bg, fg));
console.log('Icons generated.');
