#  Copyright 2016 Thiago da Silva Teixeira <teixeira.zeus@gmail.com>
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  
#  

.text
	
#Começo do Main{
main:
	jal Topo
	
	la $a0, buffer  	#GetEntrada(buffer, tamanho)
	li $a1, 20
	jal GetEntrada
	
	la 	$a0, buffer
	jal loadMatrix		#loadMatrix(nome_do_arquivo)
	
	la $a0, Str7	#|=======|\n"
	jal printS
	
	jal multiM
	
	jal printN
	la $a0, Str7	#|=======|\n"
	jal printS

li	$v0, 10
syscall
#} Fim do main

#Topo{
Topo:
addi $sp, $sp, -4
sw $ra, 0($sp)

	la $a0, Str1	#|===Multiplicador de matrizes===|\n"
	jal printS

	la $a0, Str2	#"Certifique-se que o arquivo esteja no mesmo diretorio do MARS\n"
	jal printS
	
	la $a0, Str3	#"Digite o nome do arquivo:"
	jal printS

	#End	
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra
#}

#Print String{
printS:
addi $sp, $sp, -4
sw $v0, 0($sp)
	li $v0, 4       
	syscall
lw $v0, 0($sp)
addi $sp, $sp, 4
jr $ra
#}

#Print Inteiro{
printI:
addi $sp, $sp, -4
sw $v0, 0($sp)
	li $v0, 1     
	syscall
lw $v0, 0($sp)
addi $sp, $sp, 4
	
jr $ra
#}

#Print Caracter{
printC:
addi $sp, $sp, -4
sw $v0, 0($sp)
	li $v0, 11     
	syscall
lw $v0, 0($sp)
addi $sp, $sp, 4
jr $ra
#}

#PulaLinha{
printN:
addi $sp, $sp, -4
sw $v0, 0($sp)
addi $sp, $sp, -4
sw $a0, 0($sp)
	la $a0, Str4	#\n
	li $v0, 4     
	syscall
lw $a0, 0($sp)
addi $sp, $sp, 4
lw $v0, 0($sp)
addi $sp, $sp, 4
jr $ra
#}


#printTeste{
printTeste:
addi $sp, $sp, -4
sw $v0, 0($sp)
addi $sp, $sp, -4
sw $a0, 0($sp)
	la $a0, Str4	#\n
	li $v0, 4     
	syscall
	la $a0, Str5	#\teste
	li $v0, 4     
	syscall
lw $a0, 0($sp)
addi $sp, $sp, 4
lw $v0, 0($sp)
addi $sp, $sp, 4
jr $ra
#}

#printSpaço{
printSpace:
addi $sp, $sp, -4
sw $v0, 0($sp)
addi $sp, $sp, -4
sw $a0, 0($sp)
	la $a0, Str6	#" "
	li $v0, 4     
	syscall
lw $a0, 0($sp)
addi $sp, $sp, 4
lw $v0, 0($sp)
addi $sp, $sp, 4
jr $ra
#}

#printBarra{
printBarra:
addi $sp, $sp, -4
sw $v0, 0($sp)
addi $sp, $sp, -4
sw $a0, 0($sp)
	la $a0, Str8	#|
	li $v0, 4     
	syscall
lw $a0, 0($sp)
addi $sp, $sp, 4
lw $v0, 0($sp)
addi $sp, $sp, 4
jr $ra
#}


#GetEntrada{
GetEntrada:
addi $sp, $sp, -4
sw $ra, 0($sp)

addi $sp, $sp, -4
sw $s0, 0($sp)

	li $v0, 8       #Guarda a entrada do usuario no buffer     
	syscall
	
	li $s0,0        #index = 0
	removerBarraN:
		lb $a3,buffer($s0)    
		addi $s0,$s0,1      # index++
		bnez $a3,removerBarraN     # Chega até o final da string
		beq $a1,$s0, .ok    # Não remover se estiver no limite do buffer
		subiu $s0,$s0,2     # Anda até o \n
		sb $0, buffer($s0)    # "zera" o \n com \0
	.ok:

lw $s0, 0($sp)
addi $sp, $sp, 4

	#End
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra
#}

#Carrega Matrix{
loadMatrix:
addi $sp, $sp, -4
sw $ra, 0($sp)
########
#
#	Arquivo
#	t8 = file decriptor	
#
#	Matrix A
#	s0 = indice
#	s1 = linha
#	s2 = coluna
#	s6 = endereço fixo
#
#	Matrix B
#	s3 = indice
#	s4 = linha
#	s5 = coluna
#	s7 = endereço fixo
#
#	t0 = temp para calcular elementos
#	
#


	li $t9, 0	#zera indice
	

	#Abre arquivo
	li	$v0, 13			#Configura os parametros para abertura de arquivo
	add	$a1, $0, $0		
	add	$a2, $0, $0		
	syscall
					
	add	$t8, $v0, $0	# File decriptor em t8

	#Leitura
	li	$v0, 14		#leia do arquivo
	add	$a0, $t8, $0	# Passa fd(t8) para a0
	la	$a1, bufferArq	#le 500 bytes
	li $a2, 500
	syscall
	
	la	$a0, bufferArq		
	#jal printS			#Printa buffer

	
	#MATRIX A
	#la $s0, matrixA($zero)
	
	jal atoi			#linha		
	move $s1, $v0
	addi $a0, $a0, 1

	jal atoi			#coluna
	move $s2, $v0
	addi $a0, $a0, 1

	mul $t0, $s1, $s2 #total de elementos A
	
	move $a3, $t0
	jal malloc	#Alocação de memoria
	move $s6, $v0	#Guarda em s6
	move $s0, $s6
	
	#for range(t0)
	forRangeA:
		blez $t0, exitForRangeA
																	
		jal atoi
		sw	$v0, 0($s0)
			
		addiu  $a0, $a0, 1
		addiu $s0, $s0, 4
		
		sub $t0, $t0, 1
	j forRangeA
	exitForRangeA:
	
	######
	#Pula \n
	#####

	#MATRIX B
	#la $s3, matrixB($zero)
	
	jal atoi			#linha
	li $s4, 0	
	move $s4, $v0
	addi $a0, $a0, 1
	
	jal atoi			#coluna
	move $s5, $v0
	addi $a0, $a0, 1
	
	mul $t0, $s4, $s5 #total de elementos B
	
	move $a3, $t0
	jal malloc	#Alocação de memoria
	move $s7, $v0	#Guarda em s7
	move $s3, $s7
	
	
	#for range(t0)
	forRange:
		blez $t0, exitForRange
		
		jal atoi
		sw	$v0, 0($s3)
		
		addiu $a0, $a0, 1
		addiu $s3, $s3, 4
		
		subu $t0, $t0, 1
	j forRange
	exitForRange:

	#Fecha arquivo
	fecha:
		li	$v0, 16	
		add	$a0, $t8, $0	
		syscall		
	
					
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra
#}

#Atoi{
atoi:
addi $sp, $sp, -4
sw $t0, 0($sp)
addi $sp, $sp, -4
sw $t1, 0($sp)
addi $sp, $sp, -4
sw $t2, 0($sp)
addi $sp, $sp, -4
sw $t3, 0($sp)

	li      $v0, 0   #Resultado = 0
	li      $t1, 0   #Flag para negativo
	
	lb      $t0, 0($a0)
	bne     $t0, '+', .positivo      
	addi    $a0, $a0, 1
	.positivo:
	
	lb      $t0, 0($a0)
	bne     $t0, '-', .scan

		addi    $t1, $zero, 1       #é negativo
	addi    $a0, $a0, 1
	
	.scan:
		lb      $t0, 0($a0)
		
		
		slti    $t2, $t0, 58        #'9'
		slti    $t3, $t0, '0'       #'0'
		
		
		beq     $t2, $zero, .fim
		bne     $t3, $zero, .fim
		
		sll     $t2, $v0, 1
		sll     $v0, $v0, 3
		
		add     $v0, $v0, $t2       #num *= 10
		addi    $t0, $t0, -48
		
		add     $v0, $v0, $t0       #concatena resultado
		addi    $a0, $a0, 1         #percorre string
	j   .scan
	
	.fim:

	beq     $t1, $zero, .exitAtoi    # Se negativo troca sina
	sub     $v0, $zero, $v0

	.exitAtoi:

lw $t3, 0($sp)
addi $sp, $sp, 4
lw $t2, 0($sp)
addi $sp, $sp, 4
lw $t1, 0($sp)
addi $sp, $sp, 4
lw $t0, 0($sp)
addi $sp, $sp, 4
jr      $ra         # return
#}


#Multiplicador{
multiM:
addi $sp, $sp, -4
sw $ra, 0($sp)
addi $sp, $sp, -4
sw $t0, 0($sp)
addi $sp, $sp, -4
sw $t1, 0($sp)
addi $sp, $sp, -4
sw $t2, 0($sp)
addi $sp, $sp, -4
sw $t3, 0($sp)
addi $sp, $sp, -4
sw $t4, 0($sp)
	
	#i = t0
	#j = t1
	#ita = t2
	
	#for(int itA = 0 , i = 0; i < linhaA; itA += colunaA, i++ ){
	li $t2, 0
	li $t0, 0
	forC1:
	jal printBarra
	#blt  $s1, $t0, exitforC1	#If i < linhaA 
	ble	$s1, $t0, exitforC1	#If i < linhaA 
		#for(int j = 0; j < colunaB; j++){
		li $t1, 0
		forC2:
		
		jal cat
		
		addi $t1, $t1, 1
		ble $s5, $t1, exitforC2
		j forC2
		exitforC2:		
	
	jal printN
			
	addu $t2, $t2 $s2	#itA += colunaA
	addi $t0, $t0, 1	#i++
	j forC1	
	exitforC1:


lw $t4, 0($sp)
addi $sp, $sp, 4
lw $t3, 0($sp)
addi $sp, $sp, 4
lw $t2, 0($sp)
addi $sp, $sp, 4
lw $t1, 0($sp)
addi $sp, $sp, 4
lw $t0, 0($sp)
addi $sp, $sp, 4
lw $ra, 0($sp)
addi $sp, $sp, 4
jr      $ra         # return
#}
	
	
	
#cat{
cat:
addi $sp, $sp, -4
sw $ra, 0($sp)
addi $sp, $sp, -4
sw $t0, 0($sp)
addi $sp, $sp, -4
sw $t1, 0($sp)
addi $sp, $sp, -4
sw $t2, 0($sp)
addi $sp, $sp, -4
sw $t3, 0($sp)
addi $sp, $sp, -4
sw $t4, 0($sp)
addi $sp, $sp, -4
sw $t5, 0($sp)
addi $sp, $sp, -4
sw $t6, 0($sp)
addi $sp, $sp, -4
sw $t7, 0($sp)

	#i = t0
	#j = t1
	#ita = t2
	#
	
	li $v0, 0
	
	#cat(int matrixA[], int matrixB[], int i, int j, int tamanho, int pulo){
	#la	$s0, matrixA
	move $s0, $s6
	
	#la	$s3, matrixB
	move $s3, $s7
	
	
	move $t0, $t2 #intA
	mul $t0, $t0, 4
	
	mul  $t1, $t1, 4 #j
	
	
	move $t2, $s2 #colunaA / tamanho
	move $t3, $s5 #colunaB
	mul $t3, $t3, 4
		
	addu $s0, $s0, $t0	
	addu $s3, $s3, $t1

	
	li $t4, 0	#resultado
	li $t5, 0
	
	whileF:
	blez $t2, exitF #if tamanho <= 0
	
	lw $t4, 0($s0)				#r += multiInt(matrixA[i++],matrixB[j]);
	lw $t5, 0($s3)
		

	mul $t6, $t4, $t5	 
	addu $v0, $v0, $t6 
	
	addu $s0, $s0, 4
	
	#j += pulo;
	#la	$s3, matrixB
	move $s3, $s7
	
	addu $t1, $t1, $t3  #j = j + culunaB
	addu $s3, $s3, $t1
	#move $s3, $t1
	
	addiu $t2, $t2, -1	#tamanho--		
	j whileF	
	exitF:
	
	move $a0, $v0
	jal printI
	jal printSpace
	


lw $t7, 0($sp)
addi $sp, $sp, 4
lw $t6, 0($sp)
addi $sp, $sp, 4
lw $t5, 0($sp)
addi $sp, $sp, 4
lw $t4, 0($sp)
addi $sp, $sp, 4
lw $t3, 0($sp)
addi $sp, $sp, 4
lw $t2, 0($sp)
addi $sp, $sp, 4
lw $t1, 0($sp)
addi $sp, $sp, 4
lw $t0, 0($sp)
addi $sp, $sp, 4
lw $ra, 0($sp)
addi $sp, $sp, 4
jr      $ra         # return
#}

#Alocação de memoria{
malloc:
# a3 = tamanho sem alinhamento
addi $sp, $sp, -4
sw $a0, 0($sp)
#
	mul $a3, $a3, 4
	li $v0, 9		#Aloca memoria suficiente          
	move $a0, $a3         
	syscall

#
lw $a0, 0($sp)
addi $sp, $sp, 4
jr $ra
#}


.data
buffer:	.space	50			#buffer para a entrada do usuario
Str1: .asciiz "|==================Multiplicador de matrizes==================|\n"
Str2: .asciiz "|Certifique-se que o arquivo esteja no mesmo diretorio do mars|\n"
Str3: .asciiz "|Digite o nome do arquivo:"
Str4: .asciiz "\n"
Str5: .asciiz "TESTE\n"
Str6: .asciiz " "
Str7: .asciiz "|=============================================================|\n"
Str8: .asciiz "| "


bufferArq:	.space	500		#Buffer guarda arquivo
				.align 2
