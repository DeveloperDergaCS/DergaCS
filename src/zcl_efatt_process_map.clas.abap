class ZCL_EFATT_PROCESS_MAP definition
  public
  final
  create public .

*"* public components of class ZCL_EFATT_PROCESS_MAP
*"* do not include other source files here!!!
public section.
  type-pools MMCR .
  type-pools MRM .

  interfaces ZIF_EFATT_PROCESS_MAP .

  data BADI_PROCESS_MAP type ref to ZEFATT_BADI_PROCESS_MAP .
protected section.
*"* protected components of class ZCL_EFATT_PROCESS_MAP
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_EFATT_PROCESS_MAP
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_EFATT_PROCESS_MAP IMPLEMENTATION.


METHOD zif_efatt_process_map~process_map_incoming_invoice.

  TYPES: BEGIN OF lty_vat_code,
           aliquota    TYPE zefatt_aliquota,
           natura      TYPE zit_natura,
           esigibilita TYPE zefatt_esigibilita,
           count       TYPE i,
         END OF lty_vat_code.

  DATA: lv_xblnr          TYPE xblnr,
        lv_xabln          TYPE xabln,
        lv_len            TYPE i,
        ls_rbsellifs      TYPE rbsellifs,
        lt_rbsellifs      TYPE STANDARD TABLE OF rbsellifs,
        ls_rbselbest      TYPE rbselbest,
        lt_rbselbest      TYPE STANDARD TABLE OF rbselbest,
        ls_rbkpv          TYPE mrm_rbkpv,
        lt_drseg          TYPE TABLE OF mmcr_drseg,
        lt_drseg_old      TYPE TABLE OF mmcr_drseg,
        lt_rbselfrbr      TYPE TABLE OF rbselfrbr,
        lt_rbselwerk      TYPE TABLE OF rbselwerk,
        lt_rbselerfb      TYPE TABLE OF rbselerfb,
        lt_rbseltran      TYPE TABLE OF letra_iv_fields,
        lt_errprot        TYPE TABLE OF mrm_errprot,
        lt_ebelntab       TYPE TABLE OF ebelntab,
        lt_limit          TYPE mmcr_tlimit,
        ls_return         TYPE bapiret2,
        ls_itemdata       TYPE bapi_incinv_create_item,
        ls_accountingdata TYPE bapi_incinv_create_account,
        buscs             TYPE zefatt_reg_td-buscs,
        count             TYPE i,
        i_xblnr           TYPE ek08b-xblnr,
        i_lifnr           TYPE lfa1-lifnr,
        t_eksel           TYPE STANDARD TABLE OF eksel,
        lt_vat_codes      TYPE STANDARD TABLE OF lty_vat_code,
        ls_vat_code       TYPE lty_vat_code.

  FIELD-SYMBOLS: <ddt>     TYPE zefatt_ddt_map,
                 <oda>     TYPE zefatt_oda_map,
                 <errprot> TYPE mrm_errprot,
                 <drseg>   TYPE mmcr_drseg,
                 <item>    TYPE zefatt_item_map,
                 <co>      TYPE mmcr_drseg_co.

* Testata Fattura Parcheggiata

* Società
  headerdata-comp_code    = header-bukrs.
* Tipo Documento
  headerdata-doc_type     = header-blart.
* Calcolare automaticamente imposta
  headerdata-calc_tax_ind = 'X'.
* Data Documeto
  headerdata-doc_date     = header-data_doc.
* Data Registrazione
  headerdata-pstng_date   = budat.
* Riferimento
  headerdata-ref_doc_no   = header-ref_doc.
* Importo lordo
  headerdata-gross_amount = abs( header-wrbtr ).
* Divisa
  headerdata-currency     = header-waers.

* Condizioni di pagamento da anagrafica fornitore
  SELECT SINGLE zterm FROM lfb1 INTO headerdata-pmnttrms
         WHERE lifnr = header-lifnr
         AND   bukrs = header-bukrs.

* Verificare se create fattura o accredito
  SELECT SINGLE buscs FROM zefatt_reg_td INTO buscs
         WHERE itdpa = header-itdpa.

  CASE buscs.
    WHEN 'R'. " Fattura
      headerdata-invoice_ind  = 'X'.
    WHEN 'G'. " Accredito
      headerdata-invoice_ind  = ' '.
  ENDCASE.

* Ricerca dei documenti logistici di riferimento ODA/DDT

* Documenti materiali
  LOOP AT ddt ASSIGNING <ddt>.

    ls_rbsellifs-lfsnr = <ddt>-ddt.
    ls_rbsellifs-gjahr = <ddt>-data_ddt(4).

    CLEAR: i_lifnr,
           i_xblnr.

    REFRESH t_eksel.

    i_xblnr = <ddt>-ddt.
    i_lifnr = header-lifnr.

    AT NEW ddt.

      CALL FUNCTION 'ME_SELECT_DOCUMENTS'
        EXPORTING
          i_xblnr = i_xblnr
          i_lifnr = i_lifnr
        TABLES
          t_eksel = t_eksel.

      IF lines( t_eksel ) <> 0.

        APPEND ls_rbsellifs TO lt_rbsellifs.
        CLEAR ls_rbsellifs.

      ENDIF.

    ENDAT.

  ENDLOOP.

  IF lines( lt_rbsellifs ) = 0.

    LOOP AT oda ASSIGNING <oda>.

* Ordine d'Acquisto
      IF <oda>-ebelp IS NOT INITIAL.

        SELECT SINGLE e~ebeln p~ebelp
               FROM ekko AS e
               INNER JOIN ekpo AS p  ON p~ebeln = e~ebeln
               INTO CORRESPONDING FIELDS OF ls_rbselbest

               WHERE e~ebeln EQ <oda>-ebeln
               AND p~ebelp EQ <oda>-ebelp
               AND e~lifnr EQ header-lifnr.

        IF sy-subrc <> 0.

          SELECT SINGLE ebeln FROM ekko INTO CORRESPONDING FIELDS OF ls_rbselbest
                 WHERE ebeln EQ <oda>-ebeln
                 AND   lifnr EQ header-lifnr.

        ENDIF.

      ELSE.

        SELECT SINGLE ebeln FROM ekko INTO CORRESPONDING FIELDS OF ls_rbselbest
               WHERE ebeln EQ <oda>-ebeln
               AND   lifnr EQ header-lifnr.

      ENDIF.

      IF ls_rbselbest IS NOT INITIAL.

        ls_rbsellifs-gjahr = header-data_doc(4).

        APPEND ls_rbselbest TO lt_rbselbest.

      ENDIF.

      CLEAR: ls_rbselbest.

    ENDLOOP.

  ENDIF.

  SORT lt_rbsellifs BY lfsnr.
  DELETE ADJACENT DUPLICATES FROM lt_rbsellifs COMPARING ALL FIELDS.

  SORT lt_rbselbest BY ebeln ebelp.
  DELETE ADJACENT DUPLICATES FROM lt_rbselbest COMPARING ALL FIELDS.

  IF lt_rbselbest[] IS INITIAL AND
     lt_rbsellifs[] IS INITIAL.

    headerdata-diff_inv = header-lifnr.

    no_ref = 'X'.
    RETURN.

  ENDIF.

* Asegnazione dati di testata della fattura in entrata
* Società
  ls_rbkpv-bukrs    = header-bukrs.
* Data Documento
  ls_rbkpv-bldat    = header-data_doc.
* Data Registrazione
  ls_rbkpv-budat    = budat.
* Esercizio
  ls_rbkpv-gjahr    = budat(4).
* Riferimento
  ls_rbkpv-xblnr    = header-ref_doc.
* Valuta
  ls_rbkpv-waers    = header-waers.
* Importo Totale
  ls_rbkpv-rmwwr    = abs( header-wrbtr ).
* Calcolo IVA su importo lordo
  ls_rbkpv-xmwst    = 'X'.
* Tipo processamento - Logistica Fattura
  ls_rbkpv-vgart    = 'RD'.
* Tipo selezione  merci/prest. e costi accessori
  ls_rbkpv-bnksel   = '3'.
* Attribuzione OdA
  ls_rbkpv-xbest    = 'X'.
* Attribuzione DDT
  ls_rbkpv-xlifs    = 'X'.
* Attribuzione Numero Trasportatore
  ls_rbkpv-xtran    = 'X'.
* Attribuzione pos. di consegna
  ls_rbkpv-xzuordli = 'X'.
* Attribuzione resi
  ls_rbkpv-xzuordrt = 'X'.
* Codice fattura EM/Prest.servizi
  ls_rbkpv-xware    = 'X'.
* Utente
  ls_rbkpv-usnam    = sy-uname.
* Data acquisizione
  ls_rbkpv-cpudt    = sy-datlo.
* Ora acquisizione
  ls_rbkpv-cputm    = sy-timlo.
* Transazione
  ls_rbkpv-tcode    = 'MIRO'.
* Fornitore
  ls_rbkpv-lifnr    = header-lifnr.
* Fornitore selezione
  ls_rbkpv-selif    = header-lifnr.

* Assegnazione documenti per MIRO
  CALL FUNCTION 'MRM_ASSIGNMENT'
    EXPORTING
      ti_drseg_old = lt_drseg_old[]
    TABLES
      t_drseg      = lt_drseg
      t_rbselbest  = lt_rbselbest
      t_rbsellifs  = lt_rbsellifs
      t_rbselfrbr  = lt_rbselfrbr
      t_rbselwerk  = lt_rbselwerk
      t_rbselerfb  = lt_rbselerfb
      t_errprot    = lt_errprot
      t_ebelntab   = lt_ebelntab
      t_rbseltran  = lt_rbseltran
    CHANGING
      c_rbkpv      = ls_rbkpv
      t_limit      = lt_limit.


  LOOP AT lt_errprot ASSIGNING <errprot> WHERE msgty = 'E' OR  msgty = 'A'.

    ls_return-type       = <errprot>-msgty.
    ls_return-id         = <errprot>-msgid.
    ls_return-number     = <errprot>-msgno.
    ls_return-message_v1 = <errprot>-msgv1.
    ls_return-message_v2 = <errprot>-msgv2.
    ls_return-message_v3 = <errprot>-msgv3.
    ls_return-message_v4 = <errprot>-msgv4.

    APPEND ls_return TO return.
    CLEAR ls_return.

  ENDLOOP.

  IF sy-subrc = 0.
    RETURN.
  ENDIF.

* Colletto per Codici IVA
  LOOP AT item ASSIGNING <item>.

    MOVE-CORRESPONDING <item> TO ls_vat_code.
    ls_vat_code-count = 1.

    COLLECT ls_vat_code INTO lt_vat_codes.

  ENDLOOP.

  SORT lt_vat_codes BY count DESCENDING.

* Posizione Fattura Parcheggiata
  LOOP AT lt_drseg ASSIGNING <drseg>.

    CHECK <drseg>-bukrs EQ ls_rbkpv-bukrs AND
          <drseg>-bpwem NE <drseg>-bprem  AND
          <drseg>-lfbnr EQ <drseg>-mblnr.

    ADD 1 TO count.

* Posizione
    ls_itemdata-invoice_doc_item = count.
* Numero Ordine acquisto
    ls_itemdata-po_number        = <drseg>-ebeln.
* Posizione Ordine acquisto
    ls_itemdata-po_item          = <drseg>-ebelp.
* Ammpontare posizione
    ls_itemdata-item_amount      = <drseg>-wewrt.

    IF ls_itemdata-item_amount IS INITIAL.
      ls_itemdata-item_amount    = <drseg>-netwr.
    ENDIF.

* Quantità
    ls_itemdata-quantity         = <drseg>-wemng.
* Unità di misura
    ls_itemdata-po_unit          = <drseg>-meins.

* Unità di misura ISO
    SELECT SINGLE isocode FROM t006
           INTO ls_itemdata-po_unit_iso
           WHERE msehi = ls_itemdata-po_unit.

* Unità di misura ISO
    ls_itemdata-po_pr_uom_iso    = ls_itemdata-po_unit_iso.
* Unità di misura del prezzo dell'ordine d'acquisto
    ls_itemdata-po_pr_uom        = <drseg>-bprme.
* Documento Materiale - Numero
    ls_itemdata-ref_doc          = <drseg>-mblnr.
* Documento Materiale - Esercizio
    ls_itemdata-ref_doc_year     = <drseg>-mjahr.
* Documento Materiale - Posizione
    ls_itemdata-ref_doc_it       = <drseg>-mblpo.

* Codice IVA
    IF <drseg>-mwskz IS NOT INITIAL.

* Recupero codice IVA su ODA se presente...
      ls_itemdata-tax_code  = <drseg>-mwskz.

    ELSE.

*...altrimmenti recupero codice IVA tramite il codice materiale su ODA
      READ TABLE item ASSIGNING <item> WITH KEY articolo = <drseg>-matnr.

      IF sy-subrc = 0.

        CALL FUNCTION 'ZEFATT_COD_IVA'
          EXPORTING
            bukrs       = header-bukrs
            lifnr       = header-lifnr
            aliquota    = <item>-aliquota
            natura      = <item>-natura
            esigibilita = <item>-esigibilita
          IMPORTING
            mwskz       = ls_itemdata-tax_code.

      ELSE.

        IF lines( oda ) > 0.

*...altrimmenti recupero codice IVA tramite il riferimeto della posizione dell' ODA presente sull'XML
          READ TABLE oda ASSIGNING <oda> WITH KEY ebeln = <drseg>-ebeln
                                                  ebelp = <drseg>-ebelp.

          IF sy-subrc = 0.

            READ TABLE item ASSIGNING <item> WITH KEY posnr_efatt = <oda>-posnr_efatt.

            IF sy-subrc = 0.

              CALL FUNCTION 'ZEFATT_COD_IVA'
                EXPORTING
                  bukrs       = header-bukrs
                  lifnr       = header-lifnr
                  aliquota    = <item>-aliquota
                  natura      = <item>-natura
                  esigibilita = <item>-esigibilita
                IMPORTING
                  mwskz       = ls_itemdata-tax_code.

            ELSE.

*...altrimmenti recupero il codice mettendo quello che ha + ricorrenze sulla fattura in maniera tale
*...da sostituire il minor numero di posizioni possibili
              READ TABLE lt_vat_codes INTO ls_vat_code INDEX 1.

              CALL FUNCTION 'ZEFATT_COD_IVA'
                EXPORTING
                  bukrs       = header-bukrs
                  lifnr       = header-lifnr
                  aliquota    = ls_vat_code-aliquota
                  natura      = ls_vat_code-natura
                  esigibilita = ls_vat_code-esigibilita
                IMPORTING
                  mwskz       = ls_itemdata-tax_code.

            ENDIF.

          ELSE.

*...altrimmenti recupero il codice mettendo quello che ha + ricorrenze sulla fattura in maniera tale
*...da sostituire il minor numero di posizioni possibili
            READ TABLE lt_vat_codes INTO ls_vat_code INDEX 1.

            CALL FUNCTION 'ZEFATT_COD_IVA'
              EXPORTING
                bukrs       = header-bukrs
                lifnr       = header-lifnr
                aliquota    = ls_vat_code-aliquota
                natura      = ls_vat_code-natura
                esigibilita = ls_vat_code-esigibilita
              IMPORTING
                mwskz       = ls_itemdata-tax_code.

          ENDIF.

        ENDIF.

      ENDIF.

    ENDIF.

* Contabilizzazione
    LOOP AT <drseg>-co ASSIGNING <co>.

      ls_accountingdata-invoice_doc_item = count.
      ls_accountingdata-serial_no        = <co>-zekkn.
      ls_accountingdata-quantity         = <co>-bsmng.
      ls_accountingdata-po_unit          = <co>-meins.
      ls_accountingdata-po_unit_iso      = <co>-meins.
      ls_accountingdata-gl_account       = <co>-saknr.
      ls_accountingdata-costcenter       = <co>-kostl.
      ls_accountingdata-orderid          = <co>-aufnr.
      ls_accountingdata-co_area          = <co>-kokrs.
      ls_accountingdata-profit_ctr       = <co>-prctr.
      ls_accountingdata-item_amount      = <co>-netwr.
      ls_accountingdata-tax_code         = ls_itemdata-tax_code.

      APPEND ls_accountingdata TO accountingdata.
      CLEAR ls_accountingdata.

    ENDLOOP.

    APPEND ls_itemdata TO itemdata.
    CLEAR ls_itemdata.

  ENDLOOP.

* Chiamata BaDi per personalizzazione cliente
  TRY.

      GET BADI badi_process_map.

      IF badi_process_map IS BOUND.

        CALL BADI badi_process_map->process_map_incoming_invoice
          EXPORTING
            header     = header
            budat      = budat
            item       = item
            oda        = oda
            ddt        = ddt
          CHANGING
            headerdata = headerdata
            itemdata   = itemdata.

      ENDIF.

    CATCH cx_badi_not_implemented.

  ENDTRY.

ENDMETHOD.


METHOD zif_efatt_process_map~process_map_park_fi.

  TYPES: BEGIN OF lty_item_new,

           articolo    TYPE  zefatt_codarticolo,
           testo       TYPE  sgtxt,
           menge       TYPE  menge_d,
           meins       TYPE  meins,
           pr_unitario TYPE  zefatt_pr_unitario,
           pr_totale   TYPE  zefatt_pr_totale,
           aliquota    TYPE  zefatt_aliquota,
           natura      TYPE	zit_natura,
           esigibilita TYPE  zefatt_esigibilita,
           ritenuta    TYPE	zefatt_rit,

         END OF lty_item_new.

  DATA: ls_bkpf             TYPE bkpf,
        lss_bkpf            TYPE bkpf,
        ls_bseg             TYPE bseg,
        lv_belnr            TYPE bkpf-belnr,
        lv_numkr            TYPE t003-numkr,
        lv_nrlevel          TYPE nriv-nrlevel,
        ls_zefatt_reg_conto TYPE zefatt_reg_conto,
        ls_return           TYPE bapiret2,
        count               TYPE i,
        lv_rule_vatdate     TYPE zefatt_vatdate-rule_vatdate,
        lv_sdi_reg          TYPE zefatt_vatdate-sdi_reg,
        ls_zefatt_reg_td    TYPE zefatt_reg_td,
        wt_newwt            TYPE t001-wt_newwt,
        lv_land1            TYPE t001-land1,
        lt_t001wt           TYPE STANDARD TABLE OF t001wt,
        lt_lfbw             TYPE STANDARD TABLE OF lfbw,
        qsshb               TYPE bseg-qsshb,
        ls_with_item        TYPE with_itemx,
        item_new            TYPE STANDARD TABLE OF lty_item_new,
        ls_item_new         TYPE lty_item_new,
        split_payment       TYPE zefatt_reg_td-split_payment,
        e_gjahr             TYPE bkpf-gjahr,
        e_monat             TYPE bkpf-monat.

  FIELD-SYMBOLS: <fs_item_map>     TYPE zefatt_item_map,
                 <fs_item_new>     TYPE lty_item_new,
                 <fs_cassa_map>    TYPE zefatt_cassa_map,
                 <fs_ritenuta_map> TYPE zefatt_ritenuta_map,
                 <fs_t001wt>       TYPE t001wt,
                 <fs_lfbw>         TYPE lfbw.

* Configurazione per data dichiarazione e controllo data registrazione
  SELECT SINGLE rule_vatdate  sdi_reg FROM zefatt_vatdate INTO (lv_rule_vatdate, lv_sdi_reg)
         WHERE bukrs = header-bukrs.

* Controllo se la fattura è in regime di Split Payment
  READ TABLE item TRANSPORTING NO FIELDS WITH KEY esigibilita = 'S'.

  IF sy-subrc = 0.
    split_payment = 'X'.
  ELSE.
    split_payment = space.
  ENDIF.

* Configurazione per registrazione (chiavei contabili, oggetto CO, transazione...)
  SELECT SINGLE * FROM zefatt_reg_td INTO ls_zefatt_reg_td
         WHERE itdpa         = header-itdpa
         AND   split_payment = split_payment.

* Determinazione di periodo contabile e anno
  CALL FUNCTION 'FI_PERIOD_DETERMINE'
    EXPORTING
      i_budat        = budat
      i_bukrs        = header-bukrs
    IMPORTING
      e_gjahr        = e_gjahr
      e_monat        = e_monat
    EXCEPTIONS
      fiscal_year    = 1
      period         = 2
      period_version = 3
      posting_period = 4
      special_period = 5
      version        = 6
      posting_date   = 7
      OTHERS         = 8.

  IF sy-subrc <> 0.

    ls_return-type       = 'E'.
    ls_return-id         = sy-msgid.
    ls_return-number     = sy-msgno.
    ls_return-message_v1 = sy-msgv1.
    ls_return-message_v2 = sy-msgv2.
    ls_return-message_v3 = sy-msgv3.
    ls_return-message_v4 = sy-msgv4.

    APPEND ls_return TO return.
    CLEAR ls_return.

    RETURN.

  ENDIF.

* Controllo che la data di registrazione sia corretta ai fini IVA
  SELECT SINGLE numkr FROM t003 INTO lv_numkr
     WHERE blart = header-blart.

  SELECT SINGLE nrlevel FROM nriv INTO lv_nrlevel
     WHERE object    = 'RF_BELEG'
     AND   subobject = header-bukrs
     AND   nrrangenr = lv_numkr
     AND   toyear    = e_gjahr.

  lv_belnr = lv_nrlevel+10(10).

  SELECT SINGLE * FROM bkpf INTO lss_bkpf
      WHERE bukrs  = header-bukrs
      AND   belnr  = lv_belnr
      AND   gjahr  = e_gjahr.

  IF sy-subrc = 0.

    IF budat < lss_bkpf-budat.

      ls_return-type       = 'E'.
      ls_return-id         = 'ZEFATTURA'.
      ls_return-number     = '028'.

      WRITE: budat          TO ls_return-message_v1,
             lss_bkpf-budat TO ls_return-message_v2,
             lv_belnr       TO ls_return-message_v3.

      APPEND ls_return TO return.
      CLEAR ls_return.

      RETURN.

    ENDIF.

  ENDIF.

* Controllo se la data registrazione è antecedente alla data ricezione SDI
  IF lv_sdi_reg = 'X'.

    IF budat < sdi_date.

      ls_return-type       = 'E'.
      ls_return-id         = 'ZEFATTURA'.
      ls_return-number     = '031'.

      WRITE: budat    TO ls_return-message_v1,
             sdi_date TO ls_return-message_v2.

      APPEND ls_return TO return.
      CLEAR ls_return.

      RETURN.

    ENDIF.

  ENDIF.

* Controllo se la data registrazione è antecedente alla data documento
  IF budat < header-data_doc.

    ls_return-type       = 'E'.
    ls_return-id         = 'ZEFATTURA'.
    ls_return-number     = '041'.

    WRITE: budat           TO ls_return-message_v1,
           header-data_doc TO ls_return-message_v2.

    APPEND ls_return TO return.
    CLEAR ls_return.

    RETURN.

  ENDIF.

* Dati di testata
* Società
  ls_bkpf-bukrs = header-bukrs.
* Esercizio
  ls_bkpf-gjahr = e_gjahr.
* Perioodo Contabile
  ls_bkpf-monat = e_monat.
* Data Documento
  ls_bkpf-budat = budat.
* Tipo Documento
  ls_bkpf-blart = header-blart.
* Data Registrazione
  ls_bkpf-bldat = header-data_doc.
* Documento di riferimento
  ls_bkpf-xblnr = header-ref_doc.
* Divisa
  ls_bkpf-waers = header-waers.
* Calcolo imposte
  ls_bkpf-xmwst = 'X'.
* Gli importi conti Co.Ge. sono al netto
  ls_bkpf-xsnet = 'X'.
* Transazione
  ls_bkpf-tcode = ls_zefatt_reg_td-tcode.
* Utente
  ls_bkpf-usnam = sy-uname.
* Operazione gestionale
  ls_bkpf-glvor = 'RFBU'.

* Controllo se si deve compattare per evitare di tentare di creare dei documenti
* con più di 999 posizioni che SAP non permette
  LOOP AT item ASSIGNING <fs_item_map>.

    MOVE-CORRESPONDING <fs_item_map> TO ls_item_new.

    IF lines( item ) > 998.
      COLLECT ls_item_new INTO item_new.
    ELSE.
      APPEND ls_item_new TO item_new.
    ENDIF.

  ENDLOOP.

* Posizione Fornitore
  ADD 1 TO count.

* Riga Fornitore
  ls_bseg-buzei = count.
* Importo totale
  ls_bseg-wrbtr = abs( header-wrbtr ).

* Chiave contabile
  IF header-wrbtr >= 0.
    ls_bseg-bschl = ls_zefatt_reg_td-bschl_k.
  ELSE.
    ls_bseg-bschl = ls_zefatt_reg_td-bschl_k_neg.
  ENDIF.

* Indicatore dare/avere
  CLEAR ls_bseg-shkzg.
  SELECT SINGLE shkzg FROM tbsl INTO ls_bseg-shkzg
         WHERE bschl = ls_bseg-bschl.

* Divisa
  ls_bseg-pswsl = header-waers.
* Società
  ls_bseg-bukrs = header-bukrs.
* Esercizio
  ls_bseg-gjahr = e_gjahr.
* Tipo Conto
  ls_bseg-koart = 'K'.
* Fornitore
  ls_bseg-lifnr = header-lifnr.

*Conto Co.ge. G/L Account da anagrafica fornitore
  SELECT SINGLE akont INTO ls_bseg-hkont FROM lfb1
         WHERE lifnr = header-lifnr
         AND   bukrs = header-bukrs.

  ls_bseg-saknr  = ls_bseg-hkont.

* Modalità di pagamento trascodificata da XML...
  IF header-zlsch IS INITIAL.

*... altrimenti da anagrafica fornitore
    SELECT SINGLE zwels FROM lfb1 INTO ls_bseg-zlsch
           WHERE lifnr = header-lifnr
           AND   bukrs = header-bukrs.

  ENDIF.

* Condizioni di pagamento da anagrafica fornitore
  SELECT SINGLE zterm FROM lfb1 INTO ls_bseg-zterm
         WHERE lifnr = header-lifnr
         AND   bukrs = header-bukrs.

* Data base
  IF header-zfbdt IS INITIAL.

    ls_bseg-zfbdt = header-data_doc.

  ELSE.

    ls_bseg-zfbdt = header-zfbdt.

  ENDIF.

* Passo i giorno per il calcolo della scadenza
  CALL FUNCTION 'FI_TERMS_OF_PAYMENT_PROPOSE'
    EXPORTING
      i_bldat         = ls_bkpf-bldat
      i_budat         = ls_bkpf-budat
      i_zterm         = ls_bseg-zterm
    IMPORTING
      e_zbd1t         = ls_bseg-zbd1t
      e_zbd1p         = ls_bseg-zbd1p
      e_zbd2t         = ls_bseg-zbd2t
      e_zbd2p         = ls_bseg-zbd2p
      e_zbd3t         = ls_bseg-zbd3t
    EXCEPTIONS
      terms_not_found = 1
      OTHERS          = 2.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

* Controllo se ci sono da gestire i dati di ritenuta d'acconto
  IF lines( ritenuta ) > 0.

* Controllo se è attiva l'esecuzione ampliata calcolo ritenuta acconto...
    CLEAR wt_newwt.
    SELECT SINGLE land1 wt_newwt FROM t001 INTO (lv_land1, wt_newwt)
           WHERE bukrs = header-bukrs.

    LOOP AT ritenuta ASSIGNING <fs_ritenuta_map>.

      CLEAR: qsshb.

* Importo imponibile su cui è calcolato la ritenuta (POSIZIONE)
      LOOP AT item ASSIGNING <fs_item_map> WHERE ritenuta = 'SI'.
        qsshb =  qsshb + abs( <fs_item_map>-pr_totale ).
      ENDLOOP.

* Importo imponibile su cui è calcolato la ritenuta (CASSA PREVIDENZIALE)
      LOOP AT cassa ASSIGNING <fs_cassa_map> WHERE ritenuta = 'SI'.
        qsshb =  qsshb + abs( <fs_cassa_map>-imponibile_cassa ).
      ENDLOOP.

      IF wt_newwt IS INITIAL.

*... se non è attiva gestisco i campi della BSEG

* Recupero il codice ritenuta dall'anagrafica del fornitore sulla vista società
        SELECT SINGLE qsskz FROM lfb1 INTO ls_bseg-qsskz
               WHERE lifnr   = header-lifnr
               AND   bukrs   = header-bukrs.

* Importo imponibile su cui è calcolato la ritenuta
        ls_bseg-qsshb =  qsshb.
        CALL FUNCTION 'ZEFATT_IMPONIBILE_WT_CALC'
          EXPORTING
            i_qsskz   = ls_bseg-qsskz
            i_land1   = lv_land1
          CHANGING
            c_qsshb   = ls_bseg-qsshb
          EXCEPTIONS
            not_found = 1
            OTHERS    = 2.

        IF sy-subrc <> 0.

          ls_return-type       = 'E'.
          ls_return-id         = sy-msgid.
          ls_return-number     = sy-msgno.
          ls_return-message_v1 = sy-msgv1.
          ls_return-message_v2 = sy-msgv2.
          ls_return-message_v3 = sy-msgv3.
          ls_return-message_v4 = sy-msgv4.

          APPEND ls_return TO return.
          CLEAR ls_return.

          RETURN.

        ENDIF.

* Importo esente dal calcolo della ritenuta
        CALL FUNCTION 'LINEITEM_OLD_WT_AMOUNTS'
          EXPORTING
            i_qsskz = ls_bseg-qsskz
            i_land1 = lv_land1
            i_wrbtr = ls_bseg-wrbtr
          CHANGING
            c_qsshb = ls_bseg-qsshb
            c_qsfbt = ls_bseg-qsfbt.

* Importo ritenuta
        ls_bseg-qbshb = <fs_ritenuta_map>-importo_ritenuta.

      ELSE.

*... se è attiva gestisco i campi della WITH_ITEM

* Recupero i dati della ritenuta a livello di società
        CALL FUNCTION 'FI_WT_READ_T001WT'
          EXPORTING
            i_bukrs   = header-bukrs
          TABLES
            t_t001wt  = lt_t001wt
          EXCEPTIONS
            not_found = 1
            OTHERS    = 2.

        IF sy-subrc <> 0.

          ls_return-type       = 'E'.
          ls_return-id         = sy-msgid.
          ls_return-number     = sy-msgno.
          ls_return-message_v1 = sy-msgv1.
          ls_return-message_v2 = sy-msgv2.
          ls_return-message_v3 = sy-msgv3.
          ls_return-message_v4 = sy-msgv4.

          APPEND ls_return TO return.
          CLEAR ls_return.

          RETURN.

        ENDIF.

* Recupero i dati della ritenuta dall'anagrafica del fornitore
        CALL FUNCTION 'FI_WT_READ_LFBW'
          EXPORTING
            i_lifnr   = header-lifnr
            i_bukrs   = header-bukrs
          TABLES
            t_lfbw    = lt_lfbw
          EXCEPTIONS
            not_found = 1
            OTHERS    = 2.

        LOOP AT lt_lfbw ASSIGNING <fs_lfbw>.

          CHECK <fs_lfbw>-wt_subjct = 'X'.

          READ TABLE lt_t001wt ASSIGNING <fs_t001wt> WITH KEY witht = <fs_lfbw>-witht.

          CHECK sy-subrc EQ 0.

          CHECK <fs_t001wt>-wt_agent = 'X' AND budat BETWEEN <fs_t001wt>-wt_agtdf  AND <fs_t001wt>-wt_agtdt.

          MOVE-CORRESPONDING <fs_lfbw> TO ls_with_item.

          ls_with_item-wt_wtexmn = <fs_lfbw>-wt_exnr.
          ls_with_item-buzei     = count.

* Importo imponibile su cui è calcolato la ritenuta
          ls_with_item-wt_qsshb =  qsshb.

          CALL FUNCTION 'ZEFATT_IMPONIBILE_WT_CALC'
            EXPORTING
              i_qsskz     = ls_with_item-wt_withcd
              i_land1     = lv_land1
              witht       = ls_with_item-witht
              extended_wt = 'X'
            CHANGING
              c_qsshb     = ls_with_item-wt_qsshb
            EXCEPTIONS
              not_found   = 1
              OTHERS      = 2.

          IF sy-subrc <> 0.

            ls_return-type       = 'E'.
            ls_return-id         = sy-msgid.
            ls_return-number     = sy-msgno.
            ls_return-message_v1 = sy-msgv1.
            ls_return-message_v2 = sy-msgv2.
            ls_return-message_v3 = sy-msgv3.
            ls_return-message_v4 = sy-msgv4.

            APPEND ls_return TO return.
            CLEAR ls_return.

            RETURN.

          ENDIF.

          ls_with_item-wt_qsshb  = ls_with_item-wt_qsshb * -1.
          ls_with_item-wt_qsshh  = ls_with_item-wt_qsshb.

* Importo ritenuta
          ls_with_item-wt_qbshb  = <fs_ritenuta_map>-importo_ritenuta * -1.
          ls_with_item-wt_qbshh  = <fs_ritenuta_map>-importo_ritenuta * -1.
          ls_with_item-wt_stat   = 'V'.

          APPEND ls_with_item TO e_spltwt.

        ENDLOOP.

      ENDIF.

    ENDLOOP.

  ENDIF.

  APPEND ls_bseg TO e_bseg.
  CLEAR  ls_bseg.

  LOOP AT item_new ASSIGNING <fs_item_new>.

    ADD 1 TO count.

* Riga Documento
    ls_bseg-buzei = count.
* Importo totale
    ls_bseg-wrbtr = abs( <fs_item_new>-pr_totale ).

* Chiave contabile
    IF <fs_item_new>-pr_totale >= 0.
      ls_bseg-bschl = ls_zefatt_reg_td-bschl_s.
    ELSE.
      ls_bseg-bschl = ls_zefatt_reg_td-bschl_s_neg.
    ENDIF.

* Indicatore dare/avere
    CLEAR ls_bseg-shkzg.
    SELECT SINGLE shkzg FROM tbsl INTO ls_bseg-shkzg
           WHERE bschl = ls_bseg-bschl.

* Divisa
    ls_bseg-pswsl = header-waers.
* Società
    ls_bseg-bukrs = header-bukrs.
* Esercizio
    ls_bseg-gjahr = e_gjahr.
* Tipo Conto
    ls_bseg-koart = 'S'.
* Testo
    ls_bseg-sgtxt = <fs_item_new>-testo.

* Codice IVA
    CALL FUNCTION 'ZEFATT_COD_IVA'
      EXPORTING
        bukrs       = header-bukrs
        lifnr       = header-lifnr
        aliquota    = <fs_item_new>-aliquota
        natura      = <fs_item_new>-natura
        esigibilita = <fs_item_new>-esigibilita
      IMPORTING
        mwskz       = ls_bseg-mwskz.

    IF ls_bseg-mwskz IS INITIAL.

      ls_return-type       = 'E'.
      ls_return-id         = 'ZEFATTURA'.
      ls_return-number     = '059'.
      ls_return-message_v1 = <fs_item_new>-aliquota.
      ls_return-message_v2 = <fs_item_new>-natura.
      ls_return-message_v3 = <fs_item_new>-esigibilita.
      ls_return-message_v4 = space.

      APPEND ls_return TO return.
      CLEAR ls_return.

      RETURN.

    ENDIF.

* Dati per la contabilizzazione
    CLEAR ls_zefatt_reg_conto.
    zcl_efatt_util_incoming=>trascodifica_conto( EXPORTING bukrs             = header-bukrs
                                                           lifnr             = header-lifnr
                                                           articolo          = <fs_item_new>-articolo
                                                           testo             = <fs_item_new>-testo
                                                 IMPORTING e_efatt_reg_conto = ls_zefatt_reg_conto ).

    IF ls_zefatt_reg_conto IS INITIAL.

      ls_return-type       = 'E'.
      ls_return-id         = 'ZEFATTURA'.
      ls_return-number     = '012'.
      ls_return-message_v1 = header-lifnr.
      ls_return-message_v2 = header-bukrs.
      ls_return-message_v3 = space.
      ls_return-message_v4 = header-ref_doc.

      APPEND ls_return TO return.
      CLEAR ls_return.

      RETURN.

    ENDIF.

* Conto Co.ge.
    ls_bseg-hkont = ls_zefatt_reg_conto-saknr.
    ls_bseg-saknr = ls_zefatt_reg_conto-saknr.

* Contabilizzazione CO
    CASE  ls_zefatt_reg_conto-knttp.

      WHEN 'A'. "Cespite

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ls_zefatt_reg_conto-objco
          IMPORTING
            output = ls_bseg-anln1.

      WHEN 'C'. "Ordine cliente

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ls_zefatt_reg_conto-objco
          IMPORTING
            output = ls_bseg-aufnr.

      WHEN 'F'. "Ordine interno

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ls_zefatt_reg_conto-objco
          IMPORTING
            output = ls_bseg-aufnr.


      WHEN 'K'. "Centro di Costo

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ls_zefatt_reg_conto-objco
          IMPORTING
            output = ls_bseg-kostl.

      WHEN 'P'. "Progetto

        CALL FUNCTION 'CONVERSION_EXIT_ABPSP_INPUTT'
          EXPORTING
            input  = ls_zefatt_reg_conto-objco
          IMPORTING
            output = ls_bseg-projk.

      WHEN 'Q'. "Prod. sing.

        CALL FUNCTION 'CONVERSION_EXIT_ABPSP_INPUT'
          EXPORTING
            input  = ls_zefatt_reg_conto-objco
          IMPORTING
            output = ls_bseg-projk.

    ENDCASE.

    APPEND ls_bseg TO e_bseg.
    CLEAR  ls_bseg.

  ENDLOOP.

* Aggiungo la posizione dell'eventuale cassa previdenziale
  LOOP AT cassa ASSIGNING <fs_cassa_map>.

    ADD 1 TO count.

* Riga Documento
    ls_bseg-buzei = count.
* Importo totale
    ls_bseg-wrbtr = abs( <fs_cassa_map>-importo ).

* Chiave contabile
    IF <fs_cassa_map>-importo >= 0.
      ls_bseg-bschl = ls_zefatt_reg_td-bschl_s.
    ELSE.
      ls_bseg-bschl = ls_zefatt_reg_td-bschl_s_neg.
    ENDIF.

* Indicatore dare/avere
    CLEAR ls_bseg-shkzg.
    SELECT SINGLE shkzg FROM tbsl INTO ls_bseg-shkzg
           WHERE bschl = ls_bseg-bschl.

* Divisa
    ls_bseg-pswsl = header-waers.
* Società
    ls_bseg-bukrs = header-bukrs.
* Esercizio
    ls_bseg-gjahr = e_gjahr.
* Tipo Conto
    ls_bseg-koart = 'S'.
* Testo
    ls_bseg-sgtxt = 'Cassa Previdenziale'.

* Codice IVA
    CALL FUNCTION 'ZEFATT_COD_IVA'
      EXPORTING
        bukrs       = header-bukrs
        lifnr       = header-lifnr
        aliquota    = <fs_cassa_map>-aliquota
        natura      = <fs_cassa_map>-natura
        esigibilita = <fs_cassa_map>-esigibilita
      IMPORTING
        mwskz       = ls_bseg-mwskz.

    IF ls_bseg-mwskz IS INITIAL.

      ls_return-type       = 'E'.
      ls_return-id         = 'ZEFATTURA'.
      ls_return-number     = '059'.
      ls_return-message_v1 = <fs_cassa_map>-aliquota.
      ls_return-message_v2 = <fs_cassa_map>-natura.
      ls_return-message_v3 = <fs_cassa_map>-esigibilita.
      ls_return-message_v4 = space.

      APPEND ls_return TO return.
      CLEAR ls_return.

      RETURN.

    ENDIF.

* Dati per la contabilizzazione
    CLEAR ls_zefatt_reg_conto.
    zcl_efatt_util_incoming=>trascodifica_conto( EXPORTING bukrs             = header-bukrs
                                                           lifnr             = header-lifnr
                                                           cassa             = 'X'
                                                 IMPORTING e_efatt_reg_conto = ls_zefatt_reg_conto ).

    IF ls_zefatt_reg_conto IS INITIAL.

      ls_return-type       = 'E'.
      ls_return-id         = 'ZEFATTURA'.
      ls_return-number     = '063'.
      ls_return-message_v1 = header-lifnr.
      ls_return-message_v2 = header-bukrs.
      ls_return-message_v3 = space.
      ls_return-message_v4 = header-ref_doc.

      APPEND ls_return TO return.
      CLEAR ls_return.

      RETURN.

    ENDIF.

* Conto Co.ge.
    ls_bseg-hkont = ls_zefatt_reg_conto-saknr.
    ls_bseg-saknr = ls_zefatt_reg_conto-saknr.

* Contabilizzazione CO
    CASE  ls_zefatt_reg_conto-knttp.

      WHEN 'A'. "Cespite

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ls_zefatt_reg_conto-objco
          IMPORTING
            output = ls_bseg-anln1.

      WHEN 'C'. "Ordine cliente

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ls_zefatt_reg_conto-objco
          IMPORTING
            output = ls_bseg-aufnr.

      WHEN 'F'. "Ordine interno

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ls_zefatt_reg_conto-objco
          IMPORTING
            output = ls_bseg-aufnr.


      WHEN 'K'. "Centro di Costo

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ls_zefatt_reg_conto-objco
          IMPORTING
            output = ls_bseg-kostl.

      WHEN 'P'. "Progetto

        CALL FUNCTION 'CONVERSION_EXIT_ABPSP_INPUTT'
          EXPORTING
            input  = ls_zefatt_reg_conto-objco
          IMPORTING
            output = ls_bseg-projk.

      WHEN 'Q'. "Prod. sing.

        CALL FUNCTION 'CONVERSION_EXIT_ABPSP_INPUT'
          EXPORTING
            input  = ls_zefatt_reg_conto-objco
          IMPORTING
            output = ls_bseg-projk.

    ENDCASE.

    APPEND ls_bseg TO e_bseg.
    CLEAR  ls_bseg.

  ENDLOOP.

* Data dichiarazione IVA
  CASE lv_rule_vatdate.
    WHEN 'SDI'.
      ls_bkpf-vatdate = sdi_date.
    WHEN 'REG'.
      ls_bkpf-vatdate = budat.
    WHEN 'DOC'.
      ls_bkpf-vatdate = header-data_doc.
    WHEN 'CUS'.

      zcl_efatt_util_incoming=>vatdate_determine( EXPORTING i_bkpf  = ls_bkpf
                                                            i_bseg  = e_bseg
                                                  IMPORTING vatdate = ls_bkpf-vatdate ).

  ENDCASE.

  APPEND ls_bkpf TO e_bkpf.
  CLEAR ls_bkpf.

  TRY.

      GET BADI badi_process_map.

      IF badi_process_map IS BOUND.

        CALL BADI badi_process_map->process_map_park_fi
          EXPORTING
            header   = header
            item     = item
            cassa    = cassa
            ritenuta = ritenuta
            budat    = budat
            sdi_date = sdi_date
          CHANGING
            e_bkpf   = e_bkpf
            e_bseg   = e_bseg
            e_spltwt = e_spltwt.

      ENDIF.

    CATCH cx_badi_not_implemented.

  ENDTRY.

ENDMETHOD.
ENDCLASS.
