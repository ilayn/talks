<!-- Goto's micro-kernel: an MR×NR tile of C, kept in registers, gets KC rank-1 updates,
     each one column of the packed A sliver times one row of the packed B sliver.
     Step 0 shows the three blocks, step 1 the first update; step 2 plays all KC updates once, and later steps leave C finished.
     Exports skip the playing and show C finished.
     Usage: <RankOneUpdate :step="$clicks" /> -->
<script setup lang="ts">
import { useNav } from '@slidev/client'
import { computed, onUnmounted, ref, watch } from 'vue'

const props = defineProps<{
  step: number
}>()

const MR = 6
const NR = 8
const KC = 12 // far larger in a real kernel; 12 keeps the drawing legible
const CELL = 18
const GAP = 14
const PLAY_MS = 400 // per update

// Same arrangement as <GotoLoops>: the B sliver above the C tile, the A sliver to its left
const A = { x: 0, y: KC * CELL + GAP, rows: MR, cols: KC }
const B = { x: KC * CELL + GAP, y: 0, rows: KC, cols: NR }
const C = { x: KC * CELL + GAP, y: KC * CELL + GAP, rows: MR, cols: NR }

// The update on screen: -1 before the first, KC once all are done
const p = ref(-1)
let timer: ReturnType<typeof setInterval> | undefined

const { isPrintMode } = useNav()

watch(() => props.step, (step, before) => {
  if (step >= 2 && isPrintMode.value) {
    p.value = KC // exporting: no time to play, show it finished
  }
  else if (step >= 2 && before !== undefined && before < 2) {
    // Arriving at step 2: play every update once
    clearInterval(timer)
    p.value = 0
    timer = setInterval(() => {
      p.value++
      if (p.value >= KC)
        clearInterval(timer)
    }, PLAY_MS)
  }
  else if (step < 2) {
    clearInterval(timer)
    p.value = step === 1 ? 0 : -1
  }
  else if (before === undefined) {
    p.value = KC // opened at step 2 or later, e.g. going back to the slide: show it finished
  }
}, { immediate: true })

onUnmounted(() => clearInterval(timer))

const done = computed(() => Math.min(p.value + 1, KC)) // updates applied to C so far

const cells = (M: typeof A) => Array.from({ length: M.rows * M.cols }, (_, i) => ({
  i,
  row: Math.floor(i / M.cols),
  col: i % M.cols,
  x: M.x + (i % M.cols) * CELL,
  y: M.y + Math.floor(i / M.cols) * CELL,
}))
const aCells = cells(A)
const bCells = cells(B)
const cCells = cells(C)
</script>

<template>
  <svg :viewBox="`-4 -30 ${B.x + B.cols * CELL + 8} ${C.y + C.rows * CELL + 64}`" class="w-full">
    <text class="label" :x="B.x + (B.cols * CELL) / 2" y="-12">Bp sliver: KC × NR</text>
    <text class="label" :x="(A.cols * CELL) / 2" :y="A.y + A.rows * CELL + 22">Ap sliver: MR × KC</text>
    <text class="label" :x="C.x + (C.cols * CELL) / 2" :y="C.y + C.rows * CELL + 22">C tile, in registers</text>
    <text class="counter" :x="(A.cols * CELL) / 2" :y="(B.rows * CELL) / 2" :style="{ opacity: p >= 0 ? 1 : 0 }">
      update {{ done }} of KC
    </text>

    <rect
      v-for="c in aCells" :key="`a${c.i}`" class="cell" :class="{ active: c.col === p }"
      :x="c.x" :y="c.y" :width="CELL" :height="CELL"
    />
    <rect
      v-for="c in bCells" :key="`b${c.i}`" class="cell" :class="{ active: c.row === p }"
      :x="c.x" :y="c.y" :width="CELL" :height="CELL"
    />
    <rect
      v-for="c in cCells" :key="`c${c.i}`" class="cell c"
      :x="c.x" :y="c.y" :width="CELL" :height="CELL"
      :style="{ '--filled': done / KC }"
    />
  </svg>
</template>

<style scoped>
.cell {
  fill: var(--slidev-bg-alt);
  stroke: var(--frost2);
  stroke-width: 1;
  transition: fill 0.15s;
}
.cell.active {
  fill: var(--frost1);
}
/* C fills up with each update */
.cell.c {
  fill: color-mix(in srgb, var(--yellow) calc(var(--filled) * 100%), var(--slidev-bg-alt));
  transition: fill 0.3s;
}
.label,
.counter {
  fill: currentColor;
  font-size: 13px;
  text-anchor: middle;
}
.counter {
  font-family: var(--slidev-code-font-family);
  opacity: 0.8;
  transition: opacity 0.3s;
}
</style>
