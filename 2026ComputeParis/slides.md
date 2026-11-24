---
theme: nord
title: from hardware import linalg
info: No country for linear algebra
transition: slide-left
mdc: true
layout: cover
class: ipython-title
---

<div class="console">

# <span class="prompt">In &#91;<span class="num">1</span>&#93;:</span> <span class="kw">from</span> <span class="mod">hardware</span> <span class="kw">import</span> <span class="mod">linalg</span>

<span class="err">UnfortunateError</span>: No country for linalg code

<span class="prompt">In &#91;<span class="num">2</span>&#93;:</span><span class="cursor"></span>

</div>

Ilhan Polat - @ilayn · Paris, November 2026 {.absolute .inset-x-0 .bottom-10}

<!-- QR code for https://ilayn.github.io/talks/2026ComputeParis/, made with segno (dark modules on Nord's light background, 4-module margin) -->
![QR code linking to these slides](/figures/slides-qr.svg){.absolute .bottom-6 .right-8 .w-40 .rounded-md}

<!--
Thank you everyone, it is really exciting to be here, since I do not code for a living and I have been outside the research circles for quite a while. Hence I truly appreciate the opportunity.

It is also a very nice opportunity to put some faces to the GitHub handles I have been seeing for over a decade now.
-->

---
layout: center
---

# <ph-person-simple-run class="inline-block align-[-0.1em]" /> Safety first

- No drills planned for today {v-click="1"}
- Be quick, but don't rush it {v-click="2"}
- Leave your stuff behind <span v-click="4">(except RAM sticks)</span> {v-click="3"}
- Exits: <span class="todo">ask reception</span> {v-click="5"}
- Go to the meeting point and stay there {v-click="6"}


<!--
**TODO before the talk:** confirm with reception that no drills are planned, and get the exits and the meeting point.

Before we start: I am a mechanical engineer, so if we don't do this I get itchy. I spoke with reception, no drills are planned for today, so here is the procedure...
-->

---
layout: center
class: text-center
---

###### Take away

<div class="pkgs">
  <div><span class="name">NumPy</span><span class="ver">any version</span></div>
  <div><span class="name">SciPy</span><span class="ver">2.0 and later</span></div>
</div>

<div v-click class="punch">No Fortran code left</div>

<style>
.pkgs {
  display: flex;
  justify-content: center;
  gap: 5rem;
  margin-top: 2.5rem;
}
.pkgs > div {
  display: flex;
  flex-direction: column;
  align-items: center;
}
.name {
  font-size: 5rem;
  font-weight: 700;
  line-height: 1;
}
.ver {
  margin-top: 0.75rem;
  font-size: 1.5rem;
  opacity: 0.6;
}
.punch {
  margin-top: 3.5rem;
  font-size: 2.75rem;
  font-weight: 600;
}
</style>

<!--
Now this is the slide I want you to take away if nothing else...

[click] Starting from SciPy 2.0, and in any version of NumPy, there will be no Fortran code left in it.
-->

---



<div class="legend-quote">
  “NumPy is just a <span v-mark.crossed-off="{ color: '#bf616a' }">wrapper around Fortran</span>”
</div>

- Click on [numpy/numpy](https://github.com/numpy/numpy) and see it for yourself
- The tiny bit of Fortran is for **f2py**, binding **your** Fortran code to Python
- While you are there, observe the mountain of C and C++


<style>
.legend-quote {
  margin: 2.5rem 0 3rem;
  font-size: 2.25rem;
  font-style: italic;
}
</style>

<!--
NumPy never had it, but there is this urban legend of "NumPy is just a wrapper around Fortran".

I don't understand where it comes from. Just click on NumPy on GitHub and see it for yourself.

The tiny bit of Fortran is there for your Fortran code to be linked to Python through the amazing but aging tool f2py.
-->

---
layout: fact
---

### But SciPy had it

# 25%

of SciPy was Fortran 77

(Around 150K LOC, 90K SLOC)

<div v-click class="mt-10 text-xl opacity-70">Now it is, C, C++, and Cython</div>

<!--
But SciPy had a lot of F77. It had a lot; around a quarter of SciPy was F77, and it was a lot of pain to maintain for various reasons.

At some point I was the one who got annoyed the most, and translated everything.
-->

---

# Language Breakdown

<div class="flex justify-center items-center gap-12 mt-16">
  <TabFigure src="/figures/lang_breakdown_then.png" label="SciPy Then" class="w-120" />
  <TabFigure src="/figures/lang_breakdown_now.png" label="SciPy Now" class="w-120" />
</div>

<!--
It was like on the left, now it looks like on the right.
-->

---

# Laundry List [\#18566](https://github.com/scipy/scipy/issues/18566)

![Issue 18566](/figures/Issue18566.png){.absolute .top-0 .right-14 .w-85}

<v-clicks>

![Musing](/figures/musing.png){.w-120}

Took 2 years and 7 months (3-4 h per week average).

Started with ones I know about.

Notorious ones such as ARPACK, ODEPACK.

![Comment](/figures/fp_in_2010.png){.w-120}

</v-clicks>

---

# “You're holding it wrong”

<div class="grid grid-cols-2 gap-10 mt-12">
  <div class="card">
    <div class="who">Fortran users, on decades of well-documented issues</div>
    <div class="what">“They are not real scientists. Nuclear, weather, some obscure science thing”</div>
  </div>
  <div v-click class="card">
    <div class="who">C++ users, on decades of well-documented issues</div>
    <div class="what">“C++ is not for noobs but for pros, fintech, games, some mission critical thing”</div>
  </div>
</div>

<div v-click class="sutter">
  “Last time we did not do it properly, but this time we did it. For real this time.”
  <div class="who mt-2">Herb Sutter, every few years (paraphrased)</div>
</div>

<style>
.card {
  padding: 1.5rem;
  border-radius: 0.75rem;
  background: var(--slidev-bg-alt);
}
.who {
  font-size: 0.95rem;
  opacity: 0.6;
}
.what {
  margin-top: 0.75rem;
  font-size: 1.75rem;
  font-weight: 600;
}
.sutter {
  margin-top: 3rem;
  font-size: 1.5rem;
  font-style: italic;
}
.sutter .who {
  font-style: normal;
}
</style>

<!--
But we have been having a lot of issues for decades now, and this is very well documented. So the typical Fortran-user brush-off, "they are not real scientists",

[click] is exactly how C++ folks blame their users for not using it correctly, which is never going to be not funny.

[click] I have been listening to it since the 2000s. Every time, Herb Sutter comes out: "last time we did not do it properly, but this time we did it, for real this time".
-->

---
layout: fact
---

# It is not about FORTRAN

<v-clicks>

If you like FORTRAN, great keep using it. You do you.

Programming languages play tiny role in performance.

</v-clicks>


<!--
Now when I say that, Fortran users are an emotional bunch, and they immediately start reminising about Cray computers, PDP11 or whatever and the good olden days.

This work has nothing to do with Fortran, and if you like Fortran, keep using it. HPC this, nuclear submarines that, meteorology etc. these are not relevant arguments.

-->

---

# The problems, in three categories

<v-clicks>

1. The toolchain needs a lot of work
2. The code needs a lot of work
3. Testing needs huge amount of work

</v-clicks>

<style>
ol {
  margin-top: 3rem;
  font-size: 2rem;
  line-height: 2;
}
</style>

<!--
So anyways, the code problems were basically in three categories:

One, the toolchain needs a lot of work.

Two, the code needs a lot of work.

Three, the code does not allow for changes because there are no tests.
-->

---

# How FORTRAN sneaks in

<!-- The software stack, bottom to top. Grid auto-placement: NumPy spans two rows so it reaches down to BLAS, beside LAPACK. -->
<div class="stack grid grid-cols-[1fr_2fr] gap-1.5 w-180 mx-auto mt-8">
  <div class="col-span-2">scikit-learn · scikit-image · statsmodels · …</div>
  <div class="row-span-2">NumPy</div>
  <div>SciPy</div>
  <div class="lapack"><span>LAPACK <small>314k lines of FORTRAN 77</small></span></div>
  <div class="col-span-2"><span>Optimized BLAS <small>C + Assembly</small></span></div>
  <div class="col-span-2">OS</div>
</div>

<style>
.stack > div {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0.6rem;
  border: 2px solid var(--frost2);
  border-radius: 0.375rem;
  background: var(--slidev-bg-alt);
  font-size: 1.25rem;
}
.stack small {
  margin-left: 0.6em;
  font-size: 0.8rem;
  opacity: 0.75;
}
/* The one block that is still Fortran */
.stack > .lapack {
  border-color: var(--red);
  background: repeating-linear-gradient(-45deg, var(--red) 0 2px, transparent 2px 10px);
}
.stack > .lapack > span {
  padding: 0.1em 0.6em;
  border-radius: 0.25rem;
  background: var(--slidev-bg); /* keeps the label readable over the hatching */
}
</style>

---

# Well, until now...


<div class="flex justify-center items-center gap-12 mt-6">

![Semicolon-Lapack](/figures/semicolon-lapack.png){.h-100}

![Semicolon-Lapack-docs](/figures/semicolon-lapack-docs.png){.h-100}

</div>

<!--
I could not resist the temptation and also now we have LLMs to do the much of the dirty work so here is a C implementation of the entire LAPACK. All NumPy, SciPy and other scikit test suites are now passing. The performance is identical or faster.
-->

---

# Unclog the pipe, the flow restarts

<v-clicks>

 1. [scipy/xsf](https://github.com/scipy/xsf)
 2. Free-threading and CPython
 3. Pyodide

</v-clicks>
---

# BLAS and LAPACK



---

# Row-major, column-major

<div class="grid grid-cols-2 gap-12 mt-8 text-center">
<div>

### Row-major

C, NumPy default {.opacity-60}

<MemoryOrder order="C" class="mt-6" />

`a.strides == (24, 8)` {.mt-6}

</div>
<div v-click>

### Column-major

Fortran, LAPACK {.opacity-60}

<MemoryOrder order="F" class="mt-6" />

`a.strides == (8, 24)` {.mt-6}

</div>
</div>

<!--
A quick refresher, since most of you know this already. Memory is one long line, so a matrix has to be laid out in it somehow.

Row-major puts each row after the other; that's C and NumPy's default.

[click] Column-major puts each column after the other; that's Fortran, and hence LAPACK. Same matrix, different neighbours.
-->

---
clicks: 2
---

# Rank-1 Update

This is basically the bartender problem; say you want to make 9 Negronis. Do you go

<!-- Each entry of C is a glass, k is the ingredient. Click 1 pours the left one, click 2 the right one. -->
<div class="grid grid-cols-2 gap-12 mt-2 text-center">
<div>

(Gin, Campari, Vermouth) × 9

<PourOrder order="dot" :play="$clicks >= 1" class="w-60 mx-auto" />

</div>
<div>

Gin × 9, Campari × 9, Vermouth × 9

<PourOrder order="outer" :play="$clicks >= 2" class="w-60 mx-auto" />

</div>
</div>

<!--
Making 9 Negronis is a 3×3 matrix product: each glass is an entry of C, and the three ingredients are the k index.

[click] Glass by glass: pick up the gin, pour, put it down, Campari, pour, vermouth, pour, next glass. That is the dot product, row of A times column of B. 27 pours, 27 bottle pickups.

[click] Bottle by bottle: gin into all nine glasses, then Campari, then vermouth. The same 27 pours, but only 3 pickups. Each bottle is a rank-1 update: a column of A times a row of B, poured into every entry of C.

The catch: all nine glasses have to stand on the bar at once. That is the C tile living in registers.
-->


---
layout: image-right
image: /figures/traydispenser.jpg
---

# Caches, IKEA style

<v-clicks>

- The CPU keeps recently used memory close by, in caches: L1, L2, L3
- A cache holds trays, never single plates
- Tray = cache line = 64 B = 8 doubles

</v-clicks>

<!-- Bottom of the text half: the photo's own corner is taken by the dispenser's wheel -->
<a href="https://www.elakeside.com/foodservice/products/dispensing/tray-dispensers/" class="absolute bottom-2 left-14 text-[0.6rem] opacity-70">Photo: elakeside.com/foodservice/products/dispensing/tray-dispensers</a>

<!--
Memory is far away, so the CPU keeps what it recently used close by, in caches.

[click] Think of the tray racks in the canteen. The rack holds trays; you never put a single plate on it.

[click] A tray is a cache line. Ask for one double and you get the whole tray of eight.
-->

---

# Relative memory access speeds (Clickable Squares)

<!-- Interactive: click cells with the mouse, on the screen the audience sees. Slidev's own clicks don't drive it. -->
<CacheLatency class="mt-4" />

<div class="absolute bottom-2 right-4 text-right text-[0.6rem] leading-tight opacity-70">
  After Tony Albrecht, “Relative Memory Access speeds (Lesson 3)”, overbyte.com.au, 2014<br>
  <a href="https://web.archive.org/web/20140402225836/http://www.overbyte.com.au/misc/Lesson3/CacheFun.html">web.archive.org/web/20140402225836/http://www.overbyte.com.au/misc/Lesson3/CacheFun.html</a>
</div>

<!--
This is a rebuild of a lovely demo by Tony Albrecht from Overbyte. One cycle here is one frame of animation.

Loading from L1: four cycles. From L2: thirty. And from memory... we wait. Six hundred cycles.

On its way the value was copied into L2 and L1. Click its copy in L1: four cycles again.
-->

---

# Matrix multiplication cuts across the grain

$$
C_{ij} = \sum_k A_{ik}\, B_{kj}
$$

<!-- Both matrices are row-major, so the grain runs left to right in both. The arrow is the walk along k.
     On the first click B turns a quarter turn, so its walk lines up with A's and its grain stands across it. -->
<div class="flex justify-center gap-20 mt-6">
  <div class="flex flex-col items-center">
    <div class="relative">
      <img src="/figures/AccentWall.jpg" class="w-56 h-56 object-cover rounded">
      <ph-arrow-right-bold class="absolute inset-0 m-auto text-7xl text-white" />
    </div>
    <div class="mt-3 text-lg">row <em>i</em> of A</div>
  </div>
  <div class="flex flex-col items-center">
    <div class="relative transition-transform duration-1000" :class="$clicks >= 1 ? '-rotate-90' : 'rotate-0'">
      <img src="/figures/AccentWall.jpg" class="w-56 h-56 object-cover rounded">
      <ph-arrow-down-bold class="absolute inset-0 m-auto text-7xl text-white" />
    </div>
    <div class="mt-3 text-lg">column <em>j</em> of B</div>
  </div>
</div>

<div v-click="2" class="mt-8 text-center text-xl">Row-major or column-major, one of them always goes against the grain</div>

<a href="https://realcraft.com/products/lexington-reclaimed-barnwood-planks" class="absolute bottom-2 right-4 text-[0.6rem] opacity-70">Photo: realcraft.com/products/lexington-reclaimed-barnwood-planks</a>

<!--
Now the matrix multiplication. Each entry of C is a row of A times a column of B. With row-major storage, the row of A is along the grain.

[click] But the column of B, if you line it up with the row of A, looks like this. Every step in k lands on a new cache line.

[click] And switching to column-major only swaps the roles. One of them is always against the grain.
-->

---

# GOTO mechanism

<!-- The code's line highlights make the clicks; the diagram follows them through $clicks -->
<div class="grid grid-cols-[max-content_1fr] gap-8 items-center mt-2">

```c {all|1|2-3|4-5|6|7-8}
for (jc = 0; jc < n; jc += NC)
  for (pc = 0; pc < k; pc += KC) {
    Bp = pack(B[pc:pc+KC, jc:jc+NC]);
    for (ic = 0; ic < m; ic += MC) {
      Ap = pack(A[ic:ic+MC, pc:pc+KC]);
      for (jr = 0; jr < NC; jr += NR)
        for (ir = 0; ir < MC; ir += MR)
          kernel(Ap[ir], Bp[jr], C[ic+ir, jc+jr]);
    }
  }
```

<GotoLoops :step="$clicks" />

</div>

<div class="absolute bottom-2 right-4 text-right text-[0.6rem] leading-tight opacity-70">
  After K. Goto, R. van de Geijn, “Anatomy of High-Performance Matrix Multiplication”, ACM TOMS 34(3), 2008<br>
  and F. Van Zee, R. van de Geijn, “BLIS: A Framework for Rapidly Instantiating BLAS Functionality”, ACM TOMS 41(3), 2015
</div>

<!--
Goto's idea: chop the multiplication so that every piece fits one level of the memory hierarchy.

[click] First a column panel of B and C.

[click] Then a slice of it, KC rows of B, copied, packed, so it sits in L3.

[click] A block of A, packed, sits in L2.

[click] A thin sliver of the packed B fits in L1.

[click] And a tiny tile of C stays in registers for the whole computation.
-->

---

# The micro-kernel: rank-1 updates

<div class="grid grid-cols-[auto_1fr] gap-10 items-center mt-6">

<RankOneUpdate :step="$clicks" class="w-100" />

<div>

<v-clicks>

- One update: a column of Ap times a row of Bp
- 6 + 8 = 14 numbers loaded, 6 × 8 = 48 multiply-adds
- The C tile never leaves the registers
- Packing puts Ap and Bp in the order the kernel reads them: along the grain

</v-clicks>

</div>
</div>

<!--
Inside the kernel, the C tile sits in registers.

[click] Each step multiplies a column of the A sliver by a row of the B sliver: a rank-1 update, an outer product.

[click] Fourteen numbers in, forty-eight multiply-adds out. And it repeats KC times.

[click] C never goes back to memory until the end.

[click] And because Ap and Bp were packed, each step reads the next numbers in memory. No more cutting across the grain.
-->

---

# Why every level keeps up

| Level     | Holds             | Size       | Reused            | Sends out    |
| --------- | ----------------- | ---------- | ----------------- | ------------ |
| Registers | C tile, MR × NR   | 48 doubles | KC = 256 times    | —            |
| L1        | Bp sliver, KC × NR | 16 KB      | MC / MR = 12 times | 19 B / cycle |
| L2        | Ap, MC × KC       | 144 KB     | NC / NR = 510 times | 8 B / cycle  |
| L3        | Bp, KC × NC       | 8 MB       | m / MC times      | < 1 B / cycle |

<div class="mt-8">
<v-clicks>

- Where a block lives: how long until it is used again
- Whether that level keeps up: how many multiply-adds each number pays for

</v-clicks>
</div>

<div class="absolute bottom-2 right-4 text-[0.6rem] opacity-70">
  BLIS double precision on Intel Haswell: MR = 6, NR = 8, KC = 256, MC = 72, NC = 4080, at 8 multiply-adds per cycle
</div>

<!--
So how does Ap, sitting in L2, keep up? Both slivers are in L1 during a kernel call. The Bp sliver stays, because it is needed again by the very next call; each Ap sliver just passes through, prefetched from L2 because it is read in order.

The numbers: L1 hands the kernel 6 + 8 doubles every 6 cycles, about 19 bytes per cycle, and Haswell's L1 can do 64. L2 sends Ap at 8 bytes per cycle, and it can do 64. L3 refills the Bp sliver at under a byte per cycle.

[click] So a block lives where it waits: the C tile is needed every update, the Bp sliver every call, Ap every sweep.

[click] And the level keeps up because every number it sends pays for many multiply-adds: NR of them for each number of Ap, MR for each number of Bp.
-->

---

# What is an Optimized BLAS

Each vendor does this chopping and cache aligning using their particular hardware

<div>

 - OpenBLAS (formerly GOTO Blas what Kazushige Goto started)
 - Intel MKL (has an optimized BLAS in it)
 - Accelerate Framework (has Apple specific BLAS)
 - BLIS
 - AOCL
 - RocM
 - ...

</div>

Every vendor provides a C/Assembly implementation to link to F77 LAPACK


---

# Reference vs optimized dgemm

<!-- Hover the plot for exact values -->
<GemmChart />

<div class="absolute bottom-2 right-4 text-[0.6rem] opacity-70">
  One core of an AMD Ryzen 9 9950X, single thread, double precision, measured November 2026.
  Reference: dgemm.f from LAPACK 3.12.1, GNU Fortran 16.2.1. OpenBLAS 0.3.33, MKL 2026.1.0.
</div>

<!--
The red and yellow lines are the reference dgemm, the Fortran code LAPACK ships with, on one core of my machine. While A fits in L2 it does about 20 GFLOPS, or 40 with every compiler flag. Once A outgrows L3 it falls to 7.

The blue lines are the optimized libraries on the same core. OpenBLAS doesn't care about the size at all. MKL sits lower here, most likely because on an AMD chip it doesn't pick its fastest code; the latest release, 2026.1, is no different.

At n = 4096 that is almost twenty times. Same core, same operation, same day.
-->

---

# What about fusing expressions?

Pairwise distances $\lVert x_i - y_j \rVert$, written the way anyone would:

```python
G = X @ Y.T                              # one BLAS call
D = np.sqrt(-2 * G + xx[:, None] + yy)   # xx, yy: squared row norms of X and Y
```

<div v-click class="mt-6">

**Line by line**, all a library can do: every step writes an $n \times m$ matrix and the next one reads it back

<FusionPipeline class="mt-3 mb-6" />

</div>
<div v-click>

**Fused**, what a compiler could do once it sees both lines

<FusionPipeline fused class="mt-3 mb-6" />

</div>

<div v-click class="mt-2 text-center">
  <div class="text-2xl font-600">Today, you are the compiler</div>
  <div class="mt-1 opacity-70">A library sees one call at a time. Only a compiler sees both lines.</div>
  <div class="mt-3 text-sm opacity-70">
    Same story: <code>A @ x</code> with <code>A.T @ y</code> (LSQR) · element-wise chains (numexpr) · <code>softmax(Q @ K.T) @ V</code> (FlashAttention, by hand)
  </div>
</div>

<!--
Pairwise distances; everyone here has written this. Two lines: a matrix product, then the norms and a square root.

[click] Line by line, that is all any library can do. The product writes an n by m matrix to memory, and every step after it reads the whole thing back and writes a new one, for work that is trivial.

[click] But if you see both lines at once, all of it can happen on the C tile while it is still in the registers, in the micro-kernel we just saw. G never exists, and D is written once.

[click] If only there were a technology that reads more than one line and finds a better way to run it... There is. It's called a compiler. A library only ever sees one call. So today, you are the compiler: you write that kernel by hand, or you don't get it. FlashAttention is exactly that: people hand-wrote a kernel for one expression. Same story for A x and A-transpose y in one pass, which BLIS even has inside but cannot expose, and for chains of element-wise operations.

That's why we need a lower-level language whose compiler can do this for us, instead of trying to influence the hardware from the outside through a gazillion different libraries. Finding the best fusion in general is NP-hard, but any improvement is an improvement.
-->


---
layout: center
---

<div class="flex flex-col items-center">

# Thank you

![QR code linking to these slides](/figures/slides-qr.svg){.w-64 .mt-6 .rounded-lg}

[ilayn.github.io/talks/2026ComputeParis](https://ilayn.github.io/talks/2026ComputeParis/) {.mt-4}

</div>

<!--
Thank you. The slides are online; the QR code takes you there. Happy to take questions.
-->
