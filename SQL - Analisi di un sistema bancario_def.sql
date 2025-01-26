/*Tabella 0 - BASE - banca.codice_cliente
Dal momento che tutta l'analisi deve essere riferita al singolo id_cliente ho creato una tabella temporanea banca.codice_cliente che connette
la tabella 'cliente' con la tabella 'conto', la tabella conto infatti è il punto di contatto per la maggior parte delle analisi.
- la tabella 'cliente' contiene l'ID di tutti clienti 
- la tabella 'conto' contiene ID_CONTO e ID_TIPO_CONTO 
*/
create temporary table banca.codice_cliente as
select clt.id_cliente, cnt.id_conto, cnt.id_tipo_conto
from banca.cliente clt
left join banca.conto cnt on clt.id_cliente=cnt.id_cliente;

/*Tabella 1 - ETA - banca.tab_eta 
Calcola l'età dei clienti partendo dalla data odierna
*/
create temporary table banca.tab_eta as
select id_cliente,
timestampdiff(year, data_nascita, current_date()) eta
from banca.cliente;

/*Tabella 2 - NUMERO TRANSAZIONI IN USCITA SU TUTTI I CONTI - banca.tab_n_trz_uscita
Partendo dalla tabella 0 e unendo la tabella 'transazioni', conta il numero di transazioni con importo minore uguale a zero per tutti i conti
*/
create temporary table banca.tab_n_trz_uscita as
select ccli.id_cliente, 
count(case when trz.importo <= 0 then 1 else null end) n_trz_uscita
from banca.codice_cliente ccli
left join banca.transazioni trz on ccli.id_conto=trz.id_conto
group by 1;

/*Tabella 3  - NUMERO TRANSAZIONI IN ENTRATA SU TUTTI I CONTI - banca.tab_n_trz_entrata
Partendo dalla tabella 0 e unendo la tabella 'transazioni' conta il numero di transazioni con importo maggiore di zero per tutti i conti 
*/
create temporary table banca.tab_n_trz_entrata as
select ccli.id_cliente,
count(case when importo >0 then 1 else null end) as n_trz_entrata
from banca.codice_cliente ccli
left join banca.transazioni trz on ccli.id_conto=trz.id_conto
group by 1;

/*Tabella 4 - IMPORTO TRANSATO IN USCITA SU TUTTI I CONTI - banca.tab_tot_trz_uscita
Partendo dalla tabella 0 e unendo la tabella 'transazioni' calcola l'importo totale delle transazioni con importo minore o uguale a zero per tutti i conti.
L'importo è arrotondato a 2 cifre decimali. 
*/
create temporary table banca.tab_tot_trz_uscita as
select ccli.id_cliente,
round(sum(case when importo<=0 then importo else 0 end),2) as tot_trz_uscita
from banca.codice_cliente ccli
left join banca.transazioni trz on ccli.id_conto=trz.id_conto
group by 1;

/*Tabella 5 - IMPORTO TRANSATO IN ENTRATA SU TUTTI I CONTI - banca.tab_tot_trz_entrata
Partendo dalla tabella 0 e unendo la tabella 'transazioni' calcola l'importo totale delle transazioni con importo maggiore di zero per tutti i conti.
L'importo è arrotondato a 2 cifre decimali. 
*/
create temporary table banca.tab_tot_trz_entrata as
select ccli.id_cliente,
round(sum(case when importo>0 then importo else 0 end),2) as tot_trz_entrata
from banca.codice_cliente ccli
left join banca.transazioni trz on ccli.id_conto=trz.id_conto
group by 1;

/*Tabella 6 - NUMERO TOTALE DI CONTI POSSEDUTI - banca.tab_tot_conti
Utilizza solo la tabella 0 per contare il numero di conti per ogni id_cliente
*/
create temporary table banca.tab_tot_conti as
select ccli.id_cliente,
count(id_conto) as tot_num_conti
from banca.codice_cliente ccli
group by 1;

/* Tabella 7 - NUMERO TOTALE DI CONTI POSSEDUTI PER TIPOLOGIA - banca.tab_typ_conti
Utilizza solo la tabella 0 per contare i conti per ogni cliente raggrupprandoli per tipologia di conto. Gli alias sono attribuiti sulla base della descrizione
contenuta nella tabella tipo_conto che però non viene utilizzata.
*/
create temporary table banca.tab_typ_conti as
select ccli.id_cliente,
count(case when ccli.id_tipo_conto=0 then ccli.id_tipo_conto else null end) ntot_conto_base,
count(case when ccli.id_tipo_conto=1 then ccli.id_tipo_conto else null end) ntot_conto_business,
count(case when ccli.id_tipo_conto=2 then ccli.id_tipo_conto else null end) ntot_conto_privati,
count(case when ccli.id_tipo_conto=3 then ccli.id_tipo_conto else null end) ntot_conto_famiglie
from banca.codice_cliente ccli
group by 1;

/*Tabella 8 - NUMERO DI TRANSAZIONI IN USCITA PER TIPOLOGIA - banca.tab_typ_trz_uscita
Partendo dalla tabella 0 e unendo la tabella 'transazioni' conta il numero di transazioni e le raggruppa per tipologia.
Le transazioni considerate (con importo minore o uguale a zero) e gli alias sono attribuiti sulla base del segno e della descrizione nella tabella 'tipo_transazione' 
*/
create temporary table banca.tab_typ_trz_uscita as
select ccli.id_cliente,
count(case when id_tipo_trans=3 then id_tipo_trans else null end) ntrz_u_Acquisto_Amazon,
count(case when id_tipo_trans=4 then id_tipo_trans else null end) ntrz_u_Rata_mutuo,
count(case when id_tipo_trans=5 then id_tipo_trans else null end) ntrz_u_Hotel,
count(case when id_tipo_trans=6 then id_tipo_trans else null end) ntrz_u_Biglietto_aereo,
count(case when id_tipo_trans=7 then id_tipo_trans else null end) ntrz_u_Supermercato
from banca.codice_cliente ccli
left join banca.transazioni trz on ccli.id_conto = trz.id_conto
group by 1;

/*Tabella 9 - NUMERO DI TRANSAZIONI IN ENTRATA PER TIPOLOGIA - banca.tab_typ_trz_entrata
Partendo dalla tabella 0 e unendo la tabella 'transazioni' conta il numero di transazioni e le raggruppa per tipologia.
Le transazioni considerate (con importo maggiore di zero) e gli alias sono attribuiti sulla base del segno e della descrizione nella tabella 'tipo_transazione' 
*/
create temporary table banca.tab_typ_trz_entrata as
select ccli.id_cliente,
count(case when id_tipo_trans=0 then id_tipo_trans else null end) ntrz_e_Stipendio,
count(case when id_tipo_trans=1 then id_tipo_trans else null end) ntrz_e_Pensione,
count(case when id_tipo_trans=2 then id_tipo_trans else null end) ntrz_e_Dividendi
from banca.codice_cliente ccli
left join banca.transazioni trz on ccli.id_conto = trz.id_conto
group by 1;

/*Tabella 10 - IMPORTO TRANSATO IN USCITA PER TIPOLOGIA DI CONTO - banca.tab_uscite_typ_cnt
Partendo dalla tabella 0 e unendo la tabella 'transazioni' calcoliamo il totale delle transazioni con importo minore o ugale a zero.
La case when verifica che l'importo sia <= a zero, se la condione è vera allora verifica l'id_tipo_conto e restituisce l'importo. Si procede poi alla somma 
dell'importo restituito e all'arrotondamento a 2 cifre decimali. Se le condizione sono false restituisce zero.
 */
create temporary table banca.tab_uscite_typ_cnt as
select ccli.id_cliente,
round(sum(case when importo <=0 then (case when ccli.id_tipo_conto=0 then trz.importo else 0 end) else 0 end),2) imp_u_conto_base,
round(sum(case when importo <=0 then (case when ccli.id_tipo_conto=1 then trz.importo else 0 end) else 0 end),2) imp_u_conto_business,
round(sum(case when importo <=0 then (case when ccli.id_tipo_conto=2 then trz.importo else 0 end) else 0 end),2) imp_u_conto_privati,
round(sum(case when importo <=0 then (case when ccli.id_tipo_conto=3 then trz.importo else 0 end) else 0 end),2) imp_u_conto_famiglie
from banca.codice_cliente ccli
left join banca.transazioni trz on ccli.id_conto=trz.id_conto
group by 1;

/*Tabella 11 - IMPORTO TRANSATO IN ENTRATA PER TIPOLOGIA DI CONTO - banca.tab_entrate_typ_cnt
Partendo dalla tabella 0 e unendo la tabella 'transazioni' calcoliamo il totale delle transazioni con importo maggiore di zero.
La case when verifica che l'importo sia > di zero, se la condione è vera allora verifica l'id_tipo_conto e restituisce l'importo. Si procede poi alla somma 
dell'importo restituito e all'arrotondamento a 2 cifre decimali. Se le condizione sono false restituisce zero.
*/
create temporary table banca.tab_entrate_typ_cnt as
select ccli.id_cliente,
round(sum(case when importo >0 then (case when ccli.id_tipo_conto=0 then trz.importo else 0 end) else 0 end),2) imp_e_conto_base,
round(sum(case when importo >0 then (case when ccli.id_tipo_conto=1 then trz.importo else 0 end) else 0 end),2) imp_e_conto_business,
round(sum(case when importo >0 then (case when ccli.id_tipo_conto=2 then trz.importo else 0 end) else 0 end),2) imp_e_conto_privati,
round(sum(case when importo >0 then (case when ccli.id_tipo_conto=3 then trz.importo else 0 end) else 0 end),2) imp_e_conto_famiglie
from banca.codice_cliente ccli
left join banca.transazioni trz on ccli.id_conto=trz.id_conto
group by 1;

/*Query finale - ANALISI DENORMALIZZATA
La query finale unisce tutte le 11 tabelle precedenti ad eccezione della tabella zero che serviva solo come base per la creazione delle altre tabelle.
Partendo dalla tabella 1 - Eta, si uniscono tramite left join tutte le altre fino a formare una tabella denormalizzata.
 */
SELECT
e.id_cliente, e.eta,
ntu.n_trz_uscita,
nte.n_trz_entrata,
ttu.tot_trz_uscita,
tte.tot_trz_entrata,
tc.tot_num_conti,
tpc.ntot_conto_base, tpc.ntot_conto_business, tpc.ntot_conto_privati, tpc.ntot_conto_famiglie,
tytu.ntrz_u_acquisto_amazon, tytu.ntrz_u_rata_mutuo, tytu.ntrz_u_biglietto_aereo, tytu.ntrz_u_hotel, tytu.ntrz_u_supermercato,
tyte.ntrz_e_stipendio, tyte.ntrz_e_pensione, tyte.ntrz_e_dividendi,
utc.imp_u_conto_base, utc.imp_u_conto_business, utc.imp_u_conto_privati, utc.imp_u_conto_famiglie,
etc.imp_e_conto_base, etc.imp_e_conto_business, etc.imp_e_conto_privati, etc.imp_e_conto_famiglie

FROM banca.tab_eta E

left join banca.tab_n_trz_uscita NTU on e.id_cliente=ntu.id_cliente
left join banca.tab_n_trz_entrata NTE on e.id_cliente=nte.id_cliente
left join banca.tab_tot_trz_uscita TTU on e.id_cliente=ttu.id_cliente
left join banca.tab_tot_trz_entrata TTE on e.id_cliente=tte.id_cliente
left join banca.tab_tot_conti TC on e.id_cliente=tc.id_cliente
left join banca.tab_typ_conti TPC on e.id_cliente=tpc.id_cliente
left join banca.tab_typ_trz_uscita TYTU on e.id_cliente=tytu.id_cliente
left join banca.tab_typ_trz_entrata TYTE on e.id_cliente=tyte.id_cliente
left join banca.tab_uscite_typ_cnt UTC on e.id_cliente=utc.id_cliente
left join banca.tab_entrate_typ_cnt ETC on e.id_cliente=etc.id_cliente;

