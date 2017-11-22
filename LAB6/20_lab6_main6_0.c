//These functions inside the asm file
extern void GPIO_init();
extern void max7219_init();
extern void max7219_send(unsigned char address, unsigned char data);
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
	while(data > 0 && cnt < 8){
		ch[cnt] = data%10 + '0';
		cnt = cnt + 1;
		data = data/10;
	}
	if(data == 0){
		for(i = 0;i < cnt; ++i)
			max7219_send(i + 1, ch[i]);
	}
	return (cnt <= 8 && data == 0)?0: -1;
}
int main(void)
{
	int student_id = 1234567;
	GPIO_init();
	max7219_init();
	display(student_id, 8);
}
