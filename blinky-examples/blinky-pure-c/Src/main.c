/**
 ******************************************************************************
 * @file           : main.c
 * @author         : Auto-generated by STM32CubeIDE
 * @brief          : Main program body
 ******************************************************************************
 * @attention
 *
 * <h2><center>&copy; Copyright (c) 2021 STMicroelectronics.
 * All rights reserved.</center></h2>
 *
 * This software component is licensed by ST under BSD 3-Clause license,
 * the "License"; You may not use this file except in compliance with the
 * License. You may obtain a copy of the License at:
 *                        opensource.org/licenses/BSD-3-Clause
 *
 ******************************************************************************
 */

#include <stdint.h>

#define REGISTER_ADDR(x)   (volatile uint32_t*)(x)

#define RCC_BASE		(0x40023800)
#define RCC_AHB1RSTR	REGISTER_ADDR(RCC_BASE + 0x10)
#define RCC_AHB1ENR		REGISTER_ADDR(RCC_BASE + 0x30)

#define GPIOC_BASE		(0x40020800)
#define GPIOC_MODER		REGISTER_ADDR(GPIOC_BASE + 0x00)
#define GPIOC_OTYPER	REGISTER_ADDR(GPIOC_BASE + 0x04)
#define GPIOC_OSPEEDR	REGISTER_ADDR(GPIOC_BASE + 0x08)
#define GPIOC_PUPDR		REGISTER_ADDR(GPIOC_BASE + 0x0C)
#define GPIOC_IDR		REGISTER_ADDR(GPIOC_BASE + 0x10)
#define GPIOC_ODR		REGISTER_ADDR(GPIOC_BASE + 0x14)
#define GPIOC_BSSR		REGISTER_ADDR(GPIOC_BASE + 0x18)
#define GPIOC_LCKR		REGISTER_ADDR(GPIOC_BASE + 0x1C)
#define GPIOC_AFRL		REGISTER_ADDR(GPIOC_BASE + 0x20)
#define GPIOC_AFRH		REGISTER_ADDR(GPIOC_BASE + 0x24)


//! Инициализазция железа перед работой main
void SystemInit(void)
{
	// В нашем примере пустая
}


//! Задержка в сколько-то тактов
void delay(uint32_t how_much)
{
	/*volatile */uint32_t i;
	for (i = 0; i < how_much; i++)
	{}
}


int main(void)
{
	// Тактирование GPIOC
	*RCC_AHB1ENR |= (1 << 2);

	// пин 13 в единичку
	*GPIOC_ODR |= (1 << 13);

	// пин 13 на open drain
	*GPIOC_OTYPER |= (1 << 13);

	// пин 13 на максимальную скорость
	*GPIOC_OSPEEDR |= (3 << (13*2));

	// пин 13 на вывод
	*GPIOC_MODER |= (1 << (13*2));

	for(;;)
	{
		// Зажигаем лампочку (через ODR регистр для разнобразия)
		*GPIOC_ODR &= ~(1 << 13);

		// ждем
		delay(0x100000);

		// Тушим лампочку (через BSSE регистр для разнобразия)
		*GPIOC_BSSR |= (1 << 13);

		// ждем
		delay(0x100000);
	}
}