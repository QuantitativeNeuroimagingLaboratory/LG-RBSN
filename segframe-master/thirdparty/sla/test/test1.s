	.file	"test1.c"
# GNU C (Ubuntu/Linaro 4.6.3-1ubuntu5) version 4.6.3 (x86_64-linux-gnu)
#	compiled by GNU C version 4.6.3, GMP version 5.0.2, MPFR version 3.1.0-p3, MPC version 0.9
# GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
# options passed:  -imultilib . -imultiarch x86_64-linux-gnu -D_REENTRANT
# test1.c -mavx -mtune=generic -march=x86-64 -O3 -std=c99 -fverbose-asm
# -fopenmp -fstack-protector
# options enabled:  -fasynchronous-unwind-tables -fauto-inc-dec
# -fbranch-count-reg -fcaller-saves -fcombine-stack-adjustments -fcommon
# -fcompare-elim -fcprop-registers -fcrossjumping -fcse-follow-jumps
# -fdefer-pop -fdelete-null-pointer-checks -fdevirtualize -fdwarf2-cfi-asm
# -fearly-inlining -feliminate-unused-debug-types -fexpensive-optimizations
# -fforward-propagate -ffunction-cse -fgcse -fgcse-after-reload -fgcse-lm
# -fguess-branch-probability -fident -fif-conversion -fif-conversion2
# -findirect-inlining -finline -finline-functions
# -finline-functions-called-once -finline-small-functions -fipa-cp
# -fipa-cp-clone -fipa-profile -fipa-pure-const -fipa-reference -fipa-sra
# -fira-share-save-slots -fira-share-spill-slots -fivopts
# -fkeep-static-consts -fleading-underscore -fmath-errno -fmerge-constants
# -fmerge-debug-strings -fmove-loop-invariants -fomit-frame-pointer
# -foptimize-register-move -foptimize-sibling-calls -fpartial-inlining
# -fpeephole -fpeephole2 -fpredictive-commoning -fprefetch-loop-arrays
# -freg-struct-return -fregmove -freorder-blocks -freorder-functions
# -frerun-cse-after-loop -fsched-critical-path-heuristic
# -fsched-dep-count-heuristic -fsched-group-heuristic -fsched-interblock
# -fsched-last-insn-heuristic -fsched-rank-heuristic -fsched-spec
# -fsched-spec-insn-heuristic -fsched-stalled-insns-dep -fschedule-insns2
# -fshow-column -fsigned-zeros -fsplit-ivs-in-unroller -fsplit-wide-types
# -fstack-protector -fstrict-aliasing -fstrict-overflow
# -fstrict-volatile-bitfields -fthread-jumps -ftoplevel-reorder
# -ftrapping-math -ftree-bit-ccp -ftree-builtin-call-dce -ftree-ccp
# -ftree-ch -ftree-copy-prop -ftree-copyrename -ftree-cselim -ftree-dce
# -ftree-dominator-opts -ftree-dse -ftree-forwprop -ftree-fre
# -ftree-loop-distribute-patterns -ftree-loop-if-convert -ftree-loop-im
# -ftree-loop-ivcanon -ftree-loop-optimize -ftree-parallelize-loops=
# -ftree-phiprop -ftree-pre -ftree-pta -ftree-reassoc -ftree-scev-cprop
# -ftree-sink -ftree-slp-vectorize -ftree-sra -ftree-switch-conversion
# -ftree-ter -ftree-vect-loop-version -ftree-vectorize -ftree-vrp
# -funit-at-a-time -funswitch-loops -funwind-tables -fvect-cost-model
# -fverbose-asm -fzee -fzero-initialized-in-bss -m128bit-long-double -m64
# -m80387 -maccumulate-outgoing-args -malign-stringops -mavx
# -mavx256-split-unaligned-load -mavx256-split-unaligned-store
# -mfancy-math-387 -mfp-ret-in-387 -mglibc -mieee-fp -mmmx -mpopcnt
# -mpush-args -mred-zone -msse -msse2 -msse3 -msse4 -msse4.1 -msse4.2
# -mssse3 -mtls-direct-seg-refs -mvzeroupper

# Compiler executable checksum: 75e879ed14f91af504f4150eadeaa0e6

	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"usage: test1 N\n"
.LC1:
	.string	"running with N=%d\n"
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC10:
	.string	"%f, %f, %f, %f (%e s./iteration)\n"
	.section	.text.startup,"ax",@progbits
	.p2align 4,,15
	.globl	main
	.type	main, @function
main:
.LFB22:
	.cfi_startproc
	pushq	%rbp	#
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp	#,
	.cfi_def_cfa_register 6
	pushq	%rbx	#
	andq	$-64, %rsp	#,
	subq	$512, %rsp	#,
	cmpl	$2, %edi	#, argc
	jne	.L10	#,
	.cfi_offset 3, -24
	movq	8(%rsi), %rdi	# MEM[(char * *)argv_5(D) + 8B], MEM[(char * *)argv_5(D) + 8B]
	movl	$10, %edx	#,
	xorl	%esi, %esi	#
	call	strtol	#
	movl	$.LC1, %esi	#,
	movl	%eax, %ebx	# D.2555, N
	movl	%eax, %edx	# D.2555,
	movl	$1, %edi	#,
	xorl	%eax, %eax	#
	call	__printf_chk	#
	movl	$0x3f800000, 464(%rsp)	#, fa.f
	movl	$0x40000000, 468(%rsp)	#, fa.f
	movl	$0x40400000, 472(%rsp)	#, fa.f
	movl	$0x40800000, 476(%rsp)	#, fa.f
	vmovaps	464(%rsp), %xmm1	# fa.v, prephitmp.10
	movl	$0x40a00000, 480(%rsp)	#, fb.f
	movl	$0x40c00000, 484(%rsp)	#, fb.f
	movl	$0x40e00000, 488(%rsp)	#, fb.f
	movl	$0x41000000, 492(%rsp)	#, fb.f
	vmovaps	%xmm1, 496(%rsp)	# prephitmp.10, fc.v
	vmovaps	%xmm1, (%rsp)	#,
	call	omp_get_wtime	#
	testl	%ebx, %ebx	# N
	vmovsd	%xmm0, 56(%rsp)	#, %sfp
	vmovaps	(%rsp), %xmm1	#,
	jle	.L3	#,
	vmovaps	480(%rsp), %xmm0	# fb.v, pretmp.9
	xorl	%eax, %eax	# i
	.p2align 4,,10
	.p2align 3
.L4:
	addl	$1, %eax	#, i
	vaddps	%xmm0, %xmm1, %xmm1	# pretmp.9, prephitmp.10, prephitmp.10
	cmpl	%ebx, %eax	# N, i
	jl	.L4	#,
	vmovaps	%xmm1, 496(%rsp)	# prephitmp.10, fc.v
.L3:
	call	omp_get_wtime	#
	vcvtsi2sd	%ebx, %xmm1, %xmm1	# N,
	vsubsd	56(%rsp), %xmm0, %xmm4	# %sfp, ft1, tmp112
	vmovss	508(%rsp), %xmm3	# fc.f,
	vmovss	496(%rsp), %xmm0	# fc.f, tmp117
	movl	$.LC10, %esi	#,
	vmovss	504(%rsp), %xmm2	# fc.f,
	movl	$1, %edi	#,
	movl	$5, %eax	#,
	vcvtps2pd	%xmm0, %xmm0	# tmp117, tmp117
	vcvtps2pd	%xmm3, %xmm3	#,
	vcvtps2pd	%xmm2, %xmm2	#,
	vdivsd	%xmm1, %xmm4, %xmm4	#, tmp112,
	vmovsd	%xmm1, 48(%rsp)	#, %sfp
	vmovss	500(%rsp), %xmm1	# fc.f,
	vcvtps2pd	%xmm1, %xmm1	#,
	call	__printf_chk	#
	movabsq	$4607182418800017408, %rax	#,
	movabsq	$4611686018427387904, %rdx	#,
	movabsq	$4613937818241073152, %rcx	#,
	movabsq	$4616189618054758400, %rsi	#,
	movq	%rax, 128(%rsp)	#, da.f
	movq	%rdx, 136(%rsp)	#, da.f
	movq	184(%rsp), %rax	# da.v, da.v
	movq	176(%rsp), %rdx	# da.v, da.v
	movabsq	$4617315517961601024, %rdi	#,
	movq	%rcx, 144(%rsp)	#, da.f
	movq	%rsi, 152(%rsp)	#, da.f
	movabsq	$4618441417868443648, %r8	#,
	movq	160(%rsp), %rsi	# da.v, da.v
	movq	168(%rsp), %rcx	# da.v, da.v
	movabsq	$4619567317775286272, %r9	#,
	movabsq	$4620693217682128896, %r10	#,
	movq	%rdi, 192(%rsp)	#, db.f
	movq	%r8, 200(%rsp)	#, db.f
	movabsq	$4616189618054758400, %rdi	#, da.v
	movabsq	$4613937818241073152, %r8	#, da.v
	movq	%r9, 208(%rsp)	#, db.f
	movq	%r10, 216(%rsp)	#, db.f
	movabsq	$4611686018427387904, %r9	#, da.v
	movabsq	$4607182418800017408, %r10	#, da.v
	movq	%r10, 320(%rsp)	# da.v, prephitmp.5
	movq	%r9, 328(%rsp)	# da.v, prephitmp.5
	movq	%r8, 336(%rsp)	# da.v, prephitmp.5
	movq	%rdi, 344(%rsp)	# da.v, prephitmp.5
	movq	%rsi, 352(%rsp)	# da.v, prephitmp.5
	movq	%rcx, 360(%rsp)	# da.v, prephitmp.5
	movq	%rdx, 368(%rsp)	# da.v, prephitmp.5
	movq	%rax, 376(%rsp)	# da.v, prephitmp.5
	movq	%r10, 256(%rsp)	# da.v, dc.v
	movq	%r9, 264(%rsp)	# da.v, dc.v
	movq	%r8, 272(%rsp)	# da.v, dc.v
	movq	%rdi, 280(%rsp)	# da.v, dc.v
	movq	%rsi, 288(%rsp)	# da.v, dc.v
	movq	%rcx, 296(%rsp)	# da.v, dc.v
	movq	%rdx, 304(%rsp)	# da.v, dc.v
	movq	%rax, 312(%rsp)	# da.v, dc.v
	call	omp_get_wtime	#
	testl	%ebx, %ebx	# N
	vmovsd	%xmm0, 56(%rsp)	#, %sfp
	jle	.L5	#,
	movq	192(%rsp), %rax	# db.v, db.v
	movq	%rax, 384(%rsp)	# db.v, pretmp.4
	movq	200(%rsp), %rax	# db.v, db.v
	movq	%rax, 392(%rsp)	# db.v, pretmp.4
	movq	208(%rsp), %rax	# db.v, db.v
	movq	%rax, 400(%rsp)	# db.v, pretmp.4
	movq	216(%rsp), %rax	# db.v, db.v
	movq	%rax, 408(%rsp)	# db.v, pretmp.4
	movq	224(%rsp), %rax	# db.v, db.v
	vmovaps	384(%rsp), %ymm3	#, pretmp.7
	movq	%rax, 416(%rsp)	# db.v, pretmp.4
	movq	232(%rsp), %rax	# db.v, db.v
	movq	%rax, 424(%rsp)	# db.v, pretmp.4
	movq	240(%rsp), %rax	# db.v, db.v
	movq	%rax, 432(%rsp)	# db.v, pretmp.4
	movq	248(%rsp), %rax	# db.v, db.v
	movq	%rax, 440(%rsp)	# db.v, pretmp.4
	xorl	%eax, %eax	# i
	vmovaps	416(%rsp), %ymm2	#, pretmp.7
	.p2align 4,,10
	.p2align 3
.L6:
	vaddps	320(%rsp), %ymm3, %ymm1	#, pretmp.7, D.2546
	addl	$1, %eax	#, i
	cmpl	%ebx, %eax	# N, i
	vaddps	352(%rsp), %ymm2, %ymm0	#, pretmp.7, D.2549
	vmovaps	%ymm1, 64(%rsp)	# D.2546,
	movq	64(%rsp), %r11	#, tmp150
	movq	72(%rsp), %r10	#, tmp151
	movq	80(%rsp), %r9	#, tmp152
	movq	88(%rsp), %r8	#, tmp153
	vmovaps	%ymm0, 96(%rsp)	# D.2549,
	movq	96(%rsp), %rdi	#, tmp154
	movq	104(%rsp), %rsi	#, tmp155
	movq	112(%rsp), %rcx	#, tmp156
	movq	120(%rsp), %rdx	#, tmp157
	movq	%r11, 320(%rsp)	# tmp150, prephitmp.5
	movq	%r10, 328(%rsp)	# tmp151, prephitmp.5
	movq	%r9, 336(%rsp)	# tmp152, prephitmp.5
	movq	%r8, 344(%rsp)	# tmp153, prephitmp.5
	movq	%rdi, 352(%rsp)	# tmp154, prephitmp.5
	movq	%rsi, 360(%rsp)	# tmp155, prephitmp.5
	movq	%rcx, 368(%rsp)	# tmp156, prephitmp.5
	movq	%rdx, 376(%rsp)	# tmp157, prephitmp.5
	jl	.L6	#,
	movq	%r11, 256(%rsp)	# tmp150, dc.v
	movq	%r10, 264(%rsp)	# tmp151, dc.v
	movq	%r9, 272(%rsp)	# tmp152, dc.v
	movq	%r8, 280(%rsp)	# tmp153, dc.v
	movq	%rdi, 288(%rsp)	# tmp154, dc.v
	movq	%rsi, 296(%rsp)	# tmp155, dc.v
	movq	%rcx, 304(%rsp)	# tmp156, dc.v
	movq	%rdx, 312(%rsp)	# tmp157, dc.v
.L5:
	vzeroupper
	call	omp_get_wtime	#
	vsubsd	56(%rsp), %xmm0, %xmm4	# %sfp, dt1, tmp166
	vmovsd	280(%rsp), %xmm3	# dc.f,
	vmovsd	272(%rsp), %xmm2	# dc.f,
	movl	$.LC10, %esi	#,
	vmovsd	264(%rsp), %xmm1	# dc.f,
	movl	$1, %edi	#,
	vmovsd	256(%rsp), %xmm0	# dc.f,
	movl	$5, %eax	#,
	vdivsd	48(%rsp), %xmm4, %xmm4	# %sfp, tmp166,
	call	__printf_chk	#
	movq	-8(%rbp), %rbx	#,
	leave
	.cfi_remember_state
	.cfi_def_cfa 7, 8
	xorl	%eax, %eax	#
	ret
.L10:
	.cfi_restore_state
	movl	$.LC0, %esi	#,
	movl	$1, %edi	#,
	xorl	%eax, %eax	#
	call	__printf_chk	#
	movl	$1, %edi	#,
	call	exit	#
	.cfi_endproc
.LFE22:
	.size	main, .-main
	.ident	"GCC: (Ubuntu/Linaro 4.6.3-1ubuntu5) 4.6.3"
	.section	.note.GNU-stack,"",@progbits
