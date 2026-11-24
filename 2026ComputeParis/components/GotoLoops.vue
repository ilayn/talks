<!-- The five loops of Goto's matrix multiplication, in BLIS's naming: C += A·B chopped into blocks that each fit one level of the memory hierarchy.
     Step 1 to 5 highlights the next loop's block, from the outermost (jc) to the innermost (ir); step 0 shows the bare matrices.
     After K. Goto and R. van de Geijn, "Anatomy of High-Performance Matrix Multiplication", ACM TOMS 34(3), 2008,
     and F. Van Zee and R. van de Geijn, "BLIS: A Framework for Rapidly Instantiating BLAS Functionality", ACM TOMS 41(3), 2015.
     Usage: <GotoLoops :step="$clicks" /> -->
<script setup lang="ts">
defineProps<{
  step: number
}>()

// Matrix sizes in drawing units: A is m×k, B is k×n, C is m×n.
// B sits above C and A to its left, so a block's rows and columns line up across the matrices.
const k = 120
const m = 180
const n = 240
const GAP = 16
const A = { x: 0, y: k + GAP, w: k, h: m }
const B = { x: k + GAP, y: 0, w: n, h: k }
const C = { x: k + GAP, y: k + GAP, w: n, h: m }

// The blocks the walk-through follows: offset and size of each, in drawing units
const [jc, NC] = [120, 120]
const [pc, KC] = [0, 60]
const [ic, MC] = [60, 60]
const [jr, NR] = [40, 20]
const [ir, MR] = [15, 15]

type Box = typeof A
const part = (M: Box, dx: number, dy: number, w: number, h: number) => ({ x: M.x + dx, y: M.y + dy, w, h })

// shade 1: the outer loops' panels, 2: the packed blocks, 3: the slivers, 4: the register tile
const OPACITY = [0, 0.15, 0.3, 0.55, 1]
const blocks = [
  { step: 1, shade: 1, ...part(B, jc, 0, NC, k) },
  { step: 1, shade: 1, ...part(C, jc, 0, NC, m) },
  { step: 2, shade: 1, ...part(A, pc, 0, KC, m) },
  { step: 2, shade: 2, ...part(B, jc, pc, NC, KC) },
  { step: 3, shade: 2, ...part(A, pc, ic, KC, MC) },
  { step: 3, shade: 2, ...part(C, jc, ic, NC, MC) },
  { step: 4, shade: 3, ...part(B, jc + jr, pc, NR, KC) },
  { step: 4, shade: 3, ...part(C, jc + jr, ic, NR, MC) },
  { step: 5, shade: 3, ...part(A, pc, ic + ir, KC, MR) },
  { step: 5, shade: 4, ...part(C, jc + jr, ic + ir, NR, MR) },
]

// Block sizes, each on its own edge so they never collide
const sizes = [
  { step: 1, text: 'NC', x: B.x + jc + NC / 2, y: -8, anchor: 'middle' },
  { step: 2, text: 'KC', x: B.x + n + 8, y: pc + KC / 2 + 4, anchor: 'start' },
  { step: 3, text: 'MC', x: -8, y: A.y + ic + MC / 2 + 4, anchor: 'end' },
  { step: 4, text: 'NR', x: C.x + jc + jr + NR / 2, y: C.y + m + 18, anchor: 'middle' },
  { step: 5, text: 'MR', x: C.x + n + 8, y: C.y + ic + ir + MR / 2 + 4, anchor: 'start' },
]

// Where each block lives, in the empty corner above A. Both slivers are in L1 during a kernel call:
// the Bp sliver stays there for the whole ir loop, while each Ap sliver passes through once on its way from L2.
const legend = [
  { step: 2, text: 'Bp → L3' },
  { step: 3, text: 'Ap → L2' },
  { step: 4, text: 'Bp sliver → L1, stays' },
  { step: 5, text: 'Ap sliver → L1, streams' },
  { step: 5, text: 'C tile → registers' },
]
</script>

<template>
  <svg viewBox="-44 -28 464 372" class="w-full">
    <g v-for="(M, name) in { A, B, C }" :key="name">
      <rect class="matrix" :x="M.x" :y="M.y" :width="M.w" :height="M.h" />
      <text class="name" :x="M.x + 8" :y="M.y + 20">{{ name }}</text>
    </g>
    <rect
      v-for="(b, i) in blocks" :key="i"
      :class="[b.shade === 4 ? 'tile' : 'block', { current: b.step === step }]"
      :x="b.x" :y="b.y" :width="b.w" :height="b.h"
      :style="{ fillOpacity: step >= b.step ? OPACITY[b.shade] : 0, strokeOpacity: b.step === step ? 1 : 0 }"
    />
    <text
      v-for="s in sizes" :key="s.text" class="size"
      :x="s.x" :y="s.y" :text-anchor="s.anchor" :style="{ opacity: step >= s.step ? 1 : 0 }"
    >
      {{ s.text }}
    </text>
    <text
      v-for="(l, i) in legend" :key="l.text" class="legend"
      :x="-40" :y="18 + i * 23" :style="{ opacity: step >= l.step ? 1 : 0 }"
    >
      {{ l.text }}
    </text>
  </svg>
</template>

<style scoped>
.matrix {
  fill: var(--slidev-bg-alt);
  stroke: var(--frost2);
  stroke-width: 1.5;
}
.block,
.tile {
  stroke: var(--frost1);
  stroke-width: 2;
  transition: fill-opacity 0.4s, stroke-opacity 0.4s;
}
.block {
  fill: var(--frost2);
}
.tile {
  fill: var(--yellow);
}
.name {
  fill: currentColor;
  font-size: 16px;
  opacity: 0.7;
}
.size {
  fill: currentColor;
  font-family: var(--slidev-code-font-family);
  font-size: 13px;
  transition: opacity 0.4s;
}
.legend {
  fill: currentColor;
  font-size: 13px;
  transition: opacity 0.4s;
}
</style>
