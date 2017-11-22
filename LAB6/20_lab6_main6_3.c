//These functions inside the asm file

#include "stm32l476xx.h"
#include <stdbool.h>

extern void GPIO_init();
extern void max7219_init();
extern void max7219_send(unsigned char address, unsigned char data);
extern void MAX7219re();
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
//bool use[4][4];
int before, calculating, tmp;
char now_op, bef_op, cal_op;
bool update;
/**
* TODO: Show data on 7-seg via max7219_send
* Input:
* data: decimal value
* num_digs: number of digits will show on 7-seg
* Return:
* 0: success
* -1: illegal data range(out of 8 digits range)
*/
void display(int data, int num_digs)
{
	char ch[8];
	int cnt = 0, i;
	int neg = 0;
	if(data == 0) {
		cnt = 1;
		ch[0] = '0';
	}
	if(data < 0) {
		neg = 1;
		data *= (-1);
	}
	while(data > 0 && cnt+neg < 8){
		ch[cnt] = data%10 + '0';
		cnt = cnt + 1;
		data = data/10;
	}
	if(data == 0){
		for(i = 0;i < cnt; ++i)
			max7219_send(i + 1, ch[i]);
		if(neg == 1)
			max7219_send(cnt+1,10);
		for(i = cnt+neg;i < 8; ++i)
			max7219_send(i+1, 15);
	}
	//return (cnt <= 8 && data == 0)?0: -1;
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
	int num[16] = {1,2,3,-1,4,5,6,-2,7,8,9,-3,-5,0,-6,-4};
	int flag, ans = -10;
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
					return num[j*4+i];
				}
			}
			//if(ans != -1) break;
		}
	}
	return ans;
	//return ans;
}
char convert_op(int a){
	if(a == -1) return '+';
	else if(a == -2) return '-';
	else if(a == -3) return '*';
	else if(a == -4) return '/';
	else if(a == -5) return '=';
	else return 'C';
}
void initial_var_op(){

	before = 0; //99999205;
	calculating = 0;
	tmp = 0;
	now_op = '+';
	bef_op = '+';
	cal_op = '+';
	update = false;
}
int op_do(int a, char x, int b){
	if(x == '+') return a + b;
	if(x == '-') return a - b;
	if(x == '*') return a * b;
	if(x == '/') return a / b;
	return a + b;
}
int main(void)
{
	//int i, student_id = 1234567;
	GPIO_init();
	max7219_init();
	keypad_init();
	//display(student_id, 8);
	// initial
	//for(i = 0;i < 16; ++i)
	//	use[i/4][i%4] = false;
	initial_var_op();
	//int show = 0;
	while(1){
		int input;
		input = keypad_scan();
		if(input == -10) continue;
		if (input < 0) {
			//show = 0;
			MAX7219re();
			now_op = convert_op(input);
			update = true;
			if(now_op == 'C'){
				initial_var_op();
				MAX7219re();
			}
			else if(now_op == '='){
				calculating = op_do(calculating, cal_op, tmp);
				before = op_do(before, bef_op, calculating);
				display(before, 8);
				initial_var_op();
			}
		}
		else {
			// operator confirmed
			if(update == true){
				if(now_op == '-' || now_op == '+'){
					calculating = op_do(calculating, cal_op, tmp);
					before = op_do(before, bef_op, calculating);
					calculating = 0;
					cal_op = '+';
					bef_op = now_op;
				}
				else if(now_op == '*' || now_op == '/'){
					calculating = op_do(calculating, cal_op, tmp);
					cal_op = now_op;
				}
				tmp = 0;
			}
			if(tmp*10 + input < 1000){
				tmp = tmp*10 + input;
				display(tmp, 8);
			}
			update = false;
		}
	}
	//display(student_id, 8);
}
