#!/usr/bin/env bun

import { readdirSync } from 'node:fs';

const TILE_SIZE = 48;
const STAGES_DIR = 'main/game/stages';

type TileBounds = {
  minX: number;
  maxX: number;
  minY: number;
  maxY: number;
};

type TilemapStage = {
  id: string;
  dir: string;
  largeTilemapPath: string;
  smallTilemapPath: string;
  topSmallTilemapPath: string;
  collectionPath: string;
};

type TileCell = {
  x: number;
  y: number;
  tile: number;
};

const args = parseArgs(Bun.argv.slice(2));

if (args.help) {
  printHelp();
  process.exit(0);
}

const stages = getTilemapStages();
if (stages.length === 0) {
  throw new Error(`No tilemap_XX directories found in ${STAGES_DIR}`);
}

const selectedStage = args.tilemap
  ? findStage(stages, args.tilemap)
  : await pickStage(stages);

const bounds = await getTileBounds(selectedStage.largeTilemapPath);
const [x, y] = centeredPosition(bounds);
const changed = await updateRootPosition(selectedStage.collectionPath, x, y);
const action = changed ? 'updated' : 'already centered';
const topCellsCount = await updateTopSmallTiles(selectedStage);

console.log(
  `${action} ${selectedStage.collectionPath} root position to x=${formatNumber(x)} y=${formatNumber(y)}`,
);
console.log(
  `wrote ${topCellsCount} top cells to ${selectedStage.topSmallTilemapPath}`,
);

function parseArgs(argv: string[]): { help: boolean; tilemap?: string } {
  const parsed: { help: boolean; tilemap?: string } = { help: false };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];

    if (arg === '-h' || arg === '--help') {
      parsed.help = true;
    } else if (arg === '--tilemap') {
      parsed.tilemap = argv[index + 1];
      index += 1;
    } else if (arg.startsWith('--tilemap=')) {
      parsed.tilemap = arg.slice('--tilemap='.length);
    } else if (!parsed.tilemap) {
      parsed.tilemap = arg;
    } else {
      throw new Error(`Unknown argument "${arg}"`);
    }
  }

  return parsed;
}

function printHelp(): void {
  console.log(`Usage:
  bun scripts/center_tilemap_composer.ts
  bun scripts/center_tilemap_composer.ts tilemap_01
  bun scripts/center_tilemap_composer.ts --tilemap tilemap_01`);
}

function getTilemapStages(): TilemapStage[] {
  return readdirSync(STAGES_DIR, { withFileTypes: true })
    .filter((entry) => entry.isDirectory() && /^tilemap_\d+$/.test(entry.name))
    .map((entry) => {
      const dir = `${STAGES_DIR}/${entry.name}`;

      return {
        id: entry.name,
        dir,
        largeTilemapPath: `${dir}/tiles_lg.tilemap`,
        smallTilemapPath: `${dir}/tiles_sm.tilemap`,
        topSmallTilemapPath: `${dir}/top_tiles_sm.tilemap`,
        collectionPath: `${dir}/${entry.name}_composer.collection`,
      };
    })
    .sort((a, b) => a.id.localeCompare(b.id));
}

function findStage(stages: TilemapStage[], id: string): TilemapStage {
  const stage = stages.find((item) => item.id === id);
  if (stage) return stage;

  throw new Error(
    `Unknown tilemap "${id}". Available tilemaps: ${stages.map((item) => item.id).join(', ')}`,
  );
}

async function pickStage(stages: TilemapStage[]): Promise<TilemapStage> {
  console.log('Tilemaps:');
  stages.forEach((stage, index) => {
    console.log(`  ${index + 1}. ${stage.id}`);
  });

  while (true) {
    const answer = prompt('Pick a tilemap number or id:')?.trim();

    if (!answer) {
      console.log('Please pick one of the listed tilemaps.');
      continue;
    }

    const selectedIndex = Number(answer);
    if (
      Number.isInteger(selectedIndex) &&
      selectedIndex >= 1 &&
      selectedIndex <= stages.length
    ) {
      return stages[selectedIndex - 1];
    }

    const selectedStage = stages.find((stage) => stage.id === answer);
    if (selectedStage) return selectedStage;

    console.log(`Unknown tilemap "${answer}".`);
  }
}

async function getTileBounds(tilemapPath: string): Promise<TileBounds> {
  const content = await Bun.file(tilemapPath).text();
  let minX: number | undefined;
  let maxX: number | undefined;
  let minY: number | undefined;
  let maxY: number | undefined;

  for (const line of content.split(/\r?\n/)) {
    const x = line.match(/^\s*x:\s*(-?\d+)/);
    if (x) {
      const value = Number(x[1]);
      minX = minX === undefined ? value : Math.min(minX, value);
      maxX = maxX === undefined ? value : Math.max(maxX, value);
    }

    const y = line.match(/^\s*y:\s*(-?\d+)/);
    if (y) {
      const value = Number(y[1]);
      minY = minY === undefined ? value : Math.min(minY, value);
      maxY = maxY === undefined ? value : Math.max(maxY, value);
    }
  }

  if (
    minX === undefined ||
    maxX === undefined ||
    minY === undefined ||
    maxY === undefined
  ) {
    throw new Error(`No tile cells found in ${tilemapPath}`);
  }

  return { minX, maxX, minY, maxY };
}

async function updateTopSmallTiles(stage: TilemapStage): Promise<number> {
  const sourceContent = await Bun.file(stage.smallTilemapPath).text();
  const sourceLayer = findLayerBlock(sourceContent, 'layer');
  const sourceCells = parseCells(sourceLayer.block);
  const sourceKeys = new Set(sourceCells.map(cellKey));
  const topCells = sourceCells
    .filter(
      (cell) =>
        (cell.tile === 0 || cell.tile === 2) &&
        !sourceKeys.has(cellKey({ ...cell, y: cell.y + 1 })),
    )
    .map((cell) => ({
      x: cell.x,
      y: cell.y + 1,
      tile: 1,
    }))
    .sort((a, b) => a.y - b.y || a.x - b.x);

  const topContent = await readTilemapOrDefault(stage.topSmallTilemapPath);
  const topLayer = findLayerBlock(topContent, 'layer');
  const updatedLayer = formatLayerBlock('layer', topCells);
  const updated =
    topContent.slice(0, topLayer.start) +
    updatedLayer +
    topContent.slice(topLayer.end);

  await Bun.write(stage.topSmallTilemapPath, updated);
  return topCells.length;
}

async function readTilemapOrDefault(path: string): Promise<string> {
  const file = Bun.file(path);

  if (await file.exists()) {
    return file.text();
  }

  return `tile_set: "/assets/sprites/tiles/tiles_sm.tilesource"
layers {
  id: "layer"
  z: 0.0
}
material: "/builtins/materials/tile_map.material"
`;
}

function findLayerBlock(
  content: string,
  id: string,
): { start: number; end: number; block: string } {
  const lines = content.match(/^.*(?:\r?\n|$)/gm) ?? [];
  let offset = 0;

  for (let index = 0; index < lines.length; index += 1) {
    const line = lines[index];
    const start = offset;
    offset += line.length;

    if (!/^\s*layers\s*{/.test(line)) continue;

    let depth = countBraces(line);
    let block = line;
    let end = offset;

    while (depth > 0 && index + 1 < lines.length) {
      index += 1;
      const nextLine = lines[index];
      depth += countBraces(nextLine);
      block += nextLine;
      end += nextLine.length;
      offset += nextLine.length;
    }

    if (new RegExp(`^\\s*id:\\s*"${escapeRegExp(id)}"`, 'm').test(block)) {
      return { start, end, block };
    }
  }

  throw new Error(`No layer with id "${id}" found`);
}

function countBraces(line: string): number {
  let depth = 0;

  for (const char of line) {
    if (char === '{') depth += 1;
    if (char === '}') depth -= 1;
  }

  return depth;
}

function parseCells(layerBlock: string): TileCell[] {
  const cells: TileCell[] = [];
  const cellPattern =
    /cell\s*{\s*x:\s*(-?\d+)\s*y:\s*(-?\d+)\s*tile:\s*(\d+)\s*}/g;
  let match: RegExpExecArray | null;

  while ((match = cellPattern.exec(layerBlock))) {
    cells.push({
      x: Number(match[1]),
      y: Number(match[2]),
      tile: Number(match[3]),
    });
  }

  return cells;
}

function formatLayerBlock(id: string, cells: TileCell[]): string {
  const formattedCells = cells.map(formatCell).join('');

  return `layers {
  id: "${id}"
  z: 0.0
${formattedCells}}
`;
}

function formatCell(cell: TileCell): string {
  return `  cell {
    x: ${cell.x}
    y: ${cell.y}
    tile: ${cell.tile}
  }
`;
}

function cellKey(cell: Pick<TileCell, 'x' | 'y'>): string {
  return `${cell.x}:${cell.y}`;
}

function escapeRegExp(value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function centeredPosition(bounds: TileBounds): [number, number] {
  const centerX = ((bounds.minX + bounds.maxX + 1) * TILE_SIZE) / 2;
  const centerY = ((bounds.minY + bounds.maxY + 1) * TILE_SIZE) / 2;

  return [-centerX, -centerY];
}

async function updateRootPosition(
  collectionPath: string,
  x: number,
  y: number,
): Promise<boolean> {
  const content = await Bun.file(collectionPath).text();
  const [blockStart, blockEnd] = findRootBlock(content);
  const before = content.slice(0, blockStart);
  let block = content.slice(blockStart, blockEnd);
  const after = content.slice(blockEnd);
  const position = formatPositionBlock(x, y);

  if (/\n  position\s*{/.test(block)) {
    block = block.replace(
      /\n  position\s*{\s*x:\s*-?[\d.]+\s*y:\s*-?[\d.]+\s*}/,
      `\n${position.trimEnd()}`,
    );
  } else {
    block = block.replace(/\n}$/, `\n${position}}`);
  }

  const updated = before + block + after;
  if (updated === content) return false;

  await Bun.write(collectionPath, updated);
  return true;
}

function findRootBlock(content: string): [number, number] {
  const start = content.search(/embedded_instances\s*{\s*id:\s*"root"/);
  if (start === -1) {
    throw new Error('No embedded_instances block with id "root" found');
  }

  const end = content.indexOf('\n}', start);
  if (end === -1) {
    throw new Error('Could not find end of embedded_instances "root" block');
  }

  return [start, end + 2];
}

function formatPositionBlock(x: number, y: number): string {
  return `  position {
    x: ${formatNumber(x)}
    y: ${formatNumber(y)}
  }
`;
}

function formatNumber(value: number): string {
  return value.toFixed(1);
}
