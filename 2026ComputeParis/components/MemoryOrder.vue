<!-- A 3×3 matrix above the order its entries sit in memory. Each contiguous run (a row in C order, a column in F order)
     gets one colour, so the strip shows which entries are neighbours in memory.
     Usage: <MemoryOrder order="C" />  or  <MemoryOrder order="F" /> -->
<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  order: 'C' | 'F'
}>()

const n = 3
const colors = ['var(--frost1)', 'var(--yellow)', 'var(--purple)']

// The matrix entries row by row, as they are drawn: a b c / d e f / g h i
const entries = Array.from({ length: n * n }, (_, k) => ({ i: Math.floor(k / n), j: k % n, name: 'abcdefghi'[k] }))

const run = (e: { i: number, j: number }) => (props.order === 'C' ? e.i : e.j)

// The same entries in memory order: row after row in C order, column after column in F order
const memory = computed(() => props.order === 'C'
  ? entries
  : Array.from({ length: n * n }, (_, k) => entries[(k % n) * n + Math.floor(k / n)]))
</script>

<template>
  <div class="flex flex-col items-center gap-8">
    <div class="grid grid-cols-3 gap-1">
      <div
        v-for="e in entries" :key="e.name"
        class="w-12 h-12 flex items-center justify-center rounded font-mono text-xl text-[var(--dark0)]"
        :style="{ background: colors[run(e)] }"
      >
        {{ e.name }}
      </div>
    </div>
    <div class="flex flex-col items-start">
      <div class="flex gap-0.5">
        <div
          v-for="e in memory" :key="e.name"
          class="w-10 h-10 flex items-center justify-center font-mono text-lg text-[var(--dark0)] first:rounded-l last:rounded-r"
          :style="{ background: colors[run(e)] }"
        >
          {{ e.name }}
        </div>
      </div>
      <div class="mt-1 text-sm opacity-60">memory →</div>
    </div>
  </div>
</template>
