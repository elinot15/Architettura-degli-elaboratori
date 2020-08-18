#Elisa Notarangelo
#Matricola 290295
#Progetto di Architettura degli elaboratori II

.data
inizio: .word 0

#titolo del progetto:
titolo: .asciiz "\nLista dei Libri Preferiti\n"

#menu generale:
menu_richiesta: .asciiz "\nInserisci il numero corrispondente all'operazione che desideri effettuare: "
menu:.asciiz "Menu operazioni: \n0 - Inserisci una nuovo libro nella tua raccolta \n1 - Visualizza tutti i libri inseriti \n2 - Visualizza una libro in dettaglio tramite codice \n3 - Rimuovi libro tramite codice \n4 - Esci\n"
 
#inserimento sbagliato nel menu iniziale:
menu_errore: .asciiz "\nNumero dell'operazione non valido, inserire un valore corretto.\n"

inserisci: .asciiz "\nInserisci un nuovo Libro"
inserisci_titolo: .asciiz "\nInserisci il titolo del libro(massimo 40 caratteri):   "
inserisci_autore: .asciiz "\nInserisci l'autore del libro(massimo 37 caratteri):    "
inserisci_genere: .asciiz "\nInserisci il genere del libro(massimo 40 caratteri):  "

intestazione: .asciiz "\n codice   titolo   autore   genere \n\n"
separatore: .asciiz " | "
a_capo: .asciiz "\n"

inserisci_codice: .asciiz "\nInserisci codice del Libro che vuoi visualizzare:  "

elimina_codice: .asciiz "\nRimozione del libro con codice:  "

codice_errore: .asciiz "\nCodice errato, valore non valido\n" 

#Struttura nodi
#codice(4 byte) + titolo(40 byte) + autore(37 byte) + genere(40 byte)+ puntatore nodi(4 byte) = 125 byte di struttura + 3 byte(invalid) = tot 128 byte

.text
main:
    li $v0, 4 		        # Syscall per stampare il menu delle operazioni possibili
    la $a0, menu		     
    syscall                         
   
    addi $s6,$zero, 1		# $s6 è un registro dedicato al contatore dei numeri dei libri inseriti	
   
    li      $v0,9               # creazione primo nodo 
    li     $a0,128              #alloco 128 byte per la struttura del nodo 
    syscall

    move    $s5,$v0             #salvo in $s5 l'indirizzo di inizio del primo nodo
    sw      $s5,inizio 		# backup puntatore a primo nodo

    #chiusura della lista
    sw $0, 124($s5)		#setta a null l'ultimo puntatore (e ad ogni elemento che si inserirà la lista crescerà)

    li $v0, 4			# Syscall per stampare il titolo del progetto
    la $a0, titolo    	
    syscall					

    menu_iniziale:		
    li $v0, 4 			# Syscall per chiedere di inserire un valore
    la $a0, menu_richiesta		
    syscall 				
    li $v0, 5 			# Syscall che permette di inserire un valore intero 
    syscall					
    move $s0, $v0		# salvataggio del numero in $s0 
	
    #confronto tra il valore inserito e i registri per saltare alla funzione richiesta o segnalare errore:
    add $s1, $zero, 1		# salvo 1 in $s1
    add $s2, $zero, 2		# salvo 2 in $s2
    add $s3, $zero, 3		# salvo 3 in $s3
    add $s4, $zero, 4		# salvo 4 in $s4
    beq $s0, $zero, Valore0	# se il registro $s0 è uguale a 0 si salta a Valore0, che permette di inserire i dati del libro
    beq $s0, $s1, Valore1       # se il registro $s0 è uguale a 1 verranno visualizzati tutti gli elementi 
    beq $s0, $s2, Controllo     # se il registro $s0 è uguale a 2 va a controllare se ci sono elementi nella lista
    beq $s0, $s3, Controllo     # se il registro $s0 è uguale a 3 va a controllare se ci sono elementi nella lista per poi eliminarlo
    beq $s0, $s4, Fine		# se il registro $s0 è uguale a 4 va alla fine del programma

    #nel caso in cui non venisse inserito nessuno dei valore precedenti si deve condiderare come errore e torna all'inzio:	
    li $v0, 4 			#Syscall per stampare la stringa che segnala l'errore
    la $a0, menu_errore	
    syscall 				
    j menu_iniziale		# salto incodizionato per torna al menu inziale


    #inserisci libro
    Valore0: 						
    li $v0, 9	               #creo nodo e alloco 128 byte per la struttura
    li $a0, 128
    syscall

    #collegamento del nodo precedente
    sw $v0, 124($s5)

    #rendere il nuovo nodo il nodo corrente
    move $s5, $v0

    
    sw  $s6, 0($s5)	      #riempire il nodo con il valore del contatore
    addi $s6, $s6, 1	      #dare il codice e aumento il contatore

    # inserisci titolo
    li $v0, 4 		      #Syscall per stampare la stringa che chiede il titolo del libro
    la $a0, inserisci_titolo	
    syscall							
    addi $a0, $s5, 4	      # sposta alla posizione 4 del registro $s5
    addi $a1, $zero, 41	      # verificare lunghezza a 40
    li $v0,	8	      #Syscall per inserire il titolo del libro
    syscall	
    #inserisci autore:
    li $v0, 4 		      # Syscall per stampare la stringa che chiede l'autore del libro
    la $a0, inserisci_autore	
    syscall							
    addi $a0, $s5, 45	      # sposta alla posizione 46 del registro $s5 
    addi $a1, $zero, 38	      # verificare lunghezza a 37
    li $v0,	8	      # Syscall per inserire l'autore del libro	
    syscall							
    #inserisci genere:
    li $v0, 4 		      # Syscall per stampare la stringa che chiede il genere del libro
    la $a0, inserisci_genere	
    syscall						
    addi $a0, $s5, 83	      # sposto alla posizione 69 del registro $s5
    addi $a1, $zero, 41	      # controllo della lunghezza a 40
    li $v0,	8	      # Syscall per inserire il genere del libro
    syscall						

    #chiusura della lista
    sw $0, 124($s5)	     #setta a null l'ultimo puntatore (ad ogni ciclo chiudo la lista, e ad ogni elemento che si inserirà la lista crescerà)	
    j menu_iniziale	
    
    				
   # stampa tutti i libri 												
    Valore1:
    li $v0, 4 		    # Syscall per stampare l'intestazione
    la $a0, intestazione 	                
    syscall						
			
    lw	 $t0, inizio	    #puntatore al primo nodo	 
    lw 	 $t0, 124($t0)	    #ottengo direttamente il puntatore al secondo nodo, così il programma non mi stampa la prima riga relativa al nodo iniziale

    j Stampa
    
    
    Stampa:			 
    beqz   $t0, menu_iniziale   # fino alla fune della lista
  
    lw $a0, 0($t0)		# legge la parola nel registro
    li $v0, 1 			# Syscall per print integer
    syscall			
    li $v0, 4 			# Syscall per stampare il separatore |
    la $a0, separatore	
    syscall					
	
    #Titolo
    li $v0, 4 			# Syscall per print_string
    la $a0, 4($t0)		
    syscall			
    li $v0, 4 			# Syscall per stampare separatore |
    la $a0, separatore	
    syscall					
    #Autore
    li $v0, 4 			# Syscall per print_string
    la $a0, 45($t0)		
    syscall			
    li $v0, 4 			# Syscall per stampare separatore |
    la $a0, separatore	
    syscall					
    #Genere
    li $v0, 4 			# Syscall per print_string
    la $a0, 83($t0)		
    syscall			
    li $v0, 4 			# Syscall per stampare separatore |
    la $a0, a_capo		
    syscall					
    
    lw   $t0,124($t0)           # ottieni puntatore a prossimo nodo
    j Stampa                    #continua a stampare finchè la lista non è finita
    
  
        
   Controllo:
   lw $t0, inizio 		#carico in $t0 l'indirizzo di inizio
   lw $t1, 124($t0)		#carico l'immediato del puntatore al prossimo nodo in $t0
   #if
   beq $t1, $zero , caso_errore	  	# se l'indirizzo del nodo corrente è lo stesso di inizio va a caso_errore	
   #else
   beq $s0, $s2, Valore2 	  # se $s0 è uguale a 2, allora va alla stampa del codice
   beq $s0, $s3, Valore3         # se $s0 è uguale a 3, allora va alla eliminazione

    #stampa libro con codice corrispondente
    Valore2:						
    li $v0, 4 	            # Syscall per stampare la stringa che chiede il codice del libro che si vuole visualizzare
    la $a0, inserisci_codice	
    syscall						
    li $v0, 5 		    #Syscall per leggere intero
    syscall						

    move $t2, $v0	    # salvo il numero in $t2		
    addi $t0, $s6, -1       #metto temporaneamente in $t0 il valore del contatore -1,per la branch
    bgtu $t2,  $s6, err_codice        #dà errore se il valore in $t2 è più grande di $s6 
    lw $t0, inizio	    #ottengo puntatore al primo nodo e lo salvo in $t0 
    lw $t0, 124($t0)	    #ottengo direttamente il puntatore al secondo nodo, così il programma non mi stampa la prima riga relativa al nodo iniziale

    j stampa_codice	    # se il codice è giusto avviene un salto incodizionato a stampa_codice

    
    #elimina libro tramite codice
    Valore3:						
    li $v0, 4 		    #Syscall che stampa la stringa con la richiesta del codice del libro che si vuole eliminare
    la $a0, elimina_codice	
    syscall						
    li $v0, 5               #Syscall che richiede l'inserimento di un intero
    syscall						
    move $t2, $v0	    # salvo il numero in $t2		
	
    addi $t0, $s6, -1	    #metto temporaneamente in $t0 il valore del contatore -1,per la branch
    bgtu $t2, $s6, codi_er  #dà errore se il valore in $t2 è più grande di $s6,cioè del valore più alto assegnato ai codici dei libri

    lw $t0, inizio	     #puntatore al primo nodo in $t0
    lw $t0, 124($t0)	     #ottengo direttamente il puntatore al nodo succussivo
			
    j Elimina
    
   #caso in cui il codice del libro non esista
   caso_errore:
   li $v0, 4 			# Syscall per stampare la stringa che indica che il codice inserito non è valido
   la $a0, codice_errore	
   syscall					
   j menu_iniziale			#torna alla selezione del codice
   
    
   stampa_codice:
   beqz $t0,  err_codice	#se arriva alla fine della lista allora da errore	
   lw	$t1, 0($t0)		#salvo in $t1 il codice del nodo corrente
   beq $t2, $t1, ok_codice	#se il codice in $t1 à uguale a $t2 scelto prima salta a ok_codice
   lw $t0, 124($t0)		#se no cambia il puntatore al nodo successivo
   j stampa_codice		#loop

   
   #stampa singola
   ok_codice:			
   lw $a0, 0($t0)		# legge la parola nel registro
   li $v0, 1 			# Syscall per print integer
   syscall			
   li $v0, 4 			# Syscall per print_string
   la $a0, separatore	        
   syscall			
	
   #Titolo
   li $v0, 4 			# Syscall per stampare titolo
   la $a0, 4($t0)		
   syscall			
   li $v0, 4 			# Syscall per stampare separatore |
   la $a0, separatore	        
   syscall				
   #Autore
   li $v0, 4 			# Syscall per stampare l'autore
   la $a0, 45($t0)		
   syscall			
   li $v0, 4 			# Syscall per stampare separatore |
   la $a0, separatore	       
   syscall				
   #Genere
   li $v0, 4 			# Syscall per stampare il genere
   la $a0, 83($t0)		
   syscall			
   li $v0, 4 			# Syscall per stampare la stringa che manda a capo
   la $a0, a_capo		
   syscall			
   j menu_iniziale		# rimanda al menu principale
	
		
   err_codice:
   li $v0, 4 			# Systemcall per stampare stringa codice_errore
   la $a0, codice_errore	
   syscall			
   j Valore2			#torna alla selezione del codice


   #eliminazione e rinumerazione 
   Elimina:				
   beqz $t0,  codi_er	        #se arriva alla fine della lista allora dà errore
   lw	$t1, 0($t0)		#salvo in $t1 il codice del nodo corrente
   beq $t2, $t1, ok_elimina	#se $t1 à uguale a $t2 salta a ok_codice
   lw $t0, 124($t0)		#cambia il puntatore
   j Elimina 			#loop

   codi_er:
   li $v0, 4 			# Syscall per stampare la stringa che segnale un errore del codice inserito
   la $a0, codice_errore	
   syscall					
   j Valore3			#torna alla selezione del codice


   ok_elimina:
   addi $s6, $s6, -1		# decremento del contatore $s6 
   #eccezione primo nodo
   li $t4, 1			# salvare il numero 1 in $t4
   beq $t1, $t4, ok_inizio	#se $t1 è uguale a 1 allora va a ok_inizio
   #nodo in mezzo alla lista e ultimo nodo
   lw $t3, 124($t0)		#salvo in $t3 il puntatore al nodo successivo
   #cerco nodo precedente
   lw $t4, inizio	       #puntatore al primo nodo
   lw $t4, 124($t4)	       #puntatore al nodo successivo in $t4
   addi $t2, $t2, -1	       #salvo codice precedente in $t2



   #loop per cercare il nodo precedente a quello scelto da eliminare
   loop:							
   lw $t1, 0($t4)		#prendo il codice del nodo corrente $t4
   beq $t2, $t1, ok_secondo	#se il codice in $t1 à uguale a $t2 scelto prima salta a ok_codice
   lw $t4, 124($t4)		#cambia il puntatore
   j loop 			#loop


   ok_secondo:				
   sw $t3, 124($t4)		#collego nodo $t3 al nodo $t4 escludendo così il nodo $t0 dalla lista
   sw $0, 0($t0)		#rimuovo il contenuto di $t0 per liberare memoria
   j resetta			


   #usando come massimo $s6 resetto tutti i codici della lista
   resetta:					
   addi $t7, $zero, 1	       #metto 1 in $t7
   lw $t0, inizio	       #ottengo puntatore al primo nodo	 
   lw  $t0, 124($t0)	       #ottengo direttamente il puntatore al secondo nodo


  #loop resettare i codici
  loop_codice:						
  beq $t7, $s6, menu_iniziale	#salto al menù iniziale se il valore di $t7 è uguale al contatore $s6
  sw $t7, 0($t0)		#altrimenti, setto il codice del nodo
  lw $t0, 124($t0)		#ottengo puntatore al nodo successivo e lo setto a $t0
  addi $t7, $t7, 1		#incremento il contatore dei codici
  j loop_codice


  ok_inizio:						
  lw $t4, inizio 		#$t4 = nodo precedente
  lw $t3, 124($t0)		#$t3 = nodo successivo
  sw $t3, 124($t4)		#collego $t3 a $t4 escludendo nodo corrente
  sw $0, 0($t0)			#rimuovo il contenuto in $t0 per liberare memoria
  j resetta


  Fine:				
  li $v0, 10
  syscall
    
