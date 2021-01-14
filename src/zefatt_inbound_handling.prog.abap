*&---------------------------------------------------------------------*
*& Report ZEFATT_INBOUND_UPLOAD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zefatt_inbound_handling.

TYPE-POOLS slis.

CONSTANTS: gc_icon_green TYPE icon_d VALUE '@5B@',
           gc_icon_red   TYPE icon_d VALUE '@5C@'.

DATA: gt_file            TYPE filetable,
      gs_upload_log      TYPE zefatt_upload_log,
      gt_upload_log      TYPE STANDARD TABLE OF zefatt_upload_log,
      it_fieldcat        TYPE slis_t_fieldcat_alv,
      is_layout          TYPE slis_layout_alv,
      fileprovider       TYPE REF TO zif_efatt_fileprovider,
      webserviceprovider TYPE REF TO zif_fatt_api,
      return             TYPE bapiret2,
      gs_int_conf        TYPE zefatt_int_conf,
      obj_descr          TYPE so_obj_des,
      badi_notif         TYPE REF TO zfatt_badi_notif,
      badi_soluzione     TYPE REF TO zfatt_badi_soluzione,
      xml                TYPE xstring,
      trasmissione       TYPE zefatt_intest_trasmissione,
      intest_societa     TYPE zefatt_intest_map,
      intest_fornitore   TYPE zefatt_intest_for_map,
      header             TYPE zefatt_header_map_t,
      item               TYPE zefatt_item_map_t,
      oda                TYPE zefatt_oda_map_t,
      ddt                TYPE zefatt_ddt_map_t,
      ritenuta           TYPE zefatt_ritenuta_map_t,
      cassa              TYPE zefatt_cassa_map_t,
      contratto          TYPE zefatt_contratto_map_t,
      fatture            TYPE zefatt_fatture_map_t,
      ricezione          TYPE zefatt_ricezione_map_t,
      convenzione        TYPE zefatt_convenzione_map_t,
      allegati           TYPE zefatt_attach_map_t,
      error_text         TYPE bapiret2-message,
      notifica           TYPE zfatt_notif_map,
      file_name          TYPE zefatt_file_name,
      i_filename         TYPE string,
      gt_files           TYPE zefatt_filedescriptor_t,
      sdi_date           TYPE zefatt_sdi_date.


FIELD-SYMBOLS: <fs_files>      TYPE zefatt_filedescriptor,
               <fs_efatt_mail> TYPE zefatt_mail.

* Parametri di selezione
PARAMETERS: p_bukrs TYPE bkpf-bukrs OBLIGATORY.
PARAMETERS: p_int   TYPE zefatt_interfaccia OBLIGATORY MATCHCODE OBJECT zefatt_int_in_h.
PARAMETERS: p_sdi   TYPE zefatt_sdi_date NO-DISPLAY DEFAULT sy-datum.

*----------------------------------------------------------------------*
*       CLASS lcl_main DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_main DEFINITION FINAL.

  PUBLIC SECTION.

    METHODS display_data.
    METHODS display_alv.
    METHODS call_webservice.
    METHODS upload_file.

  PRIVATE SECTION.

    METHODS copy_file   IMPORTING filename    TYPE zefatt_filedescriptor-filename.
    METHODS upload      IMPORTING iv_source   TYPE zefatt_filedescriptor-filename
                        EXPORTING ev_uploaded TYPE boolean.
    METHODS soluzione.


ENDCLASS.                    "lcl_main DEFINITION
*----------------------------------------------------------------------*
* Local classes implementation
*----------------------------------------------------------------------*
CLASS lcl_main IMPLEMENTATION.

  METHOD display_data.
    PERFORM alv.
  ENDMETHOD.                    "display_data

  METHOD display_alv.
  ENDMETHOD.                    "display_alv

  METHOD call_webservice.

* Istanzio la classe che mi gestirà il WebService
    zcl_fatt_wsprovider_factory=>get_wsprovider( EXPORTING interfaccia   = gs_int_conf-interfaccia
                                                           i_type        = gs_int_conf-interfaccia_tipo
                                                 IMPORTING rp_wsprovider = webserviceprovider
                                                           return        = return ).

    IF return-type = 'E' OR
       return-type = 'A'.

      MESSAGE ID     return-id
              TYPE   return-type
              NUMBER return-number
              WITH   return-message_v1 return-message_v2 return-message_v3 return-message_v4.

    ENDIF.

* Connessione al sistema partner
    webserviceprovider->connect_to_service( EXPORTING bukrs       = p_bukrs
                                                      interfaccia = gs_int_conf-interfaccia
                                            IMPORTING return      = return ).

    IF return-type = 'E' OR
       return-type = 'A'.

      MESSAGE ID     return-id
              TYPE   return-type
              NUMBER return-number
              WITH   return-message_v1 return-message_v2 return-message_v3 return-message_v4.

    ENDIF.

* Controllo di che soluzione si tratta
    CASE gs_int_conf-soluzione.

      WHEN 'A' OR  " Creazione Automatica documento in entrata.
           'M'.    " Creazione Documento tramite Cockpit

* Chiamata API per la ricezione della fattura
        webserviceprovider->incoming_invoice( EXPORTING bukrs       = p_bukrs
                                                        interfaccia = gs_int_conf-interfaccia
                                              IMPORTING xml         = xml
                                                        filename    = file_name
                                                        sdi_date    = sdi_date
                                                        return      = return ).
      WHEN 'N'.  " Gestione Notifiche SDI

* Chiamata API per la ricezione delle Notifiche SDI
        webserviceprovider->incoming_notification( EXPORTING bukrs       = p_bukrs
                                                             interfaccia = gs_int_conf-interfaccia
                                                   IMPORTING xml         = xml
                                                             return      = return ).

    ENDCASE.

    IF return-type = 'E' OR
       return-type = 'A'.

      MESSAGE ID     return-id
              TYPE   return-type
              NUMBER return-number
              WITH   return-message_v1 return-message_v2 return-message_v3 return-message_v4.

    ENDIF.

* Chiusura della connessione
    webserviceprovider->close( IMPORTING return = return ).

* Eseguo l'elaborazione dell'XML in base alla soluzione configurata
    soluzione( ).

  ENDMETHOD.                  "call_webservice

  METHOD upload_file.

* Istanzio la classe che mi gestirà i file
    zcl_efatt_util=>manage_file( EXPORTING bukrs        = p_bukrs
                                           interfaccia  = gs_int_conf-interfaccia
                                           i_type       = gs_int_conf-interfaccia_tipo
                                 IMPORTING fileprovider = fileprovider
                                           return       = return ).

    IF return-type = 'E' OR
       return-type = 'A'.

      MESSAGE ID return-id TYPE return-type NUMBER return-number
              WITH return-message_v1 return-message_v2 return-message_v3 return-message_v4.

      RETURN.

    ENDIF.

* Setto la directory di lavoro dove recupero i file
    CLEAR return.
    fileprovider->set_work_directory( EXPORTING bukrs       = p_bukrs
                                                interfaccia = gs_int_conf-interfaccia
                                      IMPORTING return      = return ).


* Recupero la lista dei files
    fileprovider->get_file_listing( IMPORTING et_files = gt_files
                                              return   = return ).


    IF return-type = 'E' OR
       return-type = 'A'.

      MESSAGE ID return-id TYPE return-type NUMBER return-number
              WITH return-message_v1 return-message_v2 return-message_v3 return-message_v4.

      RETURN.

    ENDIF.


    IF gt_files[] IS INITIAL.

      MESSAGE s045(zefattura).
      RETURN.

    ENDIF.

* Importo i file
    LOOP AT gt_files ASSIGNING <fs_files>.

      sdi_date = <fs_files>-filedate.

      copy_file( EXPORTING filename = <fs_files>-filename ).

      IF gs_int_conf-interfaccia_tipo = 'A'.

* Chiudo la sessione file
        i_filename = <fs_files>-filename.
        fileprovider->close( EXPORTING i_filename = i_filename
                             IMPORTING return     = return ).
      ENDIF.

    ENDLOOP.

    IF gs_int_conf-interfaccia_tipo = 'F'.

* Chiudo la sessione FTP
      fileprovider->close( EXPORTING i_filename = i_filename
                           IMPORTING return     = return ).

    ENDIF.

  ENDMETHOD.                    "upload_file

  METHOD copy_file.

    DATA: lv_file_uploaded TYPE boolean,
          i_filename       TYPE string.

* Esecuzione dell'upload del file
    upload( EXPORTING iv_source   = filename
            IMPORTING ev_uploaded = lv_file_uploaded ).

    gs_upload_log-filename = filename.

    IF lv_file_uploaded NE 'X'.

      gs_upload_log-icon     = gc_icon_red.

    ELSE.

      gs_upload_log-icon     = gc_icon_green.
      gs_upload_log-comments = TEXT-009.

* Se l'upload è andato a buon fine trasferisco il file nella cartella di backup
      i_filename = filename.
      fileprovider->transfer_file( EXPORTING i_filename = i_filename
                                   IMPORTING return     = return ).

    ENDIF.

    APPEND gs_upload_log TO gt_upload_log.

  ENDMETHOD.                    "copy_file.

  METHOD upload.

    DATA: et_content TYPE sdokcntbins,
          e_size     TYPE i.

    REFRESH: header,
             item,
             oda,
             ddt,
             ritenuta,
             cassa,
             allegati.

    CLEAR: trasmissione,
           intest_societa,
           intest_fornitore,
           error_text,
           notifica,
           xml,
           file_name,
           i_filename.

    file_name = i_filename = iv_source.

* Lettura file
    fileprovider->read_file( EXPORTING i_filename = i_filename
                             IMPORTING et_content = et_content
                                       e_size     = e_size
                                       return     = return ).

    IF return-type = 'E' OR
       return-type = 'A'.

      MESSAGE ID return-id TYPE return-type NUMBER return-number INTO gs_upload_log-comments
              WITH return-message_v1 return-message_v2 return-message_v3 return-message_v4.

      RETURN.

    ENDIF.

    IF et_content[] IS INITIAL.

      MESSAGE e019(zefattura) INTO gs_upload_log-comments.
      RETURN.

    ENDIF.

* Conversione in stringa esadeciamale
    CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
      EXPORTING
        input_length = e_size
      IMPORTING
        buffer       = xml
      TABLES
        binary_tab   = et_content
      EXCEPTIONS
        failed       = 1
        OTHERS       = 2.

    IF sy-subrc <> 0.

      MESSAGE e007(zefattura) INTO gs_upload_log-comments.
      RETURN.

    ENDIF.

* Eseguo l'elaborazione dell'XML in base alla soluzione configurata
    soluzione( ).

* Aggiorno o stato in base all'esito
    IF error_text IS INITIAL.
      ev_uploaded = 'X'.
    ENDIF.

  ENDMETHOD.                    "upload.
  METHOD soluzione.

    CASE gs_int_conf-soluzione.

      WHEN 'A' OR  " Creazione Automatica documento in entrata.
           'M'.     " Creazione Documento tramite Cockpit

* Creazione della fattura passiva avviene solo se presente e attivato
* il pacchetto ZEFATTURA - Fattura Elettronica - Flusso Passivo
        INCLUDE zefatt_create_efattura IF FOUND.

      WHEN 'N'.  " Gestione Notifiche SDI

* Gestione Notifiche SDI avviene solo se presente e attivato
* il pacchetto ZFATTURA_NOTIF - Fattura Elettronica - Notifiche
        INCLUDE zfatt_handle_notif IF FOUND.

      WHEN 'C'.  " Soluzione Custom

* Mapping della Soluzione Custom
        TRY.

            GET BADI badi_soluzione.

            IF badi_soluzione IS BOUND.

              CALL BADI badi_soluzione->handle_mapping
                EXPORTING
                  interfaccia      = p_int
                IMPORTING
                  trasmissione     = trasmissione
                  intest_societa   = intest_societa
                  intest_fornitore = intest_fornitore
                  header           = header
                  item             = item
                  oda              = oda
                  ddt              = ddt
                  ritenuta         = ritenuta
                  cassa            = cassa
                  allegati         = allegati
                  message          = error_text
                  notifica         = notifica
                CHANGING
                  xml              = xml.

            ENDIF.

          CATCH cx_badi_not_implemented.

        ENDTRY.

        IF error_text IS NOT INITIAL.

          gs_upload_log-comments = error_text.
          RETURN.

        ENDIF.

* Elaborazione della Soluzione Custom
        TRY.

            GET BADI badi_soluzione.

            IF badi_soluzione IS BOUND.

              CALL BADI badi_soluzione->handle_soluzione
                EXPORTING
                  interfaccia      = p_int
                  file_name        = i_filename
                  trasmissione     = trasmissione
                  intest_societa   = intest_societa
                  intest_fornitore = intest_fornitore
                  header           = header
                  item             = item
                  oda              = oda
                  ddt              = ddt
                  ritenuta         = ritenuta
                  cassa            = cassa
                  allegati         = allegati
                  message          = error_text
                  notifica         = notifica.

            ENDIF.

          CATCH cx_badi_not_implemented.

        ENDTRY.

        IF error_text IS NOT INITIAL.

          gs_upload_log-comments = error_text.
          RETURN.

        ENDIF.

    ENDCASE.

  ENDMETHOD.                    "soluzione

ENDCLASS.                    "lcl_main IMPLEMENTATION

DATA: go_report  TYPE REF TO lcl_main.

START-OF-SELECTION.

* Recupero il customizing dell'interfaccia
  SELECT SINGLE * FROM zefatt_int_conf INTO gs_int_conf
         WHERE interfaccia = p_int.

  IF sy-subrc <> 0.

    MESSAGE s020(zefattura) WITH p_int.
    STOP.

  ENDIF.
  CREATE OBJECT go_report.

  CASE gs_int_conf-interfaccia_tipo.

    WHEN 'F' OR 'A'. " FTP/File logico

* Upload file e creazione record
      go_report->upload_file( ).

    WHEN 'S' OR 'R'. " WebService SOAP/RestFull

* Richiamo API
      go_report->call_webservice( ).

  ENDCASE.

* Invio mail con shortcut delle eFattura da elaborare solo se presente e attivato
* il pacchetto ZEFATTURA - Fattura Elettronica - Flusso Passivo
  INCLUDE zsend_mail_for_cockpit IF FOUND.

  go_report->display_data( ).

*&---------------------------------------------------------------------*
*& Form ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM alv .

  PERFORM fieldcat.
  PERFORM layout.
  PERFORM display.

ENDFORM.                    "alv
*&---------------------------------------------------------------------*
*& Form FIELDCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fieldcat .

  FIELD-SYMBOLS: <fieldcat> TYPE slis_fieldcat_alv.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-cprog
      i_structure_name       = 'ZEFATT_UPLOAD_LOG'
      i_inclname             = sy-cprog
      i_bypassing_buffer     = 'X'
    CHANGING
      ct_fieldcat            = it_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  LOOP AT it_fieldcat ASSIGNING <fieldcat>.

    CASE <fieldcat>-fieldname.
      WHEN 'SEL'.
        <fieldcat>-no_out  = 'X'.
      WHEN 'ICON'.
        <fieldcat>-icon  = 'X'.
    ENDCASE.

  ENDLOOP.

ENDFORM.                    "fieldcat
*&---------------------------------------------------------------------*
*& Form LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM layout .

  is_layout-zebra             = 'X'.
  is_layout-colwidth_optimize = 'X'.
  is_layout-box_fieldname     = 'SEL'.

ENDFORM.                    "layout
*&---------------------------------------------------------------------*
*& Form DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display .

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-cprog
      i_callback_pf_status_set = 'PF_STATUS_SET'
      i_callback_user_command  = 'USER_COMMAND'
      is_layout                = is_layout
      it_fieldcat              = it_fieldcat
      i_save                   = 'A'
    TABLES
      t_outtab                 = gt_upload_log
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.                    "display
*&---------------------------------------------------------------------*
*&      Form  PF_STATUS_SET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EXTAB   text
*----------------------------------------------------------------------*
FORM pf_status_set USING rt_extab TYPE slis_t_extab.

  SET PF-STATUS 'UPLOAD'.

ENDFORM.                    "pf_status_set
*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM user_command  USING r_ucomm     LIKE sy-ucomm
                         rs_selfield TYPE slis_selfield.

ENDFORM.                    "user_command
