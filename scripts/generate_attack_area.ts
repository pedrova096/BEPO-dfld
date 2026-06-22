#!/usr/bin/env bun

import { deflateSync } from 'node:zlib';

type Rgba = readonly [number, number, number, number];
type Shape = 'box' | 'circle';

type Args = {
  help: boolean;
  force: boolean;
  name: string;
  shape: Shape;
  width: number;
  height: number;
  padding: number;
  outlineWidth: number;
  outlineColor: string;
  fillColor: string;
  outDir: string;
  atlas: string;
};

type Png = {
  width: number;
  height: number;
  data: Uint8Array;
};

const DEFAULT_OUT_DIR = 'assets/sprites/enemies/attacks';
const DEFAULT_ATLAS = `${DEFAULT_OUT_DIR}/enemies_attacks.atlas`;
const PNG_SIGNATURE = new Uint8Array([137, 80, 78, 71, 13, 10, 26, 10]);
const CRC_TABLE = makeCrcTable();
const textEncoder = new TextEncoder();

const args = parseArgs(Bun.argv.slice(2));

if (args.help) {
  printHelp();
  process.exit(0);
}

await Bun.$`mkdir -p ${args.outDir}`;

const filename = `${args.name}.png`;
const outPath = `${args.outDir.replace(/\/$/, '')}/${filename}`;
const atlasImagePath = toDefoldPath(outPath);

if (!args.force && (await Bun.file(outPath).exists())) {
  throw new Error(`"${outPath}" already exists. Use --force to replace it.`);
}

const png = drawAttackArea({
  shape: args.shape,
  width: args.width,
  height: args.height,
  padding: args.padding,
  outlineWidth: args.outlineWidth,
  outlineColor: hexToRgba(args.outlineColor),
  fillColor: hexToRgba(args.fillColor),
});

await Bun.write(outPath, encodePng(png));
await attachImageToAtlas(args.atlas, atlasImagePath);

console.log(`wrote ${outPath}`);
console.log(`attached ${atlasImagePath} to ${args.atlas}`);

function drawAttackArea(options: {
  shape: Shape;
  width: number;
  height: number;
  padding: number;
  outlineWidth: number;
  outlineColor: Rgba;
  fillColor: Rgba;
}): Png {
  const data = new Uint8Array(options.width * options.height * 4);
  const { fillMask, outlineMask } =
    options.shape === 'circle'
      ? makeEllipseAreaMasks(
          options.width,
          options.height,
          options.padding,
          options.outlineWidth,
        )
      : makeBoxAreaMasks(
          options.width,
          options.height,
          options.padding,
          options.outlineWidth,
        );

  for (let y = 0; y < options.height; y++) {
    for (let x = 0; x < options.width; x++) {
      const index = y * options.width + x;

      if (outlineMask[index]) {
        writePixel(data, index * 4, options.outlineColor);
      } else if (fillMask[index]) {
        writePixel(data, index * 4, options.fillColor);
      }
    }
  }

  return { width: options.width, height: options.height, data };
}

function makeBoxAreaMasks(
  width: number,
  height: number,
  padding: number,
  outlineWidth: number,
): { fillMask: Uint8Array; outlineMask: Uint8Array } {
  const outerMask = makeBoxMask(width, height, padding);
  const fillMask = makeBoxMask(width, height, padding + outlineWidth);
  const outlineMask = new Uint8Array(width * height);

  for (let i = 0; i < outlineMask.length; i++) {
    outlineMask[i] = outerMask[i] && !fillMask[i] ? 1 : 0;
  }

  return { fillMask, outlineMask };
}

function makeBoxMask(
  width: number,
  height: number,
  padding: number,
): Uint8Array {
  const mask = new Uint8Array(width * height);
  const minX = padding;
  const minY = padding;
  const maxX = width - padding - 1;
  const maxY = height - padding - 1;

  if (minX > maxX || minY > maxY) return mask;

  for (let y = Math.ceil(minY); y <= Math.floor(maxY); y++) {
    for (let x = Math.ceil(minX); x <= Math.floor(maxX); x++) {
      mask[y * width + x] = 1;
    }
  }

  return mask;
}

function makeEllipseAreaMasks(
  width: number,
  height: number,
  padding: number,
  outlineWidth: number,
): { fillMask: Uint8Array; outlineMask: Uint8Array } {
  const outlineMask = new Uint8Array(width * height);
  const fillMask = new Uint8Array(width * height);
  const strokeCount = Math.max(1, Math.ceil(outlineWidth));
  const minX = Math.ceil(padding);
  const minY = Math.ceil(padding);
  const maxX = Math.floor(width - padding - 1);
  const maxY = Math.floor(height - padding - 1);

  if (minX > maxX || minY > maxY) return { fillMask, outlineMask };

  asepriteEllipseFill(minX, minY, maxX, maxY, (x1, y, x2) => {
    if (y < 0 || y >= height) return;

    for (let x = Math.max(0, x1); x <= Math.min(width - 1, x2); x++) {
      fillMask[y * width + x] = 1;
    }
  });

  for (let i = 0; i < strokeCount; i++) {
    asepriteEllipse(minX + i, minY + i, maxX - i, maxY - i, (x, y) => {
      if (x >= 0 && x < width && y >= 0 && y < height) {
        outlineMask[y * width + x] = 1;
      }
    });
  }

  for (let index = 0; index < fillMask.length; index++) {
    if (outlineMask[index]) fillMask[index] = 0;
  }

  return { fillMask, outlineMask };
}

function asepriteEllipse(
  x0: number,
  y0: number,
  x1: number,
  y1: number,
  plot: (x: number, y: number) => void,
): void {
  const args = adjustEllipseArgs(x0, y0, x1, y1, 0, 0);
  x0 = args.x0;
  y0 = args.y0;
  x1 = args.x1;
  y1 = args.y1;
  const hPixels = args.hPixels;
  const vPixels = args.vPixels;
  const h = args.height;

  let a = Math.abs(x1 - x0);
  let b = Math.abs(y1 - y0);
  let b1 = b & 1;
  let dx = 4 * (1.0 - a) * b * b;
  let dy = 4 * (b1 + 1) * a * a;
  let err = dx + dy + b1 * a * a;

  y0 += Math.floor((b + 1) / 2);
  y1 = y0 - b1;
  a = 8 * a * a;
  b1 = 8 * b * b;

  const initialY0 = y0;
  const initialY1 = y1;
  const initialX0 = x0;
  const initialX1 = x1 + hPixels;

  do {
    plot(x1 + hPixels, y0 + vPixels);
    plot(x0, y0 + vPixels);
    plot(x0, y1);
    plot(x1 + hPixels, y1);

    const e2 = 2 * err;
    if (e2 <= dy) {
      y0++;
      y1--;
      err += dy += a;
    }
    if (e2 >= dx || 2 * err > dy) {
      x0++;
      x1--;
      err += dx += b1;
    }
  } while (x0 <= x1);

  while (y0 + vPixels - y1 + 1 <= h) {
    plot(x0 - 1, y0 + vPixels);
    plot(x1 + 1 + hPixels, y0++ + vPixels);
    plot(x0 - 1, y1);
    plot(x1 + 1 + hPixels, y1--);
  }

  if (hPixels > 0) {
    for (let i = x0; i < x1 + hPixels + 1; i++) {
      plot(i, y1 + 1);
      plot(i, y0 + vPixels - 1);
    }
  }

  if (vPixels > 0) {
    for (let i = initialY1 + 1; i < initialY0 + vPixels; i++) {
      plot(initialX0, i);
      plot(initialX1, i);
    }
  }
}

function asepriteEllipseFill(
  x0: number,
  y0: number,
  x1: number,
  y1: number,
  hline: (x1: number, y: number, x2: number) => void,
): void {
  const args = adjustEllipseArgs(x0, y0, x1, y1, 0, 0);
  x0 = args.x0;
  y0 = args.y0;
  x1 = args.x1;
  y1 = args.y1;
  const hPixels = args.hPixels;
  const vPixels = args.vPixels;
  const h = args.height;

  let a = Math.abs(x1 - x0);
  let b = Math.abs(y1 - y0);
  let b1 = b & 1;
  let dx = 4 * (1.0 - a) * b * b;
  let dy = 4 * (b1 + 1) * a * a;
  let err = dx + dy + b1 * a * a;

  y0 += Math.floor((b + 1) / 2);
  y1 = y0 - b1;
  a = 8 * a * a;
  b1 = 8 * b * b;

  const initialY0 = y0;
  const initialY1 = y1;
  const initialX0 = x0;
  const initialX1 = x1 + hPixels;

  do {
    hline(x0, y0 + vPixels, x1 + hPixels);
    hline(x0, y1, x1 + hPixels);

    const e2 = 2 * err;
    if (e2 <= dy) {
      y0++;
      y1--;
      err += dy += a;
    }
    if (e2 >= dx || 2 * err > dy) {
      x0++;
      x1--;
      err += dx += b1;
    }
  } while (x0 <= x1);

  while (y0 + vPixels - y1 + 1 <= h) {
    hline(x0 - 1, y0 + vPixels, x0 - 1);
    hline(x1 + 1 + hPixels, y0++ + vPixels, x1 + 1 + hPixels);
    hline(x0 - 1, y1, x0 - 1);
    hline(x1 + 1 + hPixels, y1--, x1 + 1 + hPixels);
  }

  if (vPixels > 0) {
    for (let i = initialY1 + 1; i < initialY0 + vPixels; i++) {
      hline(initialX0, i, initialX1);
    }
  }
}

function adjustEllipseArgs(
  x0: number,
  y0: number,
  x1: number,
  y1: number,
  hPixels: number,
  vPixels: number,
): {
  x0: number;
  y0: number;
  x1: number;
  y1: number;
  hPixels: number;
  vPixels: number;
  height: number;
} {
  hPixels = Math.max(hPixels, 0);
  vPixels = Math.max(vPixels, 0);

  if (x0 > x1) [x0, x1] = [x1, x0];
  if (y0 > y1) [y0, y1] = [y1, y0];

  const w = x1 - x0 + 1;
  const h = y1 - y0 + 1;
  const hDiameter = w - hPixels;
  const vDiameter = h - vPixels;

  if (w === 8 || w === 12 || w === 22) hPixels++;
  if (h === 8 || h === 12 || h === 22) vPixels++;

  hPixels = hDiameter > 5 ? hPixels : 0;
  vPixels = vDiameter > 5 ? vPixels : 0;

  if (hDiameter % 2 === 0 && hDiameter > 5) hPixels--;
  if (vDiameter % 2 === 0 && vDiameter > 5) vPixels--;

  x1 -= hPixels;
  y1 -= vPixels;

  return { x0, y0, x1, y1, hPixels, vPixels, height: h };
}

function writePixel(data: Uint8Array, offset: number, color: Rgba): void {
  data[offset] = color[0];
  data[offset + 1] = color[1];
  data[offset + 2] = color[2];
  data[offset + 3] = color[3];
}

async function attachImageToAtlas(
  atlasPath: string,
  imagePath: string,
): Promise<void> {
  const atlasFile = Bun.file(atlasPath);
  let atlas = (await atlasFile.exists()) ? await atlasFile.text() : '';

  if (atlas.includes(`image: "${imagePath}"`)) return;

  const imageBlock = `images {\n  image: "${imagePath}"\n}\n`;
  const animationsIndex = atlas.search(/^animations \{/m);

  if (animationsIndex >= 0) {
    const before = atlas.slice(0, animationsIndex).trimEnd();
    const after = atlas.slice(animationsIndex).trimStart();
    atlas = `${before}\n${imageBlock}${after}`;
  } else {
    atlas = atlas.trimEnd();
    atlas = atlas.length > 0 ? `${atlas}\n${imageBlock}` : imageBlock;
  }

  await Bun.write(atlasPath, atlas.endsWith('\n') ? atlas : `${atlas}\n`);
}

function encodePng(png: Png): Uint8Array {
  const stride = png.width * 4;
  const scanlines = new Uint8Array((stride + 1) * png.height);

  for (let y = 0; y < png.height; y++) {
    const srcStart = y * stride;
    const dstStart = y * (stride + 1);
    scanlines[dstStart] = 0;
    scanlines.set(png.data.subarray(srcStart, srcStart + stride), dstStart + 1);
  }

  const ihdr = new Uint8Array(13);
  writeU32(ihdr, 0, png.width);
  writeU32(ihdr, 4, png.height);
  ihdr[8] = 8;
  ihdr[9] = 6;
  ihdr[10] = 0;
  ihdr[11] = 0;
  ihdr[12] = 0;

  return concatBytes([
    PNG_SIGNATURE,
    makeChunk('IHDR', ihdr),
    makeChunk('IDAT', deflateSync(scanlines)),
    makeChunk('IEND', new Uint8Array()),
  ]);
}

function makeChunk(type: string, data: Uint8Array): Uint8Array {
  const typeBytes = textEncoder.encode(type);
  const chunk = new Uint8Array(12 + data.length);
  writeU32(chunk, 0, data.length);
  chunk.set(typeBytes, 4);
  chunk.set(data, 8);
  writeU32(chunk, 8 + data.length, crc32(concatBytes([typeBytes, data])));
  return chunk;
}

function writeU32(bytes: Uint8Array, offset: number, value: number): void {
  new DataView(bytes.buffer, bytes.byteOffset + offset, 4).setUint32(0, value);
}

function concatBytes(chunks: Array<Uint8Array | Buffer>): Uint8Array {
  const length = chunks.reduce((sum, chunk) => sum + chunk.length, 0);
  const result = new Uint8Array(length);
  let offset = 0;

  for (const chunk of chunks) {
    result.set(chunk, offset);
    offset += chunk.length;
  }

  return result;
}

function hexToRgba(hex: string): Rgba {
  const normalized = hex.replace('#', '');

  if (!/^[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$/.test(normalized)) {
    throw new Error(`Invalid color "${hex}". Use #rrggbb or #rrggbbaa.`);
  }

  return [
    Number.parseInt(normalized.slice(0, 2), 16),
    Number.parseInt(normalized.slice(2, 4), 16),
    Number.parseInt(normalized.slice(4, 6), 16),
    normalized.length === 8 ? Number.parseInt(normalized.slice(6, 8), 16) : 255,
  ];
}

function crc32(bytes: Uint8Array): number {
  let crc = 0xffffffff;

  for (const byte of bytes) {
    crc = CRC_TABLE[(crc ^ byte) & 0xff] ^ (crc >>> 8);
  }

  return (crc ^ 0xffffffff) >>> 0;
}

function makeCrcTable(): Uint32Array {
  const table = new Uint32Array(256);

  for (let i = 0; i < 256; i++) {
    let crc = i;
    for (let bit = 0; bit < 8; bit++) {
      crc = crc & 1 ? 0xedb88320 ^ (crc >>> 1) : crc >>> 1;
    }
    table[i] = crc >>> 0;
  }

  return table;
}

function parseArgs(rawArgs: string[]): Args {
  const parsed: Args = {
    help: false,
    force: false,
    name: 'attack_area_custom',
    shape: 'circle',
    width: 24,
    height: 24,
    padding: 1,
    outlineWidth: 1,
    outlineColor: '#ffffeb',
    fillColor: '#eb564b66',
    outDir: DEFAULT_OUT_DIR,
    atlas: DEFAULT_ATLAS,
  };

  for (let i = 0; i < rawArgs.length; i++) {
    const arg = rawArgs[i];
    const [key, inlineValue] = arg.split('=', 2);

    if (arg === '--help' || arg === '-h') parsed.help = true;
    else if (arg === '--force') parsed.force = true;
    else if (key === '--name')
      parsed.name = parseName(readValue(rawArgs, i, inlineValue, key));
    else if (key === '--shape')
      parsed.shape = parseShape(readValue(rawArgs, i, inlineValue, key));
    else if (key === '--size') {
      const [width, height] = parseSize(
        readValue(rawArgs, i, inlineValue, key),
      );
      parsed.width = width;
      parsed.height = height;
    } else if (key === '--width')
      parsed.width = parsePositiveInt(
        readValue(rawArgs, i, inlineValue, key),
        'width',
      );
    else if (key === '--height')
      parsed.height = parsePositiveInt(
        readValue(rawArgs, i, inlineValue, key),
        'height',
      );
    else if (key === '--padding')
      parsed.padding = parseNonNegativeNumber(
        readValue(rawArgs, i, inlineValue, key),
        'padding',
      );
    else if (key === '--outline-width') {
      parsed.outlineWidth = parseNonNegativeNumber(
        readValue(rawArgs, i, inlineValue, key),
        'outline width',
      );
    } else if (key === '--outline-color' || key === '--outline') {
      parsed.outlineColor = readValue(rawArgs, i, inlineValue, key);
    } else if (key === '--fill-color' || key === '--fill') {
      parsed.fillColor = readValue(rawArgs, i, inlineValue, key);
    } else if (key === '--out-dir')
      parsed.outDir = readValue(rawArgs, i, inlineValue, key);
    else if (key === '--atlas')
      parsed.atlas = readValue(rawArgs, i, inlineValue, key);
    else throw new Error(`Unknown or incomplete argument "${arg}"`);

    if (inlineValue === undefined && usesValue(key)) {
      i++;
    }
  }

  if (
    parsed.padding * 2 >= parsed.width ||
    parsed.padding * 2 >= parsed.height
  ) {
    throw new Error('Padding must leave drawable space inside the image.');
  }

  return parsed;
}

function usesValue(key: string): boolean {
  return key !== '--help' && key !== '-h' && key !== '--force';
}

function readValue(
  rawArgs: string[],
  index: number,
  inlineValue: string | undefined,
  label: string,
): string {
  const value = inlineValue ?? rawArgs[index + 1];

  if (!value || value.startsWith('--')) {
    throw new Error(`Missing value for ${label}`);
  }

  return value;
}

function parseName(name: string): string {
  if (!/^[a-zA-Z0-9_-]+$/.test(name)) {
    throw new Error(
      'Name can only contain letters, numbers, underscores, and dashes.',
    );
  }

  return name.replace(/\.png$/, '');
}

function parseShape(shape: string): Shape {
  if (shape === 'box' || shape === 'circle') return shape;
  throw new Error(`Unknown shape "${shape}". Use circle or box.`);
}

function parseSize(size: string): [number, number] {
  const match = size.match(/^(\d+)(?:x(\d+))?$/i);
  if (!match) throw new Error(`Invalid size "${size}". Use 24 or 48x32.`);

  const width = parsePositiveInt(match[1], 'width');
  const height = parsePositiveInt(match[2] ?? match[1], 'height');
  return [width, height];
}

function parsePositiveInt(value: string, label: string): number {
  const parsed = Number(value);
  if (!Number.isInteger(parsed) || parsed <= 0) {
    throw new Error(`Invalid ${label} "${value}". Use a positive integer.`);
  }

  return parsed;
}

function parseNonNegativeNumber(value: string, label: string): number {
  const parsed = Number(value);
  if (!Number.isFinite(parsed) || parsed < 0) {
    throw new Error(`Invalid ${label} "${value}". Use a non-negative number.`);
  }

  return parsed;
}

function toDefoldPath(path: string): string {
  const normalized = path.replace(/^\.\//, '');
  return normalized.startsWith('/') ? normalized : `/${normalized}`;
}

function printHelp(): void {
  console.log(`Usage: bun scripts/generate_attack_area.ts [options]

Options:
  --name <id>              Output PNG name without extension. Default: attack_area_custom
  --shape <circle|box>     Area shape. Default: circle
  --size <n|wxh>           Image size. Examples: 24, 48x32. Default: 24
  --width <px>             Image width. Overrides --size width.
  --height <px>            Image height. Overrides --size height.
  --padding <px>           Transparent padding around the shape. Default: 1
  --outline-width <px>     Outline thickness inside the shape. Default: 1
  --outline-color <hex>    Outline color, #rrggbb or #rrggbbaa. Default: #ffffeb
  --outline <hex>          Alias for --outline-color
  --fill-color <hex>       Fill color, #rrggbb or #rrggbbaa. Default: #eb564b66
  --fill <hex>             Alias for --fill-color
  --out-dir <path>         Output folder. Default: ${DEFAULT_OUT_DIR}
  --atlas <path>           Atlas to update. Default: ${DEFAULT_ATLAS}
  --force                  Replace an existing PNG
  -h, --help               Show this help

Examples:
  bun scripts/generate_attack_area.ts --name attack_area_02 --shape circle --size 32 --padding 1 --outline '#eb564b' --fill '#ff916666'
  bun scripts/generate_attack_area.ts --name attack_area_wide --shape box --size 48x24 --padding 2 --outline-width 2 --outline '#322947' --fill '#4da6ff55'
`);
}
