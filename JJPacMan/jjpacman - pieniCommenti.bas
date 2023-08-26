'***********************************************************************
'JJ PACMAN!
'
'From an idea by AGPX@itch.io
'Code rewritten by JJFlash@itch.io
'
'Written and tested under XC=BASIC 3.1.9 !

'--- Will translate the comments into English if any interest is there! ---
'***********************************************************************


poke $DC0D, $7F 'spegne l'interrupt di sistema (si guadagna qualche ciclo di clock in più...)
'non uso BORDER e BACKGROUND perché al momento mi sembra abbiano problemi con l'ottimizzatore, sprecando un sacco di byte
poke 53280, 0 : poke 53281, 0 

'Qui si copiano i dati degli sprite e del set di caratteri nei rispettivi posti
'del Banco 2 del VIC-II. Per i caratteri non è necessario copiare tutto il set dalla ROM
'giacché buona parte di esso non sarà usata nel gioco.
'Un po' per pigrizia, un po' per avere flessibilità nei dati esportati, faccio
'calcolare a XCBASIC quanti byte copiare
memcpy @pacSprites, $8000, @endOfData - @pacSprites
memcpy @pacCharset, $B800, @pacSprites - @pacCharset

'Mi tolgo il pensiero sui colori comuni degli sprite multicolor: bianco (1) e nero (0)
sprite multicolor 1, 0

'Nei tanti comandi che XCB mette a disposizione manca quello per impostare il Banco
'di memoria del VIC-II. Tocca arrangiare con una Poke.
'Il Banco si imposta con gli ultimi 2 bit a destra. Purtroppo qui i bit sono *attivi bassi*,
'per cui per ottenere il valore bisogna sottrarre 3 al banco che ci interessa.
'In questo caso, 3 - 2 = 1, cioè %01
poke $DD00, %00010101 

'Questo è impostare la parte di RAM dedicata ai caratteri. Moltiplicando il valore specificato
'per $800 (ossia 2048) si ottiene $3800. Avendo selezionato però il Banco 2,
'si arriva a $B800 (vedi il memcpy di cui sopra)
charset 7

'Qui invece si imposta la memoria per lo schermo, che di default è a $0400.
'Si moltiplica il valore specificato per $400 (ossia 1024) e il risultato è l'indirizzo
'di memoria scelto. Sembrerebbe inutile farlo, visto che il valore qui è 1, ma in verità
'SCREEN si occupa anche di aggiornare l'indirizzo usato dal KERNAL per i Print, nonché
'i puntatori degli sprite. E quindi serve
screen 1

'Maniera poco ortodossa di pulire lo schermo: si va dritti al KERNAL anziché usare il solito
'PRINT "<cuoricino inverso>".
'SYS in XCB si comporta in maniera identica a quella del BASIC V2, incluso il fatto di copiare
'le locazioni 780, 781, 782 e 783 nell'Accumulatore, nel Registro X, nel Registro Y e nello
'Status del processore 6510, prima di lanciare la routine specificata, per poi fare l'inverso
'alla fine. Siccome tutto questo prende un sacco di byte e di tempo CPU, con l'opzione FAST
'si evita tutto questo e si chiama direttamente la routine interessata
sys $E544 FAST

'Volume del SID impostato al massimo, producendo il famoso "botto"
VOLUME 15

'XCB non ha le costanti TRUE e FALSE predefinite, e allora si arrangia così
CONST FALSE = 0
CONST TRUE = 255

'E qui si definiscono le "proprietà" dei 4 fantasmi (qui chiamati Monster in omaggio a quel che
'in realtà sono, è solo dopo che abbiamo preso a chiamarli fantasmi)
'Per rispetto ad AGPX, _non_ ho usato subroutine o funzioni nel Type, perché quelle bloccavano
'AGPX dall'usare i comandi "nativi" di XCB per gli sprite (cosa che lo ha spinto a reinventare la ruota
'già pronta) quando ha scritto la sua versione. Se avesse fatto come ho fatto io non avrebbe avuto intralci
type tMonster
    iCoord_X as INT
    bCoord_Y as BYTE
    bDirection as BYTE
    bShapeNumber as BYTE
    bOriginalColour as BYTE
    bInitialMovementTimer as BYTE
    bMovementTimer as BYTE
end type
Dim aMonsters(4) as tMonster

'Qui la subroutine per (re)impostare i fantasmi. Vengono impostate le coordinate pixel,
'la direzione in cui devono cominciare a muoversi, la loro "forma" (quale sprite usare, lo SHAPE),
'il colore e le velocità (espresse come "timer", dove ogni unità corrisponde a un fotogramma, o frame)
'Il numero 12 è la forma (SHAPE) dei fantasmi normali (inseguitori arrabbiati). Avrei dovuto
'usare delle costanti ma la pigrizia scorre potente in me
sub resetMonsters() STATIC
    aMonsters(0).iCoord_X = 144
    aMonsters(0).bCoord_Y = 80
    aMonsters(0).bDirection = 1 'est
    aMonsters(0).bShapeNumber = 12
    aMonsters(0).bOriginalColour = 2 'rosso
    aMonsters(0).bInitialMovementTimer = 4
    aMonsters(0).bMovementTimer = 4

    aMonsters(1).iCoord_X = 121 '120 + 1
    aMonsters(1).bCoord_Y = 80
    aMonsters(1).bDirection = 1 'est
    aMonsters(1).bShapeNumber = 12
    aMonsters(1).bOriginalColour = 3 'ciano
    aMonsters(1).bInitialMovementTimer = 4
    aMonsters(1).bMovementTimer = 4

    aMonsters(2).iCoord_X = 186 '184 + 2
    aMonsters(2).bCoord_Y = 80
    aMonsters(2).bDirection = 1 'est
    aMonsters(2).bShapeNumber = 12
    aMonsters(2).bOriginalColour = 10 'rosa
    aMonsters(2).bInitialMovementTimer = 4
    aMonsters(2).bMovementTimer = 4

    aMonsters(3).iCoord_X = 163 '160 + 3
    aMonsters(3).bCoord_Y = 80
    aMonsters(3).bDirection = 1 'est
    aMonsters(3).bShapeNumber = 12
    aMonsters(3).bOriginalColour = 8 'arancione
    aMonsters(3).bInitialMovementTimer = 4
    aMonsters(3).bMovementTimer = 4
    
    'tutti sprite Multicolor. Qui ripeto il numero 12 anche perché bShapeNumber di fatto lo uso
    'per tenere uno Status del fantasma (insegue? E' spaventato? E' "solo occhi" che torna alla base?)
    sprite 0 MULTI SHAPE 12 COLOR aMonsters(0).bOriginalColour ON
    sprite 1 MULTI SHAPE 12 COLOR aMonsters(1).bOriginalColour ON
    sprite 2 MULTI SHAPE 12 COLOR aMonsters(2).bOriginalColour ON
    sprite 3 MULTI SHAPE 12 COLOR aMonsters(3).bOriginalColour ON
end sub

'Qui si arriva a definire Pacman! Essendo unico esemplare della sua categoria, non ho usato
'un array né definito un "agente". Avere variabili dedicate significa anche, per il compilatore, avere
'degli indirizzi fissi, che sono più rapidi da accedere.
'Le coordinate sono sempre quelle a pixel, le variabili Map sono correlate alla mappa di
'caratteri che compongono il labirinto. Delta indica dove dovrà muoversi Pacman nel prossimo
'fotogramma, mentre Direction serve ai fantasmi Ciano e Rosa per capire dove dirigersi (meglio
'spiegato nella routine dedicata ai fantasmi).
'SpriteNumber e SpriteFrameNumber servono per l'animazione di Pacman
Dim pacman_iCoord_X as INT, pacman_bCoord_Y as BYTE
Dim pacman_iMap_X as INT, pacman_bMap_Y as BYTE
Dim pacman_iDelta_X as INT, pacman_bDelta_Y as BYTE
Dim pacman_iDirection_X as INT, pacman_bDirection_Y as BYTE
Dim pacman_bSpriteNumber as BYTE, pacman_bSpriteFrameNumber as BYTE

'E qui si (re)impostano i suoi valori di partenza. Coordinate pixel, coordinate mappa (ai fantasmi
'serve sapere da subito dove sta collocato Pacman *a livello di mappa*, non di pixel), direzione
'di partenza (espressa coi Delta) e di conseguenza dove Pacman sta puntando (interessa a Ciano e Rosa)
'Il numero sprite 3 coincide con il primo sprite d'animazione di Pacman che guarda a sinistra
sub resetPacman() STATIC
    pacman_iCoord_X = 152
    pacman_bCoord_Y = 128
    pacman_iMap_X = 19
    pacman_bMap_Y = 16
    pacman_iDelta_X = -1 'pacman va a sinistra
    pacman_bDelta_Y = 0
    pacman_iDirection_X = -8 'pacman va a sinistra
    pacman_bDirection_Y = 0

    pacman_bSpriteNumber = 3 'pacman va a sinistra
    pacman_bSpriteFrameNumber = 0
    
    'Pacman ha sprite ad "alta risoluzione", quindi imposto solo il colore
    'e accendo lo sprite, lo SHAPE verrà indicato dopo
    sprite 7 HIRES COLOR 7  ON  'giallo
end sub

'Queste sono variabili di Gioco, di "interesse generale" insomma.
'Indicano se Pacman è stato catturato da uno dei fantasmi, se c'è un effetto "fantasmi spaventati"
'e quanto manca a passare, un timer dedicato al lampeggìo delle "pillole energetiche",
'quanti pallini da mangiare mancano per completare il quadro, i tentativi rimasti di Pacman
'(le classiche "vite"), e il punteggio espresso in DECIMAL (spiegato poi)
Dim game_bPacmanCaught as BYTE, game_iScaredTimer as INT, game_bPowerPelletAnimTimer as BYTE
Dim game_iDotsToEat as INT, game_bPacmanTries as BYTE, game_dScore as DECIMAL
CONST DOTS_NUM = 306

'Gruppo di variabili e costanti per i suoni! Agendo soltanto sulle variabili dei timer,
'e fissando gli incrementi nella routine dedicata, mi pare d'aver semplificato abbastanza
'la gestione dei suoni (a tutt'oggi non ho ancora chiaro come funziona il sistema di AGPX, sembra
'"iper-ingegnerizzato" per quel che serve)
Dim snd_bDotEaten_Timer as BYTE, snd_wDotEaten_Frequency as WORD, snd_wDotEaten_IncrementDirection as WORD
CONST SND_DOT_EATEN_TIMER_START = 3
CONST SND_DOT_EATEN_FREQUENCY_START = 1250
Dim snd_bPowerDotEaten_Timer as BYTE, snd_wPowerDotEaten_Frequency as WORD
CONST SND_POWERDOT_EATEN_TIMER_START = 45
CONST SND_POWERDOT_EATEN_FREQUENCY_START = 1500
Dim snd_bMonsterEaten_Timer as BYTE, snd_wMonsterEaten_Frequency as WORD
CONST SND_MONSTER_EATEN_TIMER_START = 6
CONST SND_MONSTER_EATEN_FREQUENCY_START = 2000

'Qui si (re)impostano i canali del SID, si azzerano i timer e si (re)impostano le variabili per le
'frequenze dei suoni. Il canale 1 usa la forma di suono a triangolo, gli altri due a dente di sega
sub initSounds() STATIC   
    VOICE 1 ADSR 8, 0, 6, 0  WAVE TRI 
    snd_bDotEaten_Timer = 0
    snd_wDotEaten_Frequency = SND_DOT_EATEN_FREQUENCY_START
    snd_wDotEaten_IncrementDirection = 1250
    
    VOICE 2 ADSR 0, 0, 15, 4  WAVE SAW
    snd_bPowerDotEaten_Timer = 0
    snd_wPowerDotEaten_Frequency = SND_POWERDOT_EATEN_FREQUENCY_START
    
    VOICE 3 ADSR 0, 0, 15, 4  WAVE SAW
    snd_bMonsterEaten_Timer = 0
    snd_wMonsterEaten_Frequency = SND_MONSTER_EATEN_FREQUENCY_START
end sub

'Qui vengono "suonati i suoni" a partire dal momento in cui vengono impostati i timer dai vari eventi
'del Gioco. Quello per la pillola mangiata alterna col salire o lo scendere, nel pallido tentativo di ricreare
'il suono del gioco arcade
sub soundHandler() STATIC
    if snd_bDotEaten_Timer then
        VOICE 1 TONE snd_wDotEaten_Frequency  ON
        snd_bDotEaten_Timer = snd_bDotEaten_Timer - 1
        snd_wDotEaten_Frequency = snd_wDotEaten_Frequency + snd_wDotEaten_IncrementDirection
        'Vedere un if-then scritto così può far inarcare un sopracciglio, il punto è che facendo così si risparmia qualche
        'byte (l'ho verificato) e di conseguenza anche tempo CPU!
        if snd_bDotEaten_Timer then
        else
            VOICE 1 OFF
            snd_wDotEaten_IncrementDirection = NOT (snd_wDotEaten_IncrementDirection) + 1 'inverte la direzione dell'aggiornamento frequenza suono
        end if
    end if
    
    if snd_bPowerDotEaten_Timer then
        VOICE 2 TONE snd_wPowerDotEaten_Frequency  ON
        snd_bPowerDotEaten_Timer = snd_bPowerDotEaten_Timer - 1
        snd_wPowerDotEaten_Frequency = snd_wPowerDotEaten_Frequency + 100 'gli incrementi per i suoni sono "cablati" nella routine
        if snd_bPowerDotEaten_Timer then
        else
            VOICE 2 OFF
            snd_wPowerDotEaten_Frequency = SND_POWERDOT_EATEN_FREQUENCY_START
        end if
    end if
    
    if snd_bMonsterEaten_Timer then
        VOICE 3 TONE snd_wMonsterEaten_Frequency  ON
        snd_bMonsterEaten_Timer = snd_bMonsterEaten_Timer - 1
        snd_wMonsterEaten_Frequency = snd_wMonsterEaten_Frequency + 1000 'gli incrementi per i suoni sono "cablati" nella routine
        if snd_bMonsterEaten_Timer then
        else
            VOICE 3 OFF
            snd_wMonsterEaten_Frequency = SND_MONSTER_EATEN_FREQUENCY_START
        end if
    end if
end sub

'Qui si supplisce a un'altra mancanza di XCB, l'opposto del comando CHARAT.
'CHARAT mette un singolo carattere direttamente nella memoria schermo. Servirebbe
'un altro comando che "leggesse" il carattere presente alle coordinate specificate.
'Questa cosa non c'è, e allora tocca aggiungere una tabella precalcolata di indirizzi
'della memoria video per ciascun inizio riga. Sommando il valore indicato dall'indice
'(che rappresenta la riga) alla colonna, si ottiene l'indirizzo di memoria su cui poter fare Peek
Dim wScreenTable(22) as WORD @screenTable
screenTable:
DATA AS WORD $8400, $8428, $8450, $8478, $84A0, $84C8, $84F0, $8518, $8540, $8568
DATA AS WORD $8590, $85B8, $85E0, $8608, $8630, $8658, $8680, $86A8, $86D0, $86F8
DATA AS WORD $8720, $8748

'Variabili di servizio! Qui si tiene traccia di quale fotogramma di Pacman visualizzare
Dim bAnimFrameCounter as BYTE

'Schema "precalcolato" degli offset rispetto allo sprite iniziale di Pacman (a seconda di dove
'guarda Pacman, il numero "base" di sprite cambia)
Dim bFrameAnimNumber(8) as BYTE @FrameAnimData
FrameAnimData:
DATA AS BYTE 0, 0, 1, 1, 2, 2, 1, 1

'Due array per impostare in che modo Y e X cambiano a seconda di quale direzione
'i vari personaggi percorrono. Avrei potuto fare un altro Type e fare un solo array,
'qui c'entrano la pigrizia e l'abitudine a usare ventuordici array (per contro, si ritorna
'al discorso degli indirizzi fissi che sono più veloci da richiamare)
Dim bDirections_Y(4) as BYTE @directionValues_Y
Dim iDirections_X(4) as INT @directionValues_X
'BYTE è di tipo "senza segno", per cui non si può scrivere -1, si scrive allora 255 che è lo stesso
'(cerca argomento "Complemento a Due")
directionValues_Y:
DATA AS BYTE 255, 0, 1, 0 'nord (-1), est, sud, ovest
directionValues_X:
DATA AS INT    0, 1, 0,-1 'nord     , est, sud, ovest

'Questa viene usata per "domare" la linea Raster e recuperare un fotogramma quando il precedente
'è andato lungo (spiegato sotto)
Dim bShortFrame as BYTE

'Ed eccoci giunti alla subroutine MAESTRA, quella che gestisce i fantasmi!
sub updateMonster(bMonsterNum as BYTE) STATIC
    'Principalmente per mia paranoia, tutte le variabili usate in questa subroutine sono dichiarate FAST.
    'FAST significa che vengono allocate nella famigerata "pagina zero" della memoria del C64. Le locazioni della
    'pagina zero vengono manipolate usando un byte in meno, e avendo di fatto un indirizzamento a 8 bit anziché 16, tutte
    'le operazioni prendono qualche ciclo di clock in meno. Se le operazioni sono tante si ottiene un bel risparmio di tempo
    '(e pure di memoria!)
    Dim bThis_ShapeNumber as BYTE FAST
    Dim FAST iThis_Coord_X as INT, bThis_Coord_Y as BYTE FAST
    Dim FAST iThis_Map_X as INT, bThis_Map_Y as BYTE FAST
    Dim FAST iOffset_Map_X as INT, bOffset_Map_Y as BYTE FAST
    Dim FAST iTargetTile_X as INT, bTargetTile_Y as BYTE FAST
    Dim FAST bThis_Direction as BYTE
    Dim FAST bOppositeDirection as BYTE, bDirectionToGo as BYTE FAST
    Dim FAST iThis_Distance as INT, iShortestDistance as INT FAST
    Dim FAST iPartialDistance as INT
    Dim FAST bHalfSprite_Coord_X as BYTE, bHalfSprite_Coord_Y as BYTE FAST
    Dim FAST bStepMultiplier as BYTE

    'E' stato mio "vizio" mettere per così dire in "cache" una gran quantità di variabili presenti nell'array
    'dedicato ai fantasmi. Se non facessi così, per ritrovare ogni volta una specifica variabile o proprietà all'interno
    'dell'array il programma dovrebbe fare operazioni come addizioni o anche moltiplicazioni (quest'ultime costano care al 6510!)

    'Prima cosa, mi porto appresso lo "status" del fantasma (è il numero dello sprite ma di fatto lo uso come variabile status)
    'Per onestà dirò che questa cosa la fa anche AGPX
    bThis_ShapeNumber = aMonsters(bMonsterNum).bShapeNumber
    
    'Mi porto poi dietro le coordinate pixel del fantasma, e isolo poi il contenuto degli ultimi 3 bit di ciascuna coordinata
    '(bit del 4 + bit del 2 + bit dell'1 = 7)
    iThis_Coord_X = aMonsters(bMonsterNum).iCoord_X 
    bThis_Coord_Y = aMonsters(bMonsterNum).bCoord_Y
    bHalfSprite_Coord_X = CBYTE(iThis_Coord_X AND 7)
    bHalfSprite_Coord_Y = bThis_Coord_Y AND 7
    
    'Questo è un modificatore del Delta per i fantasmi. Nel caso in cui il fantasma che viene ora gestito è "solo occhi" in fuga
    'verso la base, deve andarci di corsa. Questo però *solo* se il fantasma si trova su delle coordinate dai numeri pari.
    'Se non facessi questo controllo, il fantasma con ampia probabilità "uscirebbe dalla griglia" e prima o dopo sfonderebbe i muri
    'vagando all'infinito
    bStepMultiplier = 0
    'Formula un po' curiosa per verificare se entrambi i numeri delle coordinate sono pari. Se sì, il risultato finale sarà 1, sennò 0
    if bThis_ShapeNumber = 14 then bStepMultiplier = ((bHalfSprite_Coord_X OR bHalfSprite_Coord_Y) AND 1) XOR 1

    bDirectionToGo = aMonsters(bMonsterNum).bDirection 'si dà per scontato che il fantasma debba proseguire nella direzione attuale

    'Qui c'è un bivio FONDAMENTALE. Se il fantasma si sta spostando da una casella della Mappa all'altra, deve unicamente proseguire
    'nello spostamento. Non ci sono controlli né cambi di direzione
    if bHalfSprite_Coord_X OR bHalfSprite_Coord_Y then 'se questo fantasma non sta su una posizione multipla di 8...
        'ECCEZIONE! Qui viene verificato se il fantasma si trova davanti il cancello del recinto dei fantasmi.
        if iThis_Coord_X = 156 then 'coordinata pixel orizzontale del cancello del recinto fantasmi
            select case bThis_Coord_Y
                case 80 'coordinata pixel verticale del corridoio ALL'INTERNO del recinto fantasmi
                    bDirectionToGo = 0 'intanto si dà per scontato che il fantasma debba andare a nord (0), per uscire dal recinto
                    if bThis_ShapeNumber = 14 then 'se però questo fantasma è qui dentro con solo gli occhi (14), ALLORA deve ritornare normale
                        'Si reimpostano i parametri dei fantasmi normali
                        aMonsters(bMonsterNum).bShapeNumber = 12 '12 = forma del fantasma normale
                        aMonsters(bMonsterNum).bInitialMovementTimer = 4
                        aMonsters(bMonsterNum).bMovementTimer = 4
                        sprite bMonsterNum SHAPE 12 COLOR aMonsters(bMonsterNum).bOriginalColour 'rimette a posto forma e colore di partenza
                        'A seconda del numero identificativo del fantasma se è pari o dispari, andrà a sinistra oppure a destra
                        if (bMonsterNum AND 1) then bDirectionToGo = 1 else bDirectionToGo = 3 'est, ovest
                    end if
                case 64 'coordinata pixel verticale del corridoio ALL'ESTERNO del recinto fantasmi
                    if bDirectionToGo = 0 then 'Se questo fantasma sta andando a nord, vuol dire che è appena uscito dal recinto
                        'A seconda del numero identificativo del fantasma se è pari o dispari, andrà a sinistra oppure a destra
                        if (bMonsterNum AND 1) then bDirectionToGo = 1 else bDirectionToGo = 3 'est, ovest
                    else
                        'Se il fantasma è qui in modalità "solo occhi" (14) e quindi in fuga, deve scendere per "rigenerarsi"
                        if bThis_ShapeNumber = 14 then bDirectionToGo = 2 'ora andrà a sud
                    end if
            end select
        end if
        
        'Se questo fantasma è "spaventato" (13), allora si controlla quanto tempo manca a tornare normale
        if bThis_ShapeNumber = 13 then
            'Se mancano 120 fotogrammi o meno allo scadere del tempo...
            if game_iScaredTimer < 121 then
                'Si controlla il bit dell'8 se è acceso o spento, in base a quello si cambia il colore del fantasma.
                'Quel che si ottiene è il "lampeggìo" che avvisa il giocatore che il tempo sta per scadere
                if (game_iScaredTimer AND 8) = 0 then sprite bMonsterNum COLOR 15 else sprite bMonsterNum COLOR 6 'alterna fra grigio chiaro (15) e blu (6)
            end if
        end if
 
    else
        'Qui c'è la CICCIA vera, dove il fantasma prende le decisioni, essendo arrivato di preciso in una casella della Mappa di Gioco
        
        'Prima cosa viene reimpostato il timer del movimento, in modo che il fantasma sicuramente a questo giro si dovrà muovere e non fermare
        aMonsters(bMonsterNum).bMovementTimer = aMonsters(bMonsterNum).bInitialMovementTimer
        
        'Qui viene controllato se il fantasma si trova a uno degli estremi del corridoio "toroidale", e se sì, viene istantaneamente
        'trasportato alla parte opposta
        if iThis_Coord_X = 24 then
           iThis_Coord_X = 288
        else
            if iThis_Coord_X = 288 then
                iThis_Coord_X = 24
            end if
        end if
        'Qui vengono ricavate le coordinate di Mappa (non quelle a pixel) di questo fantasma.
        'Sostanzialmente si divide per otto, la qual cosa si fa velocemente se si fanno slittare _a destra_ di 3 posti i bit
        'che compongono il numero trattato
        iThis_Map_X = shr(iThis_Coord_X, 3) : bThis_Map_Y = shr(bThis_Coord_Y, 3)

        'Si "tiene a mente" la direzione opposta a quella in cui questo fantasma sta viaggiando
        bOppositeDirection = (bDirectionToGo + 2) AND 3

        'Qui entra il concetto di Casella Bersaglio, alla quale questo fantasma deve puntare. Questo è il "cuore decisionale"
        'che permette a ciascun fantasma di scegliere dove andare
        
        'Per default, un fantasma va addosso a Pacman. Questo è quello che fa Rosso, il fantasma 0
        iTargetTile_X = pacman_iMap_X
        bTargetTile_Y = pacman_bMap_Y
        select case bThis_ShapeNumber
            case 12
                'Casi specifici per quando il fantasma è nello status "normale" (12)
                select case bMonsterNum
                    'Il fantasma 1 (Ciano) punta a 8 caselle avanti a Pacman (nelle variabili Direction ci può essere uno 0 o
                    'un otto, di segno negativo o positivo)
                    case 1 
                        iTargetTile_X = pacman_iMap_X + pacman_iDirection_X
                        bTargetTile_Y = pacman_bMap_Y + pacman_bDirection_Y
                    'Il fantasma 2 (Rosa) punta a 8 caselle INDIETRO a Pacman
                    case 2
                        iTargetTile_X = pacman_iMap_X - pacman_iDirection_X
                        bTargetTile_Y = pacman_bMap_Y - pacman_bDirection_Y
                    'Il fantasma 3 (Arancio) è lo scemo del gruppo (così come nell'arcade originale):
                    'Generalmente punta anche lui addosso a Pacman come fa Rosso (fantasma 0), MA!
                    'Se ha una "distanza Manhattan" da lui più piccola di 12, scappa all'angolo in basso a sinistra della mappa!
                    case 3
                        iThis_Distance = ABS(CINT(pacman_bMap_Y) - CINT(bThis_Map_Y)) + ABS(pacman_iMap_X - iThis_Map_X)
                        if iThis_Distance < 12 then
                            iTargetTile_X = 4
                            bTargetTile_Y = 20
                        end if
                end select
                'Per sicurezza si controlla che la casella bersaglio finale non esca fuori dalla mappa...
                if iTargetTile_X < 3 then iTargetTile_X = 3
                if iTargetTile_X > 36 then iTargetTile_X = 36
                'Giacché le variabili BYTE non hanno segno, per testare se un valore è da considerare negativo si guarda se è 128 o più
                if bTargetTile_Y > 127 then bTargetTile_Y = 1
                if bTargetTile_Y > 20 then bTargetTile_Y = 20
            case 14
                'Casi per quando il fantasma è "solo occhi" (14)
                'Qui c'è un aiutino per far trovare meglio la strada per il cancello al fantasma. Probabilmente questa cosa nell'arcade
                'originale non c'è. Qui abbiamo una versione della mappa "allargata", per cui probabilmente
                'per quello c'è da fare del lavoro in più.
                
                'Se il fantasma di trova alla riga 8, cioè quella subito sopra il cancello...
                if bThis_Map_Y = 8 then
                    '... punta dritto alla casella direttamente sopra il cancello
                    iTargetTile_X = 19
                else
                    'Se si trova in altra parte, allora: se sta a sinistra del cancello, punta all'angolo sinistro del recinto,
                    'altrimenti punta all'angolo destro
                    if iThis_Map_X < 19 then iTargetTile_X = 14 else iTargetTile_X = 25
                end if
                'La riga è sempre la stessa, a prescindere dalla colonna
                bTargetTile_Y = 8
        end select
        
        'E' il momento di calcolare le distanze dai punti vicini al fantasma verso il Bersaglio!
        'Per cominciare, viene impostata la variabile che tiene la minor distanza trovata 
        'al valore massimo possibile che può esprimere una variabile INT
        iShortestDistance = 32767
        
        'E inizia il giro nelle 4 direzioni!
        for bThis_Direction = 0 to 3
            'Se questa direzione è quella opposta a quella attuale, non è da considerare.
            'La regola fondamentale è che un fantasma non torna MAI indietro mentre si muove! Altrimenti corre
            'l'alto rischio di rimanere bloccato in un punto facendo avanti e indietro di continuo
            if bThis_Direction = bOppositeDirection then continue for
            
            'Vengono prese le coordinate del punto adiacente a dove si trova il fantasma, lungo la direzione ora in esame
            iOffset_Map_X = iThis_Map_X + iDirections_X(bThis_Direction)
            bOffset_Map_Y = bThis_Map_Y + bDirections_Y(bThis_Direction)

            'Tutti i caratteri dal 32 al 47 sono considerati Muro, e se in questa adiacenza c'è un muro, la direzione viene saltata
            if (peek(wScreenTable(bOffset_Map_Y) + iOffset_Map_X) AND %00110000) = %00100000 then continue for
            
            'Il momento più pesante di tutta l'elaborazione: il calcolo della distanza.
            'Qui non si bada a spese, si scomoda il Teorema di Pitagora! Viene calcolata la distanza al QUADRATO facendo la
            'somma dei QUADRATI dei lati ad angolo retto di un ipotetico triangolo rettangolo.
            'Detti lati sono la differenza delle coordinate verticali e di quelle orizzontali fra l'adiacenza del fantasma e il bersaglio!
            iPartialDistance = ABS(CINT(bTargetTile_Y) - CINT(bOffset_Map_Y))
            iThis_Distance = iPartialDistance * iPartialDistance
            iPartialDistance = ABS(iTargetTile_X - iOffset_Map_X)
            iThis_Distance = iThis_Distance + (iPartialDistance * iPartialDistance)
            'Se questo fantasma è "spaventato" (13), la distanza così calcolata viene INVERTITA, usando il numero della distanza
            'al quadrato maggiore possibile (1424). Facendo così, il fantasma preferirà allontanarsi anziché avvicinarsi al bersaglio
            if bThis_ShapeNumber = 13 then iThis_Distance = 1424 - iThis_Distance

            'Se questa distanza è la minore finora trovata, questa direzione è papabile per la scelta
            if iThis_Distance < iShortestDistance then
                iShortestDistance = iThis_Distance
                bDirectionToGo = bThis_Direction
            end if
        next bThis_Direction
        
        'Nel caso in cui la distanza più corta sia ancora il numero massimo, significa che il fantasma è dentro il recinto.
        'SOLO in questo caso può fare dietrofront!
        if iShortestDistance = 32767 then bDirectionToGo = bOppositeDirection
        
    end if

    '**** Momento del rilevamento della collisione! ****
    'Qui c'è un'alta dose di pigrizia da parte mia, le variabili sono chiamate praticamente allo stesso modo del video linkato qui:
    'https://www.youtube.com/watch?v=LwMNPEG4OPo
    'Guardando la prima parte del video si capisce come funziona questa tecnica. Straordinaria per quanto è semplice!
    'E senza scomodare le collisioni del VIC-II, che notoriamente non servono a un beneamato tubo nella stragrande maggioranza dei casi  :-)
    'Sono intervenuto empiricamente sui numeri confrontati con xD e yD al fine di avere una rilevazione "clemente" delle collisioni
    dim FAST xD as INT, yD as INT FAST
    xD = ABS((iThis_Coord_X + 7) - (pacman_iCoord_X + 8))
    yD = ABS(CINT(bThis_Coord_Y + 7) - CINT(pacman_bCoord_Y + 8))
    if xD < 9 AND yD < 9 then
        select case bThis_ShapeNumber
            case 12
                'Se c'è collisione e il fantasma è "normale" (12), Pacman è considerato acchiappato
                game_bPacmanCaught = TRUE
            case 13
                'Se c'è collisione è il fantasma è "spaventato" (13), questo fantasma viene MANGIATO
                'Il suo status passa a 14 ("solo occhi"), il timer del movimento è "infinito" in modo che non si fermi mai
                aMonsters(bMonsterNum).bShapeNumber = 14 : sprite bMonsterNum SHAPE 14
                aMonsters(bMonsterNum).bInitialMovementTimer = 255
                aMonsters(bMonsterNum).bMovementTimer = 255
                'Vengono assegnati 500 punti.
                'Qui viene aggiunto "500d" non "500". Perché? Perché così funzionano le variabili DECIMAL,
                'che NON sono variabili che usano la virgola, bensì sono numeri decimali "incastrati" in valori esadecimali.
                'Quando il 6510 entra in modalità DECIMAL, lavora con i numeri in base 10 anziché base 16 come fa normalmente.
                'Questo velocizza sensibilmente i tempi di aggiornamento della variabile nonché della stampa a video. Per cui,
                'le variabili DECIMAL sono ottime per gestire e aggiornare a video i punteggi!
                game_dScore = game_dScore + 500d
                'Parte il suono del fantasma mangiato
                snd_bMonsterEaten_Timer = SND_MONSTER_EATEN_TIMER_START
                'Il punteggio viene aggiornato a schermo. Non è una cosa carina farlo qui e ripetere
                'la stessa riga di codice nella subroutine di Pacman per quando mangia le varie pillole, avrei dovuto fare una subroutine
                'dedicata, ma è sopravvenuto il timore che rallentasse il gioco... Per fortuna serve fare questa cosa solo due volte, amen
                textat 31, 24, game_dScore
        end select
    end if
    
    'Se il timer del movimento di questo fantasma è diverso da zero, allora si muove nella direzione calcolata (e nella velocità
    'individuata dal Multiplier). Il timer viene poi decrementato
    if aMonsters(bMonsterNum).bMovementTimer then
        aMonsters(bMonsterNum).iCoord_X = iThis_Coord_X + shl(iDirections_X(bDirectionToGo), bStepMultiplier)
        aMonsters(bMonsterNum).bCoord_Y = bThis_Coord_Y + shl(bDirections_Y(bDirectionToGo), bStepMultiplier)
        aMonsters(bMonsterNum).bMovementTimer = aMonsters(bMonsterNum).bMovementTimer - 1
    else
        'Altrimenti viene reimpostato il timer al valore di partenza, *senza* che il fantasma si sia mosso. L'effetto pratico è che
        'ogni fantasma si muove *leggermente* meno velocemente di Pacman
        aMonsters(bMonsterNum).bMovementTimer = aMonsters(bMonsterNum).bInitialMovementTimer       
    end if
    'Riscrive nell'array la direzione trovata, così da essere "ricordata" al prossimo giro
    aMonsters(bMonsterNum).bDirection = bDirectionToGo
end sub

'Routine per rendere tutti i fantasmi "normali" (status 12, e solo loro) dei fantasmi "spaventati" (status 13)
'Altra cosa poco ortodossa qui, il copia-e-incolla di uno stesso set di impostazioni ripetuto 3 volte, anziché
'fare un ciclo For o Do-While. Questa cosa si fa spesso in Assembly, in inglese si chiama "loop unrolling", cioè viene
'"srotolato" un loop ripetendo pedissequamente le operazioni che si sarebbero specificate una volta in un ciclo. Lo svantaggio è maggior
'memoria occupata (e anche più difficile manutenzione, ché se c'è un bug da una parte va ri-corretto dappertutto).
'Il vantaggio è una maggior velocità perché non si impiegano cicli di clock per gestire il loop.
'Da notare l'inversione di direzione, altra concessione fatta soltanto per questo passaggio di status.
'Portare il timer a 1 significa farli viaggiare a metà velocità
sub scareTheMonsters() STATIC
    if aMonsters(0).bShapeNumber = 12 then
        aMonsters(0).bDirection = (aMonsters(0).bDirection + 2) AND 3
        aMonsters(0).bShapeNumber = 13
        sprite 0 SHAPE 13
        aMonsters(0).bInitialMovementTimer = 1
        aMonsters(0).bMovementTimer = 1
    end if
    sprite 0 COLOR 6 'blu
    
    if aMonsters(1).bShapeNumber = 12 then
        aMonsters(1).bDirection = (aMonsters(1).bDirection + 2) AND 3
        aMonsters(1).bShapeNumber = 13
        sprite 1 SHAPE 13
        aMonsters(1).bInitialMovementTimer = 1
        aMonsters(1).bMovementTimer = 1
    end if
    sprite 1 COLOR 6 'blu
    
    if aMonsters(2).bShapeNumber = 12 then
        aMonsters(2).bDirection = (aMonsters(2).bDirection + 2) AND 3
        aMonsters(2).bShapeNumber = 13
        sprite 2 SHAPE 13 
        aMonsters(2).bInitialMovementTimer = 1
        aMonsters(2).bMovementTimer = 1
    end if
    sprite 2 COLOR 6 'blu
    
    if aMonsters(3).bShapeNumber = 12 then
        aMonsters(3).bDirection = (aMonsters(3).bDirection + 2) AND 3
        aMonsters(3).bShapeNumber = 13
        sprite 3 SHAPE 13
        aMonsters(3).bInitialMovementTimer = 1
        aMonsters(3).bMovementTimer = 1
    end if
    sprite 3 COLOR 6 'blu
    
    'Parte il timer per la durata dell'effetto energizzante!
    game_iScaredTimer = 350 '7 secondi * 50 frame/sec = 350
    snd_bPowerDotEaten_Timer = SND_POWERDOT_EATEN_TIMER_START
end sub

'Funzione opposta a quella sopra, esclusivamente per i fantasmi che sono "spaventati" (13)
'Anche qui avrei dovuto usare quantomeno delle costanti per i valori dei timer, la pigrizia che mi vizia
sub restoreTheMonsters() STATIC
    if aMonsters(0).bShapeNumber = 13 then
        aMonsters(0).bShapeNumber = 12
        aMonsters(0).bInitialMovementTimer = 4
        aMonsters(0).bMovementTimer = 4
        sprite 0 SHAPE 12 COLOR aMonsters(0).bOriginalColour
    end if
    
    if aMonsters(1).bShapeNumber = 13 then
        aMonsters(1).bShapeNumber = 12
        aMonsters(1).bInitialMovementTimer = 4
        aMonsters(1).bMovementTimer = 4
        sprite 1 SHAPE 12 COLOR aMonsters(1).bOriginalColour
    end if
    
    if aMonsters(2).bShapeNumber = 13 then
        aMonsters(2).bShapeNumber = 12
        aMonsters(2).bInitialMovementTimer = 4
        aMonsters(2).bMovementTimer = 4
        sprite 2 SHAPE 12 COLOR aMonsters(2).bOriginalColour
    end if
    
    if aMonsters(3).bShapeNumber = 13 then
        aMonsters(3).bShapeNumber = 12
        aMonsters(3).bInitialMovementTimer = 4
        aMonsters(3).bMovementTimer = 4
        sprite 3 SHAPE 12 COLOR aMonsters(3).bOriginalColour
    end if

end sub

'Ed eccoci arrivati alla subroutine della gestione di Pacman, ovvero del giocatore!
sub updatePacman() STATIC
    Dim bJoy2 as BYTE
    Dim wPacmanAddress as WORD
    'Banalmente, per prima cosa, si legge il Joystick dalla porta 2
    bJoy2 = JOY(2)
    
    'Se Pacman non sta sulla Mappa su una posizione multipla di 8...
    if (pacman_iCoord_X AND 7) <> 0 OR (pacman_bCoord_Y AND 7) then
        'Anche qui, come coi fantasmi, non vengono fatti controlli sui Muri, Pacman *deve* spostarsi da una casella all'altra.
        'Unica concessione: il poter tornare indietro. Quando il joystick viene mosso, viene controllato se è stato mosso nella direzione
        'opposta rispetto a prima. Altrimenti, Pacman procede fino alla casella di destinazione senza fermarsi o altro
        if (bJoy2 AND 4) AND pacman_iDelta_X = 1 then pacman_iDelta_X = -1 
        if (bJoy2 AND 8) AND pacman_iDelta_X = -1 then pacman_iDelta_X = 1 
        if (bJoy2 AND 1) AND pacman_bDelta_Y = 1 then pacman_bDelta_Y = CBYTE(-1)
        if (bJoy2 AND 2) AND pacman_bDelta_Y = CBYTE(-1) then pacman_bDelta_Y = 1
    else
        'E qui si entra nella CICCIA per Pacman

        'La prima cosa che viene controllata è se il joystick è stato mosso in diagonale mentre Pacman si sta spostando.
        'Se così è, si fa finta che il joystick non sia mai stato mosso. Si simula insomma un joystick che non è capace di
        'trasmettere movimenti in diagonale (non escludo che il joystick usato nell'arcade fosse impossibilitato a livello hardware)
        if (bJoy2 AND 12) <> 0 AND (bJoy2 AND 3) <> 0 AND (pacman_iDelta_X <> 0 OR pacman_bDelta_Y) then bJoy2 = 0
        
        'Anche qui, come coi fantasmi, viene gestito l'ingresso nel corridoio "toroidale"
        'Qui pure avrei dovuto fare una funzione apposta, ma la pigrizia ecc. ecc.
        if pacman_iCoord_X = 24 then
           pacman_iCoord_X = 288
        else
            if pacman_iCoord_X = 288 then
                pacman_iCoord_X = 24
            end if
        end if
        
        'Qui si ricavano le coordinate di Mappa da quelle di sprite (anche qui, per dividere per 8 si fanno scorrere a destra
        'i bit 3 volte)
        pacman_iMap_X = shr(pacman_iCoord_X, 3) : pacman_bMap_Y = shr(pacman_bCoord_Y, 3)

        'Si ricava l'indirizzo di memoria dalle coordinate di Mappa
        wPacmanAddress = wScreenTable(pacman_bMap_Y) + pacman_iMap_X
        'Se dove si trova Pacman c'è un carattere con codice 30 o 31, vuol dire che sta su una pillola (energizzante o meno)
        if (peek(wPacmanAddress) AND %11111110) = 30 then
            'Si scala di 1 il conteggio delle pillole totali da mangiare ancora
            game_iDotsToEat = game_iDotsToEat - 1
            'Si danno 10 punti
            game_dScore = game_dScore + 10d
            'Se poi la pillola mangiata era energizzante...
            if peek(wPacmanAddress) = 30 then
                'Tutti i fantasmi spaventabili si spaventano
                call scareTheMonsters()
                'Si aggiungono altri 40 punti (quindi una pillola energizzante dà 50 punti)
                game_dScore = game_dScore + 40d
            end if
            'Si aggiorna il punteggio! (Come ho detto già nella routine per i fantasmi, ortodosso sarebbe stato fare una subroutine apposita)
            textat 31, 24, game_dScore
            'Si sostituisce il carattere della pillola con uno spazio vuoto percorribile (il carattere 32 pure è uno spazio, ma è considerato Muro)
            poke wPacmanAddress, 29
            'Parte il suono della pillola mangiata
            snd_bDotEaten_Timer = SND_DOT_EATEN_TIMER_START
        end if

        'Qui finalmente si dà retta al joystick, e si regolano le variabili Delta in base a come è stato mosso
        if (bJoy2 AND 1) then 'Bit #0 è 1 se il joystick è mosso in alto
            pacman_bDelta_Y = CBYTE(-1)
        end if 
        if (bJoy2 AND 2) then 'Bit #1 è 1 se il joystick è mosso in basso
            pacman_bDelta_Y = 1
        end if                
        if (bJoy2 AND 4) then 'Bit #2 è 1 se il joystick è mosso a sinistra
            pacman_iDelta_X = -1
        end if
        if (bJoy2 AND 8) then 'Bit #3 è 1 se il joystick è mosso a destra
            pacman_iDelta_X = 1
        end if
        
        'Se lungo la direzione orizzontale indicata dal joystick c'è un muro, quel movimento viene annullato
        if (peek(wPacmanAddress + pacman_iDelta_X) AND %00110000) = %00100000 then pacman_iDelta_X = 0
        'Stessa cosa per la direzione verticale
        if (peek(wScreenTable(pacman_bMap_Y + pacman_bDelta_Y) + pacman_iMap_X) AND %00110000) = %00100000 then pacman_bDelta_Y = 0
        
        'Se è possibile muoversi in diagonale...
        if pacman_iDelta_X <> 0 AND pacman_bDelta_Y then
            'Se il joystick è stato mosso orizzontalmente, viene annullato il movimento verticale
            if (bJoy2 AND 12) then pacman_bDelta_Y = 0
            'E viceversa
            if (bJoy2 AND 3)  then pacman_iDelta_X = 0
            'POTREBBE ESSERE che questa parte sia inutile... Resa inutile dal fatto che i movimenti diagonali sono annullati più sopra
        end if

    end if
    
    'Finalmente Pacman si muove
    pacman_iCoord_X = pacman_iCoord_X + pacman_iDelta_X
    pacman_bCoord_Y = pacman_bCoord_Y + pacman_bDelta_Y

    'Parte dedicata all'animazione! Viene scelto il fotogramma successivo
    'Non a caso queste due istruzioni sono scritte così. Il compilatore di XCB ha un'ottimizzazione per cui se l'incremento
    'o il decremento di una variabile BYTE è di uno, nella compilazione viene scelta l'istruzione 6510 "INC" o "DEC" anziché la sequenza
    '"LDA #<numero>", "ADC/SBC #<numero>", "STA $locazione". Ho verificato che scrivendo le istruzioni così la memoria occupata scende
    pacman_bSpriteFrameNumber = pacman_bSpriteFrameNumber + 1 : pacman_bSpriteFrameNumber = pacman_bSpriteFrameNumber AND 7
    
    'A seconda di come dovrà essere orientato Pacman, si aggiornano le variabili Direction (usate dai fantasmi) e quella per lo sprite "base"
    select case pacman_bDelta_Y
        case 255 '-1
            pacman_bSpriteNumber = 9 'Sprite a nord
            pacman_bDirection_Y = CBYTE(-8)
            pacman_iDirection_X = 0
        case 0
            select case pacman_iDelta_X
                case -1
                    pacman_bSpriteNumber = 3 'Sprite a ovest
                    pacman_bDirection_Y = 0
                    pacman_iDirection_X = -8
                case 0
                    pacman_bSpriteFrameNumber = 0 'Reimposta il primo frame a zero (bocca chiusa)
                case 1
                    pacman_bSpriteNumber = 0 'Sprite a est
                    pacman_bDirection_Y = 0
                    pacman_iDirection_X = 8
            end select
        case 1
            pacman_bSpriteNumber = 6 'sprite a sud
            pacman_bDirection_Y = 8
            pacman_iDirection_X = 0
    end select
end sub

'Qui mi sono degnato di fare una subroutine per aggiornare il posizionamento di tutti gli sprite.
'Vengono posizionati tenendo conto degli offset curiosi tipici degli sprite del C64, cioè il minimo di 24 sull'asse orizzontale,
'il minimo di 50 su quello verticale. Vengono però tolti alcuni pixel per centrare gli sprite nei corridoi della mappa!
'+21 anziché +24 (-3), +48 anziché +50 (-2)
sub drawActors() STATIC
    sprite 0 at aMonsters(0).iCoord_X + 21, aMonsters(0).bCoord_Y + 48
    sprite 1 at aMonsters(1).iCoord_X + 21, aMonsters(1).bCoord_Y + 48
    sprite 2 at aMonsters(2).iCoord_X + 21, aMonsters(2).bCoord_Y + 48
    sprite 3 at aMonsters(3).iCoord_X + 21, aMonsters(3).bCoord_Y + 48
    sprite 7 shape pacman_bSpriteNumber + bFrameAnimNumber(pacman_bSpriteFrameNumber) AT pacman_iCoord_X + 21, pacman_bCoord_Y + 48
end sub

'Subroutine per il lampeggìo delle pillole energizzanti. Il timer in questo caso non è mai inizializzato a un valore specifico
'perché alla fine quel che interessa sono gli ultimi 3 bit (4 + 2 + 1 = 7)
sub animatePowerPellets() STATIC
    if (game_bPowerPelletAnimTimer AND 7) then
    else
        'dire XOR 3 significa di fatto "alterna fra 3 e 0", cioè fra ciano e nero
        poke $D87C, peek( $D87C) XOR 3
        poke $D89B, peek( $D89B) XOR 3
        poke $DA84, peek( $DA84) XOR 3
        poke $DAA3, peek( $DAA3) XOR 3
    end if
    game_bPowerPelletAnimTimer = game_bPowerPelletAnimTimer - 1
end sub

'Si copia a video la parte a caratteri della Mappa
sub resetGameMap() STATIC
    memcpy @pacScreen, $8400, @pacScreenColor - @pacScreen
end sub

'Si copia a video la parte a colori della Mappa
sub resetGameMapColours() STATIC
    memcpy @pacScreenColor, $D800, @pacCharset - @pacScreenColor
end sub

'Attende il passaggio del numero di frame specificato.
'Scan() restituisce il numero di riga che in quel momento si sta aggiornando sullo schermo
'Anche 220 doveva essere una costante.....
sub waitForNextFrame(bFrameQuantity as BYTE) STATIC
    do
        do until scan() < 220  : loop
        do until scan() >= 220 : loop
        bFrameQuantity = bFrameQuantity - 1
    loop while bFrameQuantity
end sub

'Attende che il joystick venga azionato (sia la leva che il pulsante di fuoco)
'Qui viene fatto quello che in inglese si chiama "de-bouncing": un primo loop esce
'solo quando il joystick è in posizione neutra. L'altro esce quando viene azionato il joystick.
'Questo viene fatto per evitare che movimenti precedenti facciano saltare accidentalmente dei messaggi o simile
sub waitForJoystick() STATIC
    do while JOY(2) : loop
    do until JOY(2) : loop
end sub

'Effetto lampeggiante per quando Pacman compare sulla scena
sub pacmanAppears() STATIC
    'prima di scrivere "ready!", mi salvo quello che c'è sotto...
    memcpy $85F1, $0400, 6 'la memoria "classica" del video è ora a disposizione come area d'appoggio
    textat 17, 12, "ready{92}", 7 'giallo - al carattere "£" (ASCII 92) c'è ridisegnato il punto esclamativo
    
    sprite 7 SHAPE 4 'la forma 4 è Pacman rivolto a sinistra con la bocca semi-aperta
    VOICE 1 ADSR 0, 0, 15, 9  WAVE PULSE  PULSE 2048 TONE 10000  ON  OFF
    For bAnimFrameCounter = 1 to 21
        if (bAnimFrameCounter AND 1) then
            sprite 7 ON
        else
            sprite 7 OFF
        end if
        call waitForNextFrame(2)
    next bAnimFrameCounter
    
    memset $D9F1, 6, 15 'si rimette a posto il colore grigio chiaro dei "puntini" da mangiare
    memcpy $0400, $85F1, 6 'si rimettono a posto gli effettivi "puntini" che c'erano prima
end sub

'Effetto lampeggiante per quando Pacman muore (praticamente è l'opposto della routine sopra)
sub pacmanDies() STATIC
    VOICE 1 OFF
    VOICE 3 OFF
    
    VOICE 2 OFF  ADSR 0, 0, 15, 9  WAVE PULSE  PULSE 2048  TONE 1250  ON  OFF
    
    For bAnimFrameCounter = 1 to 21
        if (bAnimFrameCounter AND 1) then
            sprite 7 OFF
        else
            sprite 7 ON
        end if
        call waitForNextFrame(2)
    next bAnimFrameCounter

    call waitForNextFrame(30)
end sub

'Replica dall'arcade dell'effetto sulla mappa quando tutte le pillole sono state mangiate
'Il labirinto vuoto lampeggia di bianco e di blu per alcune volte
sub levelCompleted() STATIC
    'spegne tutti i suoni
    VOICE 1 OFF
    VOICE 2 OFF
    VOICE 3 OFF
    call waitForNextFrame(90)
    
    'spegne tutti i fantasmi
    sprite 0 OFF
    sprite 1 OFF
    sprite 2 OFF
    sprite 3 OFF
    for bAnimFrameCounter = 1 to 10
        if (bAnimFrameCounter AND 1) then
            memset $D800, 880, 1 'colora la mappa di bianco
        else
            memset $D800, 880, 6 'colora la mappa di blu
        end if
        call waitForNextFrame(15)
    next bAnimFrameCounter
    
    call waitForNextFrame(75)
end sub

'Schermo dei titoli!
sub titleScreen() STATIC
    memset $D800, 880, 6 'imposta i caratteri tutti blu
    call resetGameMap()
    
    textat 15, 4, "jj pacman{92}", 1 'bianco - ASCII 92 "£" ridisegnato come punto esclamativo
    
    textat 10, 8, "graphics  and map by", 1 'bianco
    textat 14, 9, "agpx@itch{95}io", 7 'giallo - ASCII 95 (freccia a sinistra) ridisegnato come "dot" da mangiare
    
    textat 6, 11, "additional graphics and code", 1 'bianco
    textat 6, 12, "rewriting by ", 1 'bianco
    textat 19, 12, "jjflash@itch{95}io", 7 'giallo - ASCII 95 (freccia a sinistra) ridisegnato come "dot" da mangiare
    
    textat 7, 14, "xc basic 3 by ", 1 'bianco
    textat 21, 14, "csaba fekete", 7 'giallo
    textat 14, 15, "xc-basic{95}net", 5 'verde
    
    textat 5, 18, "use joystick in port 2 to play", 3 'ciano
    
    textat 31, 21, "rev01", 11 'grigio scuro - revisione 1, con una sentita pernacchia ai cosiddetti "cracker"
    
    call waitForJoystick()
end sub

call titleScreen()

'Queste scritte rimarranno lì per tutta la vita del gioco in memoria
textat 5, 23, "tries", 7 'giallo
textat 30, 23, "score", 13 'verde chiaro

do 'loop di *** INIZIO PARTITA ***
    'Tre "vite" a Pacman, si riazzera il punteggio, si imposta la quantità di pillole da mangiare
    game_bPacmanTries = 3
    game_dScore = 0d
    game_iDotsToEat = DOTS_NUM

    'si (ri)disegna la mappa
    call resetGameMapColours()
    call resetGameMap()
    textat 31, 24, game_dScore, 1 'bianco
    
    do 'loop di ** INIZIO TENTATIVO (VITA) **
        'Pacman vive, nessun fantasma spaventato
        game_bPacmanCaught = FALSE
        game_iScaredTimer = 0
        
        'si reimpostano fantasmi e Pacman
        call resetMonsters()
        call resetPacman()
        
        'Si scrive il numero dei tentativi rimasti
        textat 7, 24, game_bPacmanTries, 1 'bianco
        
        'si mostrano già gli "attori" sulla scena, perché Pacman deve fare la sua scena comparendo
        call drawActors()
        call pacmanAppears()
        
        'suoni (re)inizializzati
        call initSounds()
        
        'ci si sincronizza col primo frame utile
        call waitForNextFrame(1)

        do 'loop **** PRINCIPALE! **** -----------------------------------------------------------------------------------------
            'bShortFrame risolve un problema che mi ha preso praticamente una giornata intera.
            'Visti i calcoli pesanti che ho scelto di far fare ai fantasmi per muoversi meglio nel labirinto, può capitare
            'abbastanza facilmente che, arrivato il frame successivo, i calcoli non siano ancora finiti. Sforando il limite, si perde
            'un frame, una cosa intollerabile visto che AGPX era arrivato a togliere uno dei 4 fantasmi pur di non far mai accadere questo.
            '
            'La risposta mia è segnarmi se, arrivato il turno dell'ultimo fantasma, si è già scavallato al frame successivo o meno. Se così
            'non è, bShortFrame resta TRUE. Altrimenti diventa FALSE.
            'E in quest'ultimo caso, *non viene atteso che arrivi il frame successivo*. Si attende solo che si arrivi alla linea 220. Se
            'si è sforato con i calcoli, il fotogramma successivo inizierà i calcoli *con ritardo*. Ma siccome è garantito (da mie prove
            'empiriche) che il frame successivo sarà ben più leggero del precedente, i tempi si rifaseranno e a schermo non si noterà nulla.
            'Tranne se si gioca in NTSC, dove si noterà comunque un lieve effetto di distorsione su Pacman

            bShortFrame = TRUE
            
            call drawActors()
            call animatePowerPellets()
          
            call soundHandler()

            call updateMonster(0)
            call updateMonster(1)
            call updateMonster(2)

            if scan() < 220 then bShortFrame = FALSE
            call updateMonster(3)
            if scan() < 220 then bShortFrame = FALSE

            if game_bPacmanCaught then exit do '-----USCITA ANTICIPATA PER PACMAN ACCHIAPPATO!
            call updatePacman()

            'Timer per la durata dell'effetto della pillola energizzante
            if game_iScaredTimer <> 0 then
                game_iScaredTimer = game_iScaredTimer - 1
                if game_iScaredTimer = 0 then call restoreTheMonsters()
            end if
            
            'Si attende il frame successivo soltanto se si sono completati i calcoli per tempo
            if bShortFrame then
                do until scan() < 220 : loop
            end if

            do until scan() >= 220 : loop 
  
        'fin quando ci sono pillole da mangiare...
        loop until game_iDotsToEat = 0 'FINE loop **** PRINCIPALE! **** -------------------------------------------------------------
        
        'Se Pacman è stato catturato, "muore" e uno dei tentativi va perso
        if game_bPacmanCaught then
            call pacmanDies()
            game_bPacmanTries = game_bPacmanTries - 1
        else
            'Altrimenti tutte le pillole sono state mangiate, livello completato! Si rimette poi tutto a posto...
            call levelCompleted()
            game_iDotsToEat = DOTS_NUM
            call resetGameMapColours()
            call resetGameMap()
        end if
    
    'finché ci sono tentativi disponibili, si va avanti    
    loop while game_bPacmanTries '---FINE--- loop di ** INIZIO TENTATIVO (VITA) **
    
    textat 7, 24, game_bPacmanTries 'giusto per scrivere "0" nei Tries e far capire perché è game over...
    textat 15, 8, "game  over", 2 'rosso
    textat 13, 12, "try once more{92}", 3 'ciano - ASCII 92 - "£" ridefinita a punto esclamativo
    
    call waitForJoystick()

loop '---FINE--- loop di *** INIZIO PARTITA ***

'.........................................................................

'DATI IN BINARIO IMPORTATI CON incbin
pacScreen:
incbin "pacMap.bin"
pacScreenColor:
incbin "pacMapColour.bin"
pacCharset:
incbin "pacChars.bin"
pacSprites:
incbin "pacSprites.bin"
endOfData:

'.........................................................................

