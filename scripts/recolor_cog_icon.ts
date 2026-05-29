#!/usr/bin/env bun

import { deflateSync, inflateSync } from 'node:zlib';

type Rgba = readonly [number, number, number, number];
type Palette = {
  name: string;
  dark: string;
  mid: string;
  light: string;
};

const DEFAULT_INPUT = 'assets/sprites/cog/cog_icon.png';
const DEFAULT_OUT_DIR = 'assets/sprites/cog/generated';

const SOURCE_COLORS = {
  dark: '#322947',
  mid: '#725da2',
  light: '#ffffeb',
} as const;

const PALETTES: Palette[] = [
  { name: 'ammo', dark: '#4b5bab', mid: '#4da6ff', light: '#ffffeb' },
  { name: 'velocity', dark: '#3d6e70', mid: '#8fde5d', light: '#ffffeb' },
  { name: 'life', dark: '#8c3f5d', mid: '#eb564b', light: '#ffffeb' },
  { name: 'damage', dark: '#8c3f5d', mid: '#f2a65e', light: '#ffffeb' },
  { name: 'critic', dark: '#5a265e', mid: '#bd4882', light: '#ffffeb' },
];

const PNG_SIGNATURE = new Uint8Array([137, 80, 78, 71, 13, 10, 26, 10]);
const CRC_TABLE = makeCrcTable();
const textEncoder = new TextEncoder();
const textDecoder = new TextDecoder();

const args = parseArgs(Bun.argv.slice(2));

if (args.help) {
  printHelp();
  process.exit(0);
}

const input = args.input ?? DEFAULT_INPUT;
const outDir = args.outDir ?? DEFAULT_OUT_DIR;
const selectedPalettes = args.palette
  ? PALETTES.filter((palette) => palette.name === args.palette)
  : PALETTES;

if (selectedPalettes.length === 0) {
  throw new Error(
    `Unknown palette "${args.palette}". Available palettes: ${PALETTES.map((p) => p.name).join(', ')}`,
  );
}

await Bun.$`mkdir -p ${outDir}`;

const sourceBytes = await readPngBytes(input);
const source = decodePng(sourceBytes);

for (const palette of selectedPalettes) {
  const recolored = recolor(source, makeColorMap(palette));
  const outPath = `${outDir}/cog_icon_${palette.name}.png`;
  await Bun.write(outPath, encodePng(recolored));
  console.log(`wrote ${outPath}`);
}

async function readPngBytes(path: string): Promise<Uint8Array> {
  const file = Bun.file(path);
  const image = imagePipeline(file);

  if (image) {
    const pngBytes = await image.png().bytes();
    return pngBytes instanceof Uint8Array ? pngBytes : new Uint8Array(pngBytes);
  }

  return new Uint8Array(await file.arrayBuffer());
}

function imagePipeline(
  file: BunFile,
): null | { png: () => { bytes: () => Promise<Uint8Array | ArrayBuffer> } } {
  const blobImage = (file as BunFile & { image?: () => unknown }).image;
  if (typeof blobImage === 'function') {
    return blobImage.call(file) as {
      png: () => { bytes: () => Promise<Uint8Array | ArrayBuffer> };
    };
  }

  const bunImage = (
    Bun as typeof Bun & { Image?: new (input: BunFile) => unknown }
  ).Image;
  if (typeof bunImage === 'function') {
    return new bunImage(file) as {
      png: () => { bytes: () => Promise<Uint8Array | ArrayBuffer> };
    };
  }

  return null;
}

function recolor(source: DecodedPng, colorMap: Map<string, Rgba>): DecodedPng {
  const data = new Uint8Array(source.data);

  for (let i = 0; i < data.length; i += 4) {
    const alpha = data[i + 3];
    if (alpha === 0) continue;

    const replacement = colorMap.get(rgbKey(data[i], data[i + 1], data[i + 2]));
    if (!replacement) continue;

    data[i] = replacement[0];
    data[i + 1] = replacement[1];
    data[i + 2] = replacement[2];
    data[i + 3] = Math.round((replacement[3] / 255) * alpha);
  }

  return { ...source, data };
}

function makeColorMap(palette: Palette): Map<string, Rgba> {
  return new Map([
    [rgbKeyFromHex(SOURCE_COLORS.dark), hexToRgba(palette.dark)],
    [rgbKeyFromHex(SOURCE_COLORS.mid), hexToRgba(palette.mid)],
    [rgbKeyFromHex(SOURCE_COLORS.light), hexToRgba(palette.light)],
  ]);
}

type DecodedPng = {
  width: number;
  height: number;
  data: Uint8Array;
};

function decodePng(bytes: Uint8Array): DecodedPng {
  assertPngSignature(bytes);

  let offset = PNG_SIGNATURE.length;
  let width = 0;
  let height = 0;
  let bitDepth = 0;
  let colorType = 0;
  const idatChunks: Uint8Array[] = [];

  while (offset < bytes.length) {
    const length = readU32(bytes, offset);
    const type = textDecoder.decode(bytes.subarray(offset + 4, offset + 8));
    const data = bytes.subarray(offset + 8, offset + 8 + length);
    offset += 12 + length;

    if (type === 'IHDR') {
      width = readU32(data, 0);
      height = readU32(data, 4);
      bitDepth = data[8];
      colorType = data[9];
      const interlace = data[12];

      if (bitDepth !== 8)
        throw new Error(
          `Only 8-bit PNGs are supported, got bit depth ${bitDepth}`,
        );
      if (colorType !== 6 && colorType !== 2)
        throw new Error(
          `Only RGBA/RGB PNGs are supported, got color type ${colorType}`,
        );
      if (interlace !== 0) throw new Error('Interlaced PNGs are not supported');
    } else if (type === 'IDAT') {
      idatChunks.push(data);
    } else if (type === 'IEND') {
      break;
    }
  }

  if (width <= 0 || height <= 0) throw new Error('Invalid PNG: missing IHDR');

  const channels = colorType === 6 ? 4 : 3;
  const inflated = inflateSync(
    Buffer.concat(idatChunks.map((chunk) => Buffer.from(chunk))),
  );
  const stride = width * channels;
  const raw = unfilterScanlines(inflated, width, height, channels);
  const rgba = new Uint8Array(width * height * 4);

  for (let src = 0, dst = 0; src < raw.length; src += channels, dst += 4) {
    rgba[dst] = raw[src];
    rgba[dst + 1] = raw[src + 1];
    rgba[dst + 2] = raw[src + 2];
    rgba[dst + 3] = channels === 4 ? raw[src + 3] : 255;
  }

  if (raw.length !== stride * height)
    throw new Error('Invalid PNG: decoded size does not match dimensions');

  return { width, height, data: rgba };
}

function encodePng(png: DecodedPng): Uint8Array {
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

function unfilterScanlines(
  inflated: Uint8Array,
  width: number,
  height: number,
  channels: number,
): Uint8Array {
  const stride = width * channels;
  const output = new Uint8Array(stride * height);
  let srcOffset = 0;

  for (let y = 0; y < height; y++) {
    const filter = inflated[srcOffset++];
    const rowStart = y * stride;
    const prevRowStart = rowStart - stride;

    for (let x = 0; x < stride; x++) {
      const raw = inflated[srcOffset++];
      const left = x >= channels ? output[rowStart + x - channels] : 0;
      const up = y > 0 ? output[prevRowStart + x] : 0;
      const upLeft =
        y > 0 && x >= channels ? output[prevRowStart + x - channels] : 0;

      output[rowStart + x] =
        (raw + filterValue(filter, left, up, upLeft)) & 0xff;
    }
  }

  return output;
}

function filterValue(
  filter: number,
  left: number,
  up: number,
  upLeft: number,
): number {
  switch (filter) {
    case 0:
      return 0;
    case 1:
      return left;
    case 2:
      return up;
    case 3:
      return Math.floor((left + up) / 2);
    case 4:
      return paeth(left, up, upLeft);
    default:
      throw new Error(`Unsupported PNG filter ${filter}`);
  }
}

function paeth(left: number, up: number, upLeft: number): number {
  const estimate = left + up - upLeft;
  const leftDistance = Math.abs(estimate - left);
  const upDistance = Math.abs(estimate - up);
  const upLeftDistance = Math.abs(estimate - upLeft);

  if (leftDistance <= upDistance && leftDistance <= upLeftDistance) return left;
  if (upDistance <= upLeftDistance) return up;
  return upLeft;
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

function assertPngSignature(bytes: Uint8Array): void {
  for (let i = 0; i < PNG_SIGNATURE.length; i++) {
    if (bytes[i] !== PNG_SIGNATURE[i])
      throw new Error('Input is not a PNG file');
  }
}

function readU32(bytes: Uint8Array, offset: number): number {
  return new DataView(bytes.buffer, bytes.byteOffset + offset, 4).getUint32(0);
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
    throw new Error(`Invalid color "${hex}"`);
  }

  return [
    Number.parseInt(normalized.slice(0, 2), 16),
    Number.parseInt(normalized.slice(2, 4), 16),
    Number.parseInt(normalized.slice(4, 6), 16),
    normalized.length === 8 ? Number.parseInt(normalized.slice(6, 8), 16) : 255,
  ];
}

function rgbKeyFromHex(hex: string): string {
  const [r, g, b] = hexToRgba(hex);
  return rgbKey(r, g, b);
}

function rgbKey(r: number, g: number, b: number): string {
  return `${r},${g},${b}`;
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

function parseArgs(rawArgs: string[]): {
  help: boolean;
  input?: string;
  outDir?: string;
  palette?: string;
} {
  const parsed: {
    help: boolean;
    input?: string;
    outDir?: string;
    palette?: string;
  } = { help: false };

  for (let i = 0; i < rawArgs.length; i++) {
    const arg = rawArgs[i];
    const next = rawArgs[i + 1];

    if (arg === '--help' || arg === '-h') parsed.help = true;
    else if (arg === '--input' && next) parsed.input = rawArgs[++i];
    else if (arg === '--out-dir' && next) parsed.outDir = rawArgs[++i];
    else if (arg === '--palette' && next) parsed.palette = rawArgs[++i];
    else throw new Error(`Unknown or incomplete argument "${arg}"`);
  }

  return parsed;
}

function printHelp(): void {
  console.log(`Usage: bun scripts/recolor_cog_icon.ts [options]

Options:
  --input <path>       Source PNG. Default: ${DEFAULT_INPUT}
  --out-dir <path>     Output directory. Default: ${DEFAULT_OUT_DIR}
  --palette <name>     Only write one palette: ${PALETTES.map((p) => p.name).join(', ')}
  -h, --help           Show this help
`);
}
