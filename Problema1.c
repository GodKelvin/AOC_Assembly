#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
int main (void){
	int num;//variavel para o numero
	bool entrar;//float para poder entrar no contador de primos
	int cont=0;//numero de divisores do numero
	printf("digite um numero inteiro: ");//pedindo a variavel
	scanf("%d",&num);//pegando o valor da variavel
	if (num==0){
		printf("Zero\n");//se for igual a zero
		entrar = false;//não entra nos primos
	}else if(num%2!=0){
		printf("Impar\n");//se for impar retorna isso
		if (num == 1) {
			entrar = false;//não entra nos primos
		}
		else {
			entrar = true;//entra nos primos
		}
	}else{
		printf("Par\n");// se for par retorna isso
		if (num == 2) {
			entrar = true;//entra nos primos
		}
		else {
			entrar = false;//não entra nos primos
		}
		
	}
	if (entrar) {//validador para entrar no for, usado para dispensar os pares e o 1
		for (int i = 1; i <= num / 2; i++) {//loop para ver as divisões
			if (num%i== 0) {//se a divisão for sem resto
				cont += 1;//soma 1 ao contador
			}
		}
		if (cont == 1) {//se o contador for igual a 1
			printf("Primo");//o numero eh primo
		}
		else {//se não for
			printf("Nao Primo");// ele nao eh primo
		}
	}
	else {//caso não passe no validador ele nao eh primo
		printf("Nao Primo");
	}
}