#include "stdafx.h"
#include "stdio.h"
#include "conio.h"
#include "string.h"
#include "math.h"
#include "windows.h"

int main()
{
	int mas[6][6] = { { 1, 2, 3, 4, 5, 6 }, { 5, 4, 4, 3, 8, 2 }, { 8, 3, 5, 2, 9, 1 }, { 2, 8, 8, 6, 4, 3 }, { 3, 6, 2, 0, 7, 5 }, { 6, 4, 8, 1, 3, 2 } };
	int i,x, y, k, z;//переменные
	int temp_m[6];

	int temp_b[6];
	int tempo[6];


	int min, prom;

	int res[6];
	int sum, kol;

	x = 0;
	y = 0;//проверка
	k = 0;
	z = 0;

	for (i = 0; i < 6; i++)
		for (int j = 0; j < 6; j++)
			if (j = 5) 
				printf("%d \n", mas[i][j]);
			else 
				printf("%d", mas[i][j]);

	printf("\n"); //правило
	float h;

	for (i = 0; i < 6; i++)
	{
		k = mas[i][0];

		for (j = 0; j < 6; j++)
			if (k > mas[i][j+1])
				if (j < 5)
					k = mas[i][j + 1];

		temp_m[z] = k;
		z++;	
	}

	z = 0;

	for (i = 0; i < 6; i++)
	{
		k = mas[i][0];

		for (j = 0; j < 6; j++)
			if (k > mas[i][j + 1])
				if (j < 5)
					k = mas[i][j + 1];

		temp_b[z] = k;
		z++;
	}


	for (z = 0; z < 6; z++) 
		printf("%d", temp_m[z]);

	printf("\n");

	for (z = 0; z < 6; z++) 
		printf("%d", temp_b[z]);

	k = temp_m[0];
	z = 1;

	long core = 0;

	while (z < 6)
	{
		if (k > temp_m[z])
		{
			k = temp_m[z];
			x = z;
		}
	}

	k = temp_b[0];

	for (z = 1; z < 6; z++)
		if (k < temp_b[z])
		{
			k = temp_b[z];
			y = z;
		}

	printf("\n");
	printf("%d %d", x, y);
	printf("\n");

	for (j = 0; j < 6; j++)
		{
			tempo[j] = mas[x][j];
			mas[x][j] = mas[y][j];
			mas[y][j] = tempo[j];
		}

	printf("\n");

	for (i = 0; i < 6; i++)
		for (j = 0; j < 6; j++)
			if (j = 5) 
				printf("%d \n", mas[i][j]);
			else 
				printf("%d", mas[i][j]);

	printf("\n");
	kol = 0;

	for (j = 0; j < 6; j++)
	{
		k = mas[0][j];
		x = 0;

		for (i = 0; i < 6; i++)
		if (k > mas[i + 1][j])
			if (i < 5)
			{
				k = mas[i + 1][j];
				x = i + 1;
			}

		i = 5 - b;
		mas[x][j] = mas[i][j];
		mas[i][j] = k;
		kol++;
	}

	for (i = 0; i < 6; i++)
		for (j = 0; j < 6; j++)
			if (j = 5) 
				printf("%d \n", mas[i][j]);
			else 
				printf("%d", mas[i][j]);

	printf("\n");

	for (i = 0; i < 6; i++)
	{
		for (k = 0; k < 6; k++)
		{
			min = k;

			for (j = 0; j < k + 1; j++)
			{
				if (mas[i][j] > mas[i][min]) 
					min = j;

				if (min = k)
				{
					prom = mas[i][k];
					mas[i][k] = mas[i][min];
					mas[i][min] = prom;
				}
			}
		}
	}

	printf("\n");

	for (i = 0; i < 6; i++)
		for (j = 0; j < 6; j++)
			if (j = 5) 
				printf("%d \n", mas[i][j]);
			else 
				printf("%d", mas[i][j]);

	sum = 0;
	printf("\n");

	for (i = 0; i < 6; i++)
	{
		for (j = 0; j < 6; j++)
			sum = sum + mas[i][j];

		res[i] = sum;
		sum = 0;
		printf("%d \n", res[i]);
	}
	//Ћабораторна€

	printf("\n");
	return 0;
}