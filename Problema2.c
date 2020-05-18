#include <stdlib.h>
#include <stdio.h>
int main (void){
	int num;//variavel para o numero
	int valor[10];//vetor
	for (int i=0;i<10;i++){// adicionando valores ao vetor
		printf("digite o %d numero inteiro: ",(i+1));//pegar a variavel
		scanf("%d",&num);//colocando o valor na variavel
		valor[i]=num;//setando no vetor
	}
	for (int i=0;i<9;i++){//bubble Sort
		for(int j=0; j<9-i;j++){
			if(valor[j]>valor[j+1]){
				int swap = valor[j];//variavel de suporte
				valor[j]=valor[j+1];//passa o valor menor pra posicao anterior
				valor[j+1]=swap;//passa o valor maior pra posicao seguinte
			}
		}
	}
	printf("Lista Ordenada\n");//retorno da lista
	for ( int c = 0 ; c < 10 ; c++ )//loop de print
		printf("valor[%d]=%d\n",c, valor[c]);//print dos valores
	return 0;
}