.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb


.global vectors
.global reset_handler

@ Регистры управления тактирования
.equ RCC_BASE,		0x40023800
.equ RCC_AHB1RSTR,	(RCC_BASE + 0x10)
.equ RCC_AHB1ENR,	(RCC_BASE + 0x30)

.equ GPIOC_BASE,	0x40020800
.equ GPIOC_MODER,	(GPIOC_BASE + 0x00)
.equ GPIOC_OTYPER,	(GPIOC_BASE + 0x04)
.equ GPIOC_OSPEEDR,	(GPIOC_BASE + 0x08)
.equ GPIOC_PUPDR,	(GPIOC_BASE + 0x0C)
.equ GPIOC_IDR,		(GPIOC_BASE + 0x10)
.equ GPIOC_ODR,		(GPIOC_BASE + 0x14)
.equ GPIOC_BSSR,	(GPIOC_BASE + 0x18)
.equ GPIOC_LCKR,	(GPIOC_BASE + 0x1C)
.equ GPIOC_AFRL,	(GPIOC_BASE + 0x20)
.equ GPIOC_AFRH,	(GPIOC_BASE + 0x24)


.section .isr_vector,"a",%progbits
vectors:
	.word	_estack
	.word	reset_handler + 1		@ Reset_Handler
	.word	dummy_loop + 1	@ NMI_Handler
	.word	dummy_loop + 1	@HardFault_Handler
	.word	dummy_loop + 1	@MemManage_Handler
	.word	dummy_loop + 1	@BusFault_Handler
	.word	dummy_loop + 1	@UsageFault_Handler


.section .text,"ax",%progbits
dummy_loop:
	b dummy_loop


set_bit:
	@ orr r2 с регистром по адресу r1
	push {r5-r6}

	ldr r5, [r1]
	orr r5, r2
	str r5, [r1]

	pop {r5-r6}
	bx lr

delay:
	push {r1}

do_delay:
	subs r1, 1
	bne do_delay

	pop {r1}
	bx lr

reset_handler:
	@ Включаем тактирование GPIO C

	@ Загрузка периферийного регистра в регистр ЦПУ
	ldr r6, =RCC_AHB1ENR
	ldr r5, [r6]
	@ Выставка бита включаеющего тактирование GPIO
	orr r5, (1 << 2)
	@ Выгрузка из регистра ЦПУ в периферийный регистр
	str r5, [r6]

	@ Теперь настраиваем GPIOC пин 13
	@ Первоначально ставим ножку в единичку
	@ Еще до того как мы поставим её на output режим
	ldr r1, =GPIOC_ODR
	ldr r2, =(0b1 << 13)
	bl set_bit

	@ open drain
	ldr r1, =GPIOC_OTYPER
	ldr r2, =(0b1 << 13)
	bl set_bit

	@ Максимум скорости
	ldr r1, =GPIOC_OSPEEDR
	ldr r2, =(0b11 << (13*2))
	bl set_bit

	@ В самом конце - режим output
	ldr r1, =GPIOC_MODER
	ldr r2, =(0b01 << (13*2))
	bl set_bit

	@ Остальные регистры не трогаем

loop:
	@начинаем мигать
	@ Зажигаем лампочку
	ldr r7, =(0b1<<(13 + 16))
	ldr r6, =GPIOC_BSSR
	str r7, [r6]

	@ ждем
	ldr r1, =0x100000
	bl delay

	@ тушим лампочку
	ldr r7, =(0b1<<(13 + 0))
	ldr r6, =GPIOC_BSSR
	str r7, [r6]

	@ ждем
	ldr r1, =0x100000
	bl delay
	b loop
