<!-- Measured dgemm speed: the netlib reference against two optimized BLAS libraries, on one core in double precision.
     Data: AMD Ryzen 9 9950X, one thread pinned to one core, best of at least 3 runs (and at least 1 s) per size, measured 2026-11-23.
     Reference: dgemm.f from LAPACK 3.12.1, GNU Fortran 16.2.1. OpenBLAS 0.3.33 and MKL 2026.1.0 from conda-forge.
     (MKL 2024.2.2 measured within a few percent of 2026.1 at every size.)
     Hovering shows the values at the nearest measured size, and where A outgrows each cache is marked.
     Usage: <GemmChart /> -->
<script setup lang="ts">
import { computed, ref } from 'vue'

// Matrix size n (all three matrices n × n) and GFLOPS for each library at that size
const N = [100, 200, 256, 350, 500, 512, 750, 1000, 1024, 1250, 1500, 2048, 2500, 3500, 4096]
// In legend order: optimized in blues, reference in warm colours. Checked for colour-blind separation on both themes.
const series = [
  { name: 'OpenBLAS', colour: 'var(--frost1)', data: [161.8, 127.2, 128.8, 129.2, 133.0, 132.7, 135.3, 133.9, 131.9, 135.9, 135.1, 133.7, 137.7, 136.1, 136.5] },
  { name: 'MKL', colour: 'var(--frost3)', data: [71.0, 75.5, 77.7, 80.6, 80.7, 76.5, 80.8, 79.4, 77.1, 78.2, 80.7, 78.0, 79.2, 79.5, 79.3] },
  { name: 'Reference -O3 -march=native', colour: 'var(--yellow)', data: [38.8, 43.4, 44.5, 44.5, 32.2, 33.2, 33.6, 32.4, 32.8, 33.1, 25.7, 12.8, 10.7, 9.7, 9.2] },
  { name: 'Reference -O2', colour: 'var(--red)', data: [20.6, 21.2, 21.0, 18.0, 17.8, 18.2, 17.8, 18.1, 19.0, 18.0, 15.5, 8.1, 8.5, 7.0, 7.0] },
]

// Plot area inside an 860 × 385 drawing; the right margin holds the line labels
const W = 860
const H = 385
const [X0, X1, Y0, Y1] = [44, 680, 26, 345]
const [NMIN, NMAX, GMAX] = [90, 4500, 175]
const x = (n: number) => X0 + (Math.log(n / NMIN) / Math.log(NMAX / NMIN)) * (X1 - X0)
const y = (g: number) => Y1 - (g / GMAX) * (Y1 - Y0)
const X_TICKS = [100, 200, 500, 1000, 2000, 4000]
const Y_TICKS = [0, 25, 50, 75, 100, 125, 150, 175]

const path = (data: number[]) => data.map((g, i) => `${i ? 'L' : 'M'}${x(N[i]).toFixed(1)} ${y(g).toFixed(1)}`).join('')

// Where matrix A (n² doubles) stops fitting in L2 (1 MB per core) and L3 (32 MB per chiplet) on this CPU.
// The reference loops read all of A once per column of C, so these are where it slows down.
const caches = [
  { n: Math.sqrt(2 ** 20 / 8), text: 'A outgrows L2 (1 MB)' },
  { n: Math.sqrt(32 * 2 ** 20 / 8), text: 'A outgrows L3 (32 MB)' },
]

// Labels at the line ends, pushed apart where lines end close together
const LABEL_GAP = 15
const labels = computed(() => {
  const ends = series
    .map(s => ({ name: s.name, value: s.data[N.length - 1], y: y(s.data[N.length - 1]) }))
    .sort((a, b) => a.y - b.y)
  for (let i = 1; i < ends.length; i++)
    ends[i].y = Math.max(ends[i].y, ends[i - 1].y + LABEL_GAP)
  return ends
})

const last = N.length - 1
const speedup = series[0].data[last] / series[3].data[last]

// Hover: the nearest measured size, found in the log scale the axis uses
const svg = ref<SVGSVGElement>()
const hover = ref<number | null>(null)
function onMove(e: PointerEvent) {
  const m = svg.value?.getScreenCTM()
  if (!m)
    return
  const px = new DOMPoint(e.clientX, e.clientY).matrixTransform(m.inverse()).x
  let best = 0
  N.forEach((n, i) => {
    if (Math.abs(x(n) - px) < Math.abs(x(N[best]) - px))
      best = i
  })
  hover.value = best
}
const TIP_W = 230
const tip = computed(() => {
  if (hover.value === null)
    return null
  const at = x(N[hover.value])
  return {
    n: N[hover.value],
    x: at,
    boxX: at + 12 + TIP_W > X1 ? at - 12 - TIP_W : at + 12,
    rows: series.map(s => ({ name: s.name, colour: s.colour, value: s.data[hover.value!] })),
  }
})
</script>

<template>
  <div>
    <!-- Legend -->
    <div class="flex flex-wrap gap-x-6 gap-y-1 text-sm mb-1 pl-10">
      <span v-for="s in series" :key="s.name">
        <svg width="22" height="10" class="inline-block mr-1.5 align-middle">
          <line x1="0" y1="5" x2="22" y2="5" :style="{ stroke: s.colour }" stroke-width="2" />
          <circle cx="11" cy="5" r="3.5" :style="{ fill: s.colour }" />
        </svg>{{ s.name }}
      </span>
    </div>

    <svg ref="svg" :viewBox="`0 0 ${W} ${H}`" class="w-full select-none">
      <!-- Axes and gridlines, kept quiet -->
      <g class="grid">
        <line v-for="t in Y_TICKS" :key="`y${t}`" :x1="X0" :x2="X1" :y1="y(t)" :y2="y(t)" />
      </g>
      <text v-for="t in Y_TICKS" :key="`yl${t}`" class="tick" :x="X0 - 8" :y="y(t) + 4" text-anchor="end">{{ t }}</text>
      <text v-for="t in X_TICKS" :key="`xl${t}`" class="tick" :x="x(t)" :y="Y1 + 18" text-anchor="middle">{{ t }}</text>
      <text class="axis" :x="X0 - 36" :y="Y0 - 12">GFLOPS</text>
      <text class="axis" :x="(X0 + X1) / 2" :y="Y1 + 36" text-anchor="middle">matrix size n</text>

      <!-- Where A outgrows each cache -->
      <g v-for="c in caches" :key="c.text">
        <line class="cache" :x1="x(c.n)" :x2="x(c.n)" :y1="Y0" :y2="Y1" />
        <text class="cache-label" :x="x(c.n) + 5" :y="Y0 + 12">{{ c.text }}</text>
      </g>

      <!-- The lines; series[] is drawn back to front so OpenBLAS stays on top -->
      <g v-for="s in [...series].reverse()" :key="s.name">
        <path :d="path(s.data)" class="line" :style="{ stroke: s.colour }" />
        <circle
          v-for="(g, i) in s.data" :key="i" class="marker"
          :cx="x(N[i])" :cy="y(g)" :r="hover === i ? 6 : 4" :style="{ fill: s.colour }"
        />
      </g>

      <!-- Line labels at the right end, in text colour -->
      <text v-for="l in labels" :key="l.name" class="end-label" :x="x(N[last]) + 22" :y="l.y + 4">
        {{ l.name.replace(' -march=native', '') }} <tspan class="end-value">{{ l.value.toFixed(1) }}</tspan>
      </text>

      <!-- The gap at the largest size -->
      <g class="gap">
        <line :x1="x(N[last]) + 11" :x2="x(N[last]) + 11" :y1="y(series[0].data[last])" :y2="y(series[3].data[last])" />
        <line :x1="x(N[last]) + 7" :x2="x(N[last]) + 15" :y1="y(series[0].data[last])" :y2="y(series[0].data[last])" />
        <line :x1="x(N[last]) + 7" :x2="x(N[last]) + 15" :y1="y(series[3].data[last])" :y2="y(series[3].data[last])" />
        <text class="gap-label" :x="x(N[last]) - 10" :y="y(45)" text-anchor="end">{{ speedup.toFixed(1) }}×</text>
      </g>

      <!-- Hover: crosshair at the nearest size and its values -->
      <g v-if="tip" class="tip">
        <line class="crosshair" :x1="tip.x" :x2="tip.x" :y1="Y0" :y2="Y1" />
        <rect class="tip-box" :x="tip.boxX" :y="Y0 + 22" :width="TIP_W" :height="28 + tip.rows.length * 20" rx="4" />
        <text class="tip-title" :x="tip.boxX + 10" :y="Y0 + 42">n = {{ tip.n }}</text>
        <g v-for="(r, i) in tip.rows" :key="r.name">
          <circle :cx="tip.boxX + 15" :cy="Y0 + 58 + i * 20" r="4" :style="{ fill: r.colour }" />
          <text class="tip-row" :x="tip.boxX + 26" :y="Y0 + 62 + i * 20">{{ r.name }}</text>
          <text class="tip-row tip-value" :x="tip.boxX + TIP_W - 10" :y="Y0 + 62 + i * 20" text-anchor="end">{{ r.value.toFixed(1) }}</text>
        </g>
      </g>
      <!-- Hit area for hovering, bigger than the marks -->
      <rect :x="X0" :y="Y0" :width="X1 - X0 + 20" :height="Y1 - Y0" fill="transparent" @pointermove="onMove" @pointerleave="hover = null" />
    </svg>
  </div>
</template>

<style scoped>
.grid line {
  stroke: currentColor;
  stroke-width: 1;
  opacity: 0.12;
}
.tick,
.axis {
  fill: currentColor;
  font-size: 12px;
  opacity: 0.7;
}
.cache {
  stroke: currentColor;
  stroke-width: 1;
  stroke-dasharray: 4 4;
  opacity: 0.45;
}
.cache-label {
  fill: currentColor;
  font-size: 11px;
  opacity: 0.7;
}
.line {
  fill: none;
  stroke-width: 2;
  stroke-linejoin: round;
}
.marker {
  stroke: var(--slidev-bg); /* a ring of background keeps overlapping points apart */
  stroke-width: 2;
  transition: r 0.1s;
}
.end-label {
  fill: currentColor;
  font-size: 13px;
}
.end-value {
  font-family: var(--slidev-code-font-family);
  opacity: 0.7;
}
.gap line {
  stroke: currentColor;
  stroke-width: 1.5;
}
.gap-label {
  fill: currentColor;
  font-size: 26px;
  font-weight: 700;
}
.crosshair {
  stroke: currentColor;
  stroke-width: 1;
  opacity: 0.4;
}
.tip-box {
  fill: var(--slidev-bg-alt);
  stroke: var(--frost2);
  stroke-width: 1;
}
.tip-title {
  fill: currentColor;
  font-size: 13px;
  font-weight: 700;
}
.tip-row {
  fill: currentColor;
  font-size: 12px;
}
.tip-value {
  font-family: var(--slidev-code-font-family);
}
</style>
