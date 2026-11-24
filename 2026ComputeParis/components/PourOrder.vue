<!-- A 3×3 matrix product poured like 9 Negronis: each entry of C is a glass, and k picks the ingredient (gin, Campari, vermouth).
     Both orders make the same 27 pours; the counter shows how often a bottle gets picked up.
       order="dot":   glass by glass, (gin, Campari, vermouth) × 9, that is C[i, j] = A[i, :] · B[:, j]
       order="outer": bottle by bottle, gin × 9, Campari × 9, vermouth × 9, that is C += A[:, k] B[k, :], one rank-1 update per bottle
     Plays once when `play` turns true. Exports, and coming back to the slide, show it finished.
     Usage: <PourOrder order="outer" :play="$clicks >= 2" /> -->
<script setup lang="ts">
import { useNav } from '@slidev/client'
import { computed, onUnmounted, ref, watch } from 'vue'

const props = defineProps<{
  order: 'dot' | 'outer'
  play: boolean
}>()

const N = 3
const CELL = 36
const GAP = 12
const POUR_MS = 160
const INGREDIENTS = [
  { name: 'gin', colour: 'var(--frost1)' },
  { name: 'Campari', colour: 'var(--red)' },
  { name: 'vermouth', colour: 'var(--yellow)' },
]

// Same arrangement as the other matrix diagrams: B above C, A to its left
const SIZE = N * CELL
const A = { x: 0, y: SIZE + GAP }
const B = { x: SIZE + GAP, y: 0 }
const C = { x: SIZE + GAP, y: SIZE + GAP }
const range = [0, 1, 2]

// The 27 pours in this order, each [i, j, k]: glass C[i, j] gets ingredient k, using A[i, k] and B[k, j]
const pours: [number, number, number][] = []
for (const a of range) {
  for (const b of range) {
    for (const c of range)
      pours.push(props.order === 'dot' ? [a, b, c] : [b, c, a])
  }
}

const done = ref(0) // pours made so far
let timer: ReturnType<typeof setInterval> | undefined
const { isPrintMode } = useNav()

watch(() => props.play, (play, before) => {
  clearInterval(timer)
  if (!play) {
    done.value = 0
  }
  else if (before === false && !isPrintMode.value) {
    done.value = 0
    timer = setInterval(() => {
      done.value++
      if (done.value >= pours.length)
        clearInterval(timer)
    }, POUR_MS)
  }
  else {
    done.value = pours.length
  }
}, { immediate: true })

onUnmounted(() => clearInterval(timer))

// The pour on screen, highlighted while playing
const current = computed(() => (done.value > 0 && done.value < pours.length ? pours[done.value - 1] : null))
const isPoured = (i: number, j: number, k: number) =>
  pours.findIndex(([pi, pj, pk]) => pi === i && pj === j && pk === k) < done.value
// A new pickup whenever the ingredient changes from one pour to the next
const pickups = computed(() => pours.slice(0, done.value).filter((p, t) => t === 0 || p[2] !== pours[t - 1][2]).length)
</script>

<template>
  <div>
    <svg :viewBox="`-2 -2 ${2 * SIZE + GAP + 24} ${2 * SIZE + GAP + 28}`" class="w-full">
      <!-- The bottles, next to the rows of B they belong to -->
      <g v-for="(ing, k) in INGREDIENTS" :key="ing.name" :class="{ dim: current && current[2] !== k }">
        <text class="bottle" :x="SIZE - 16" :y="k * CELL + CELL / 2 + 4">{{ ing.name }}</text>
        <rect :x="SIZE - 11" :y="k * CELL + CELL / 2 - 5" width="10" height="10" rx="2" :style="{ fill: ing.colour }" />
      </g>

      <!-- A[i, k] and B[k, j], tinted by ingredient; the pair in use lights up -->
      <template v-for="i in range" :key="`a${i}`">
        <rect
          v-for="k in range" :key="k" class="cell" :class="{ active: current && current[0] === i && current[2] === k }"
          :x="A.x + k * CELL" :y="A.y + i * CELL" :width="CELL" :height="CELL" :style="{ '--ing': INGREDIENTS[k].colour }"
        />
      </template>
      <template v-for="k in range" :key="`b${k}`">
        <rect
          v-for="j in range" :key="j" class="cell" :class="{ active: current && current[2] === k && current[1] === j }"
          :x="B.x + j * CELL" :y="B.y + k * CELL" :width="CELL" :height="CELL" :style="{ '--ing': INGREDIENTS[k].colour }"
        />
      </template>

      <!-- C: nine glasses, filling bottom-up with one layer per ingredient -->
      <template v-for="i in range" :key="`c${i}`">
        <g v-for="j in range" :key="j">
          <rect class="glass" :class="{ active: current && current[0] === i && current[1] === j }" :x="C.x + j * CELL" :y="C.y + i * CELL" :width="CELL" :height="CELL" />
          <rect
            v-for="k in range" v-show="isPoured(i, j, k)" :key="k"
            :x="C.x + j * CELL + 3" :y="C.y + (i + 1) * CELL - (k + 1) * (CELL - 6) / 3 - 3"
            :width="CELL - 6" :height="(CELL - 6) / 3" :style="{ fill: INGREDIENTS[k].colour }"
          />
        </g>
      </template>

      <text class="name" :x="A.x + SIZE / 2" :y="A.y + SIZE + 18">A</text>
      <text class="name" :x="B.x + SIZE + 12" :y="B.y + SIZE / 2 + 5">B</text>
      <text class="name" :x="C.x + SIZE / 2" :y="C.y + SIZE + 18">C</text>
    </svg>
    <div class="mt-1 flex justify-center items-baseline gap-2 whitespace-nowrap">
      <span class="font-mono text-3xl">{{ pickups }}</span>
      <span class="opacity-70">bottle pickups</span>
    </div>
    <div class="text-sm opacity-50">{{ done }} / 27 pours</div>
  </div>
</template>

<style scoped>
.cell {
  fill: color-mix(in srgb, var(--ing) 25%, var(--slidev-bg-alt));
  stroke: var(--frost2);
  stroke-width: 1;
}
.cell.active {
  fill: var(--ing);
}
.glass {
  fill: var(--slidev-bg-alt);
  stroke: var(--frost2);
  stroke-width: 1;
}
.cell.active,
.glass.active {
  stroke: currentColor;
  stroke-width: 2.5;
}
.bottle,
.name {
  fill: currentColor;
  font-size: 13px;
}
.bottle {
  text-anchor: end;
  transition: opacity 0.1s;
}
.name {
  text-anchor: middle;
  opacity: 0.7;
}
.dim {
  opacity: 0.35;
}
</style>
