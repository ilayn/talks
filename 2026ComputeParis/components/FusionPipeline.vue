<!-- The steps of the pairwise-distance example D = sqrt(-2 * X @ Y.T + xx[:, None] + yy), as they run.
     Without `fused`, each step is its own pass: it writes an n×m matrix to memory and the next step reads it back
     (red and hatched, like the Fortran block on the stack slide).
     With `fused`, all steps run on the C tile while it sits in registers (yellow, as on the micro-kernel slides) and only D is written.
     Usage: <FusionPipeline /> or <FusionPipeline fused /> -->
<script setup lang="ts">
defineProps<{
  fused?: boolean
}>()

const steps = ['X @ Y.T', '-2 *', '+ xx', '+ yy', 'sqrt']
</script>

<template>
  <div class="pipeline">
    <template v-if="!fused">
      <template v-for="(s, i) in steps" :key="s">
        <span class="op">{{ s }}</span>
        <span class="arrow">→</span>
        <template v-if="i < steps.length - 1">
          <span class="temp" title="an n × m matrix in memory"><span class="temp-label">n×m</span></span>
          <span class="arrow">→</span>
        </template>
      </template>
    </template>
    <template v-else>
      <span class="registers">
        <template v-for="(s, i) in steps" :key="s">
          <span class="op">{{ s }}</span>
          <span v-if="i < steps.length - 1" class="arrow">→</span>
        </template>
        <span class="registers-label">on the C tile, in registers</span>
      </span>
      <span class="arrow">→</span>
    </template>
    <span class="op result">D</span>
  </div>
</template>

<style scoped>
.pipeline {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-family: var(--slidev-code-font-family);
  font-size: 0.9rem;
}
.op {
  padding: 0.2em 0.6em;
  border: 1.5px solid var(--frost2);
  border-radius: 0.3rem;
  background: var(--slidev-bg-alt);
  white-space: nowrap;
}
.result {
  border-color: currentColor;
}
.arrow {
  opacity: 0.6;
}
/* An n×m temporary in memory */
.temp {
  position: relative;
  width: 1.6rem;
  height: 1.6rem;
  flex: none;
  border: 2px solid var(--red);
  border-radius: 0.2rem;
  background: repeating-linear-gradient(-45deg, var(--red) 0 2px, transparent 2px 7px);
}
.temp-label {
  position: absolute;
  top: 100%;
  left: 50%;
  transform: translateX(-50%);
  margin-top: 0.15rem;
  font-size: 0.65rem;
  opacity: 0.7;
}
/* Everything that happens on the C tile without leaving the registers */
.registers {
  position: relative;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.4rem 0.6rem;
  border: 2px solid var(--yellow);
  border-radius: 0.4rem;
  background: color-mix(in srgb, var(--yellow) 15%, transparent);
}
.registers-label {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  margin-top: 0.2rem;
  text-align: center;
  font-family: var(--slidev-font-family, inherit);
  font-size: 0.7rem;
  opacity: 0.8;
}
</style>
