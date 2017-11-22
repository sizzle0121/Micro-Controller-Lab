//These functions inside the asm file

#include "stm32l476xx.h"

extern void GPIO_init();
extern void max7219_init();
extern void max7219_send(unsigned char address, unsigned char data);
//PA
#define X0 8
#define X1 9
#define X2 10
#define X3 12
//PB
#define Y0 5
#define Y1 6
#define Y2 7
#define Y3 9

unsigned int x_pin[4] = {X0, X1, X2, X3};
unsigned int y_pin[4] = {Y0, Y1, Y2, Y3};

/**
* TODO: Show data on 7-seg via max7219_send
* Input:
* data: decimal value
* num_digs: number of digits will show on 7-seg
* Return:
* 0: success
* -1: illegal data range(out of 8 digits range)
*/
int display(int data, int num_digs)
{
	char ch[8];
	int cnt = 0, i;
	if(data == 0) {
		cnt = 1;
		ch[0] = '0';
	}
	while(data > 0 && cnt < 8){
		ch[cnt] = data%10 + '0';
		cnt = cnt + 1;
		data = data/10;
	}
	if(data == 0){
		for(i = 0;i < cnt; ++i)
			max7219_send(i + 1, ch[i]);
		for(i = cnt;i < 8; ++i)
			max7219_send(i+1, 15);
	}
	return (cnt <= 8 && data == 0)?0: -1;
}

void keypad_init()
{

	// SET keypad gpio OUTPUT //
	RCC->AHB2ENR = RCC->AHB2ENR|0x3;

	//Set PA8,9,10,12 as output mode
	GPIOA->MODER= GPIOA->MODER&0xFDD5FFFF;
	//set PA8,9,10,12 is Pull-up output
	GPIOA->PUPDR=GPIOA->PUPDR|0x1150000;
	//Set PA8,9,10,12 as medium speed mode
	GPIOA->OSPEEDR=GPIOA->OSPEEDR|0x1150000;
	//Set PA8,9,10,12 as high
	GPIOA->ODR=GPIOA->ODR|10111<<8;
	// SET keypad gpio INPUT //

	//Set PB5,6,7,9 as INPUT mode
	GPIOB->MODER=GPIOB->MODER&0xFFF303FF;
	//set PB5,6,7,9 is Pull-down input
	GPIOB->PUPDR=GPIOB->PUPDR|0x8A800;
	//Set PB5,6,7,9 as medium speed mode
	GPIOB->OSPEEDR=GPIOB->OSPEEDR|0x45400;
}
int keypad_scan(){
	GPIOA->ODR=GPIOA->ODR|10111<<8; // don't know why, but i need u
	int num[16] = {1,2,3,10,4,5,6,11,7,8,9,12,15,0,14,13};
	int flag, ans = -1;
	flag = GPIOB->IDR&(10111<<5);
	if(flag != 0){
		int debounce = 45000;
		while(debounce > 0){
			flag = GPIOB->IDR&(10111<<5);
			debounce--;
		}
	}
	if(flag != 0){
		int i, j, key_pad_read = 0;
		for(i = 0;i < 4; ++i){
			GPIOA->ODR=(GPIOA->ODR&0xFFFFE8FF)|1<<x_pin[i];
			for(j = 0;j < 4; ++j){
				key_pad_read = GPIOB->IDR& (1<<y_pin[j]);
				if(key_pad_read != 0){
					ans = num[j*4+i];
					//break;
				}
			}
			//if(ans != -1) break;
		}
	}
	return ans;
}
int main(void)
{
	int student_id = 1234567;
	GPIO_init();
	max7219_init();
	keypad_init();
	display(student_id, 8);
	while(1){
		int val = keypad_scan();
		int dig = (val >= 10)?2:1;
		if(val != -1)
			display(val,dig);
		//keypad_init();
	}
	//display(student_id, 8);
}
