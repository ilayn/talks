<!-- Click a cell in L1, L2 or memory to load it into the CPU, and watch how long it takes: one cycle is one sixtieth of a second,
     so a load from memory takes ten seconds. On its way the value is copied into every cache it passes through.
     A rebuild of Tony Albrecht's "Relative Memory Access speeds (Lesson 3)" demo, overbyte.com.au (2014):
     https://web.archive.org/web/20140402225836/http://www.overbyte.com.au/misc/Lesson3/CacheFun.html
     Same idea, cache sizes and latencies; our own code. The levels sit in a row to fit a slide, and the counter stops when the load arrives.
     Usage: <CacheLatency /> -->
<script setup lang="ts">
import { computed, onUnmounted, reactive, ref, shallowRef } from 'vue'

const CELL = 8 // cell size, in SVG units
const GAP = 64 // horizontal gap between two levels
const MID = 180 // the levels are centred on this line
const CPU_PAD = 12 // the CPU frame around the registers
const WIDTH = 900
const HEIGHT = 360
const CYCLE_MS = 1000 / 60

// From the CPU outwards. `latency` is the cycles a load from that level takes to reach the CPU.
const sizes = [
  { name: 'CPU', cols: 1, rows: 4, latency: 0 },
  { name: 'L1', cols: 8, rows: 8, latency: 4 },
  { name: 'L2', cols: 22, rows: 18, latency: 30 },
  { name: 'Memory', cols: 50, rows: 36, latency: 600 },
]
let left = 10 + CPU_PAD
const levels = sizes.map((s) => {
  const w = s.cols * CELL
  const h = s.rows * CELL
  const level = { ...s, w, h, x: left, y: MID - h / 2 }
  left += w + GAP
  return level
})

// Centred under the CPU and L1
const COUNTER_X = (levels[0].x - CPU_PAD + levels[1].x + levels[1].w) / 2

const gridPath = (l: typeof levels[number]) => [
  ...Array.from({ length: l.rows - 1 }, (_, r) => `M${l.x} ${l.y + (r + 1) * CELL}h${l.w}`),
  ...Array.from({ length: l.cols - 1 }, (_, c) => `M${l.x + (c + 1) * CELL} ${l.y}v${l.h}`),
].join('')

const palette = ['var(--red)', 'var(--orange)', 'var(--yellow)', 'var(--green)', 'var(--purple)', 'var(--frost1)']
let nextColour = 0

// What each cell holds, keyed by "level:col:row"
const contents = reactive(new Map<string, string>())
const key = (level: number, col: number, row: number) => `${level}:${col}:${row}`

// A value on its way from `level` to the level below it
interface Hop { chain: number, level: number, col: number, row: number, colour: string, t0: number }
const hops = shallowRef<Hop[]>([])
const hopMs = (h: Hop) => (levels[h.level].latency - levels[h.level - 1].latency) * CYCLE_MS
// The cell a value lands in, one level down: the same position, wrapped to that level's size
const below = (h: Hop) => ({ col: h.col % levels[h.level - 1].cols, row: h.row % levels[h.level - 1].rows })

// The counter follows the latest click
let chains = 0
const now = ref(0)
const started = ref<number | null>(null)
const finished = ref(false)
const total = ref(0)
const cycles = computed(() => started.value === null
  ? 0
  : finished.value ? total.value : Math.min(Math.floor((now.value - started.value) / CYCLE_MS), total.value))

let raf = 0
function tick(t: number) {
  now.value = t
  let landed = hops.value.find(h => t >= h.t0 + hopMs(h))
  while (landed) {
    const h = landed
    const arrival = h.t0 + hopMs(h)
    const { col, row } = below(h)
    contents.set(key(h.level - 1, col, row), h.colour)
    const rest = hops.value.filter(x => x !== h)
    if (h.level - 1 > 0)
      rest.push({ ...h, level: h.level - 1, col, row, t0: arrival })
    else if (h.chain === chains)
      finished.value = true
    hops.value = rest
    landed = hops.value.find(x => t >= x.t0 + hopMs(x))
  }
  raf = hops.value.length ? requestAnimationFrame(tick) : 0
}

function load(level: number, col: number, row: number) {
  const t = performance.now()
  const colour = contents.get(key(level, col, row)) ?? palette[nextColour++ % palette.length]
  contents.set(key(level, col, row), colour)
  hops.value = [...hops.value, { chain: ++chains, level, col, row, colour, t0: t }]
  now.value = t
  started.value = t
  finished.value = false
  total.value = levels[level].latency
  if (!raf)
    raf = requestAnimationFrame(tick)
}

const svg = ref<SVGSVGElement>()
function onClick(e: MouseEvent) {
  // Map the click into SVG units; this also undoes Slidev's scaling of the slide
  const m = svg.value?.getScreenCTM()
  if (!m)
    return
  const p = new DOMPoint(e.clientX, e.clientY).matrixTransform(m.inverse())
  levels.forEach((l, i) => {
    if (i > 0 && p.x >= l.x && p.x < l.x + l.w && p.y >= l.y && p.y < l.y + l.h)
      load(i, Math.floor((p.x - l.x) / CELL), Math.floor((p.y - l.y) / CELL))
  })
}

function clear() {
  contents.clear()
  hops.value = []
  started.value = null
}

onUnmounted(() => cancelAnimationFrame(raf))

const filled = computed(() => [...contents].map(([k, colour]) => {
  const [level, col, row] = k.split(':').map(Number)
  return { k, colour, x: levels[level].x + col * CELL, y: levels[level].y + row * CELL }
}))

const moving = computed(() => hops.value.map((h) => {
  const from = levels[h.level]
  const to = levels[h.level - 1]
  const { col, row } = below(h)
  const s = Math.min(Math.max((now.value - h.t0) / hopMs(h), 0), 1)
  const x0 = from.x + h.col * CELL
  const y0 = from.y + h.row * CELL
  return { chain: h.chain, colour: h.colour, x: x0 + (to.x + col * CELL - x0) * s, y: y0 + (to.y + row * CELL - y0) * s }
}))
</script>

<template>
  <div class="select-none">
    <svg ref="svg" :viewBox="`0 0 ${WIDTH} ${HEIGHT}`" class="w-full cursor-pointer" @click="onClick">
      <rect
        class="box" rx="6"
        :x="levels[0].x - CPU_PAD" :y="levels[0].y - CPU_PAD"
        :width="levels[0].w + 2 * CPU_PAD" :height="levels[0].h + 2 * CPU_PAD"
      />
      <g v-for="(l, i) in levels" :key="l.name">
        <rect :class="i === 0 ? 'registers' : 'box'" :x="l.x" :y="l.y" :width="l.w" :height="l.h" />
        <path class="grid" :d="gridPath(l)" />
        <text class="label" :x="l.x + l.w / 2" :y="l.y - (i === 0 ? CPU_PAD : 0) - 10">{{ l.name }}</text>
        <text v-if="l.latency" class="latency" :x="l.x + l.w / 2" :y="l.y + l.h + 24">{{ l.latency }} cycles</text>
      </g>
      <rect v-for="c in filled" :key="c.k" :x="c.x" :y="c.y" :width="CELL" :height="CELL" :style="{ fill: c.colour }" />
      <rect v-for="m in moving" :key="m.chain" class="moving" :x="m.x" :y="m.y" :width="CELL" :height="CELL" :style="{ fill: m.colour }" />
      <!-- The counter, in the free space under the CPU and L1 -->
      <text class="counter" :x="COUNTER_X" :y="MID + 115">{{ cycles }}</text>
      <text class="latency" :x="COUNTER_X" :y="MID + 140">cycles</text>
      <text class="clear" :x="COUNTER_X" :y="MID + 175" @click.stop="clear">clear</text>
    </svg>
  </div>
</template>

<style scoped>
.box {
  fill: var(--slidev-bg-alt);
  stroke: var(--frost2);
  stroke-width: 2;
}
.registers {
  fill: var(--slidev-bg);
  stroke: var(--frost2);
  stroke-width: 1;
}
.grid {
  stroke: var(--frost2);
  stroke-width: 0.5;
  opacity: 0.3;
}
.label {
  fill: currentColor;
  font-size: 15px;
  text-anchor: middle;
}
.latency {
  fill: currentColor;
  font-size: 13px;
  text-anchor: middle;
  opacity: 0.7;
}
.counter {
  fill: currentColor;
  font-family: var(--slidev-code-font-family);
  font-size: 44px;
  text-anchor: middle;
}
.clear {
  fill: currentColor;
  font-size: 11px;
  text-anchor: middle;
  opacity: 0.4;
}
.clear:hover {
  opacity: 0.8;
}
.moving {
  stroke: var(--slidev-bg); /* a ring keeps the value visible over the cells it passes */
  stroke-width: 1.5;
}
</style>
