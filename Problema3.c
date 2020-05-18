#include <stdio.h>
#include <conio.h>
#include <math.h> 
#include <stdlib.h>
int expoente(int base, int expo){//função para calcular o expoente
	int pot=base;//variavel de retorno
	if (expo == 0) {//se o expoente for zero
		pot = 1;// valor da potencia eh 1
	}
	else {//se não for zero
		for (int i = 1; i < expo; i++) {
			pot = pot*base;// multiplicando o numero por ele mesmo varias vezes
		}
	}
	return pot;// retorna a potencia
}

int main (void){
	int b;//variavel base
	int n;//variavel logaritmando
	int num = 0;//variavel para o expoente
	printf("digite o valor da base: ");
	scanf("%d", &b);//pegando o valor da variavel base
	printf("digite o valor de N: ");
	scanf("%d", &n);//pegando o valor da variavel N
	int y = expoente(b, num);//chamando a função para calcular o expoente
	while (y <= n) {//loop pra descobrir o expoente
		num = num + 1;//adicionar o expoente
		y = expoente(b, num);//chama a funcao
	}
	int expo = num - 1;//valor final do expoente
	printf("Log de %d na base %d eh igual a %d", n, b, expo);//print de resposta
	return 0;
}