*&---------------------------------------------------------------------*
*& Report ZEFATT_INBOUND_UPLOAD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zefatt_inbound_upload.

TYPE-POOLS slis.

CONSTANTS: gc_icon_green TYPE icon_d VALUE '@5B@',
           gc_icon_red   TYPE icon_d VALUE '@5C@'.

DATA: gt_file          TYPE filetable,
      gt_file_info     TYPE STANDARD TABLE OF file_info,
      gs_upload_log    TYPE zefatt_upload_log,
      gt_upload_log    TYPE STANDARD TABLE OF zefatt_upload_log,
      it_fieldcat      TYPE slis_t_fieldcat_alv,
      is_layout        TYPE slis_layout_alv,
      lt_efatt_mail    TYPE STANDARD TABLE OF zefatt_mail,
      obj_descr        TYPE so_obj_des,
      gs_int_conf      TYPE zefatt_int_conf,
      badi_soluzione   TYPE REF TO zfatt_badi_soluzione,
      xml              TYPE xstring,
      trasmissione     TYPE zefatt_intest_trasmissione,
      intest_societa   TYPE zefatt_intest_map,
      intest_fornitore TYPE zefatt_intest_for_map,
      header           TYPE zefatt_header_map_t,
      item             TYPE zefatt_item_map_t,
      oda              TYPE zefatt_oda_map_t,
      ddt              TYPE zefatt_ddt_map_t,
      ritenuta         TYPE zefatt_ritenuta_map_t,
      cassa            TYPE zefatt_cassa_map_t,
      contratto        TYPE zefatt_contratto_map_t,
      fatture          TYPE zefatt_fatture_map_t,
      ricezione        TYPE zefatt_ricezione_map_t,
      convenzione      TYPE zefatt_convenzione_map_t,
      allegati         TYPE zefatt_attach_map_t,
      error_text       TYPE bapiret2-message,
      notifica         TYPE zfatt_notif_map,
      file_name        TYPE zefatt_file_name,
      i_filename       TYPE string,
      sdi_date         TYPE zefatt_sdi_date.

FIELD-SYMBOLS: <fs_efatt_mail> TYPE zefatt_mail.

* Parametri di selezione
SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-011.
  PARAMETERS: p_int TYPE zefatt_interfaccia OBLIGATORY MATCHCODE OBJECT zefatt_int_in_h.
SELECTION-SCREEN END OF BLOCK b02.

SELECTION-SCREEN BEGIN OF BLOCK b03 WITH FRAME TITLE TEXT-012.
  PARAMETERS: p_sdi TYPE zefatt_sdi_date.
SELECTION-SCREEN END OF BLOCK b03.

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-001 .

  SELECTION-SCREEN BEGIN OF LINE.

    PARAMETERS: p_file RADIOBUTTON GROUP fil DEFAULT 'X' USER-COMMAND fol MODIF ID env.

    SELECTION-SCREEN COMMENT 3(40) TEXT-002 FOR FIELD p_file MODIF ID env.
    PARAMETERS: p_fpath TYPE string MODIF ID env.

  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.

    PARAMETERS: p_dir RADIOBUTTON GROUP fil MODIF ID env.

    SELECTION-SCREEN COMMENT 3(40) TEXT-003 FOR FIELD p_dir MODIF ID env.
    PARAMETERS: p_dpath TYPE string MODIF ID env.

  SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK b01 .

SELECTION-SCREEN BEGIN OF BLOCK b04 WITH FRAME TITLE TEXT-014.

  SELECTION-SCREEN BEGIN OF LINE.

    SELECTION-SCREEN COMMENT 3(40) TEXT-015 FOR FIELD p_bck MODIF ID env.
    PARAMETERS: p_bck TYPE string MODIF ID env OBLIGATORY.

  SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK b04.


*----------------------------------------------------------------------*
*       CLASS lcl_main DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_main DEFINITION FINAL.

  PUBLIC SECTION.

    METHODS display_data.
    METHODS display_alv.
    METHODS upload_file.

  PRIVATE SECTION.

*   Private methods
    METHODS copy_file   IMPORTING iv_file  TYPE string
                                  filename TYPE char1024.
    METHODS upload      IMPORTING iv_source   TYPE string
                        EXPORTING ev_uploaded TYPE boolean.
    METHODS backup_file IMPORTING source      TYPE string
                                  destination TYPE string.

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

  METHOD upload_file.

    DATA: ls_file      TYPE file_table,
          ls_file_info TYPE file_info, "zefatt_file_name_c255,
          lv_file_path TYPE string, "zefatt_file_name_c255,
          file_name    TYPE char1024,
          lv_len       TYPE i,
          lv_separator TYPE c.

    IF p_file EQ 'X'.

      sdi_date = p_sdi.

      lv_file_path = p_fpath.

      CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
        EXPORTING
          full_name     = lv_file_path
        IMPORTING
          stripped_name = file_name
        EXCEPTIONS
          x_error       = 1
          OTHERS        = 2.

      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      copy_file( EXPORTING iv_file  = lv_file_path
                           filename = file_name ).

      CLEAR sdi_date.

    ELSEIF p_dir EQ 'X'.

      CLEAR: lv_file_path.

      lv_len = strlen( p_dpath ).
      lv_len = lv_len - 1.

      IF p_dpath+lv_len(1) EQ '\'.
        CLEAR: lv_separator.
      ELSE.
        lv_separator = '\'.
      ENDIF.

      LOOP AT gt_file_info INTO ls_file_info.

        CONCATENATE p_dpath lv_separator ls_file_info-filename INTO lv_file_path.

        IF p_sdi IS INITIAL.
          sdi_date = ls_file_info-writedate.
        ELSE.
          sdi_date = p_sdi.
        ENDIF.

        copy_file( EXPORTING iv_file  = lv_file_path
                             filename = ls_file_info-filename ).

        CLEAR sdi_date.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.                    "upload_file

  METHOD copy_file.

    DATA: lv_path          TYPE string,
          lv_file_uploaded TYPE boolean,
          source           TYPE string,
          destination      TYPE string,
          file_separator.

    lv_path = iv_file.

    upload( EXPORTING iv_source   = lv_path
            IMPORTING ev_uploaded = lv_file_uploaded ).

    gs_upload_log-filename = filename.

    IF lv_file_uploaded NE 'X'.

      gs_upload_log-icon     = gc_icon_red.

    ELSE.

      gs_upload_log-icon     = gc_icon_green.
      gs_upload_log-comments = TEXT-009.

* Sposto il file nella cartella di backup
      cl_gui_frontend_services=>get_file_separator(
        CHANGING
          file_separator       = file_separator
        EXCEPTIONS
          cntl_error           = 1
          error_no_gui         = 2
          not_supported_by_gui = 3
          OTHERS               = 4 ).

      IF sy-subrc <> 0.
        RETURN.
      ENDIF.

      source = iv_file.
      CONCATENATE p_bck file_separator filename INTO destination.

      backup_file( EXPORTING source      = source
                             destination = destination ).

    ENDIF.

    APPEND gs_upload_log TO gt_upload_log.

  ENDMETHOD.                    "copy_file.

  METHOD upload.

    TYPES: BEGIN OF ty_data_tab,
             line(64) TYPE x,
           END OF ty_data_tab.

    DATA: ls_data_tab  TYPE ty_data_tab,
          lt_data_tab  TYPE STANDARD TABLE OF ty_data_tab,
          lv_fl_length TYPE i,
          i_filename   TYPE string.

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
           file_name.

    CLEAR lt_data_tab.
    CALL METHOD cl_gui_frontend_services=>gui_upload
      EXPORTING
        filename                = iv_source
        filetype                = 'BIN'
      IMPORTING
        filelength              = lv_fl_length
      CHANGING
        data_tab                = lt_data_tab
      EXCEPTIONS
        file_open_error         = 1
        file_read_error         = 2
        no_batch                = 3
        gui_refuse_filetransfer = 4
        invalid_type            = 5
        no_authority            = 6
        unknown_error           = 7
        bad_data_format         = 8
        header_not_allowed      = 9
        separator_not_allowed   = 10
        header_too_long         = 11
        unknown_dp_error        = 12
        access_denied           = 13
        dp_out_of_memory        = 14
        disk_full               = 15
        dp_timeout              = 16
        not_supported_by_gui    = 17
        error_no_gui            = 18
        OTHERS                  = 19.

    IF sy-subrc NE 0.

      MESSAGE e006(zefattura) INTO gs_upload_log-comments.
      RETURN.

    ENDIF.

    CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
      EXPORTING
        input_length = lv_fl_length
      IMPORTING
        buffer       = xml
      TABLES
        binary_tab   = lt_data_tab
      EXCEPTIONS
        failed       = 1
        OTHERS       = 2.

    IF sy-subrc <> 0.

      MESSAGE e007(zefattura) INTO gs_upload_log-comments.
      RETURN.

    ENDIF.

    CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
      EXPORTING
        full_name     = iv_source
      IMPORTING
        stripped_name = file_name
      EXCEPTIONS
        x_error       = 1
        OTHERS        = 2.

    IF sy-subrc <> 0.

      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
               INTO gs_upload_log-comments.

      RETURN.

    ENDIF.

    i_filename = file_name.

    CASE gs_int_conf-soluzione.

      WHEN 'A' OR  " Creazione Automatica documento in entrata.
           'M'.    " Creazione Documento tramite Cockpit

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

    ev_uploaded = 'X'.

  ENDMETHOD.                    "upload.

  METHOD backup_file.           " backup_file

    DATA: rc TYPE i.

    cl_gui_frontend_services=>file_copy(
      EXPORTING
        source               = source
        destination          = destination
        overwrite            = 'X'
      EXCEPTIONS
        cntl_error           = 1
        error_no_gui         = 2
        wrong_parameter      = 3
        disk_full            = 4
        access_denied        = 5
        file_not_found       = 6
        destination_exists   = 7
        unknown_error        = 8
        path_not_found       = 9
        disk_write_protect   = 10
        drive_not_ready      = 11
        not_supported_by_gui = 12
        OTHERS               = 13 ).

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    cl_gui_frontend_services=>file_delete(
      EXPORTING
        filename             = source
      CHANGING
        rc                   = rc
      EXCEPTIONS
        file_delete_failed   = 1
        cntl_error           = 2
        error_no_gui         = 3
        file_not_found       = 4
        access_denied        = 5
        unknown_error        = 6
        not_supported_by_gui = 7
        wrong_parameter      = 8 ).

    IF sy-subrc <> 0.

    ENDIF.

  ENDMETHOD.                    "backup_file

ENDCLASS.                    "lcl_main IMPLEMENTATION

DATA: go_report  TYPE REF TO lcl_main.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fpath.
  PERFORM file_input.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_dpath.
  PERFORM folder_input USING p_dpath.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_bck.
  PERFORM folder_input USING p_bck.

AT SELECTION-SCREEN.
  PERFORM check_manditory_fields.
  PERFORM file_validations.

START-OF-SELECTION.

* Recupero il customizing dell'interfaccia
  SELECT SINGLE * FROM zefatt_int_conf INTO gs_int_conf
         WHERE interfaccia = p_int.

  IF sy-subrc <> 0.

    MESSAGE s020(zefattura) WITH p_int.
    STOP.

  ENDIF.

  CREATE OBJECT go_report.

* Upload file e creazione record
  go_report->upload_file( ).

* Invio mail con shortcut delle eFattura da elaborare
  READ TABLE gt_upload_log TRANSPORTING NO FIELDS WITH KEY icon = gc_icon_green.

  IF sy-subrc = 0.

    SELECT * FROM zefatt_mail INTO TABLE lt_efatt_mail.

    LOOP AT lt_efatt_mail ASSIGNING <fs_efatt_mail>.

      zcl_efatt_util=>send_mail_with_shortcut( recipient_user_id = <fs_efatt_mail>-uname
                                               report            = 'ZEFATTURA_COCKPIT_TO_PROCESS'
                                               name              = 'ZMAIL'
                                               obj_descr         = obj_descr ).

    ENDLOOP.

  ENDIF.

* Display ALV
  go_report->display_data( ).

*&---------------------------------------------------------------------*
*& Form FILE_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM file_input .

  DATA: lv_no    TYPE i,
        ls_file  TYPE file_table,
        lv_title TYPE string.

  lv_title = TEXT-004.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = lv_title
      default_extension       = 'XML'
      default_filename        = '*.XML*'
      multiselection          = ' '
    CHANGING
      file_table              = gt_file
      rc                      = lv_no
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  IF sy-subrc EQ 0.

    READ TABLE gt_file INTO ls_file INDEX 1.

    IF sy-subrc EQ 0.
      p_fpath = ls_file-filename.
    ENDIF.

  ENDIF.


ENDFORM.                    "file_input
*&---------------------------------------------------------------------*
*& Form FOLDER_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM folder_input USING selected_folder TYPE string.

  DATA: lv_title TYPE string.

  lv_title = TEXT-005.

  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title         = lv_title
    CHANGING
      selected_folder      = selected_folder
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.                    "folder_input
*&---------------------------------------------------------------------*
*& Form CHECK_MANDITORY_FIELDS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_manditory_fields .

  IF sy-ucomm EQ 'ONLI'.

    IF p_file EQ 'X'.

      IF p_sdi IS INITIAL.

        SET CURSOR FIELD 'P_SDI'.
        MESSAGE TEXT-018 TYPE 'E'.

      ENDIF.

      IF p_fpath IS INITIAL.

        SET CURSOR FIELD 'P_FPATH'.
        MESSAGE TEXT-006 TYPE 'E'.

      ENDIF.

    ELSEIF p_dir EQ 'X'.

      IF p_dpath IS INITIAL.

        SET CURSOR FIELD 'P_DPATH'.
        MESSAGE TEXT-007 TYPE 'E'.

      ENDIF.

    ENDIF.

    IF p_sdi IS NOT INITIAL.

      IF p_sdi > sy-datum.

        SET CURSOR FIELD 'P_SDI'.
        MESSAGE TEXT-013 TYPE 'E'.

      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.                    "check_manditory_fields
*&---------------------------------------------------------------------*
*& Form FILE_VALIDATIONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM file_validations .

  DATA: lv_value      TYPE string,
        lv_result     TYPE boole_d,
        lv_file_count TYPE i.

  IF sy-ucomm EQ 'ONLI'.

    IF p_file EQ 'X'.

      lv_value = p_fpath.
      CALL METHOD cl_gui_frontend_services=>file_exist
        EXPORTING
          file                 = lv_value
        RECEIVING
          result               = lv_result
        EXCEPTIONS
          cntl_error           = 1
          error_no_gui         = 2
          wrong_parameter      = 3
          not_supported_by_gui = 4
          OTHERS               = 5.

      IF sy-subrc <> 0.

        MESSAGE ID  sy-msgid TYPE sy-msgty NUMBER sy-msgno
                             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.


      ENDIF.

    ELSEIF p_dir EQ 'X'.

      lv_value = p_dpath.
      CALL METHOD cl_gui_frontend_services=>directory_exist
        EXPORTING
          directory            = lv_value
        RECEIVING
          result               = lv_result
        EXCEPTIONS
          cntl_error           = 1
          error_no_gui         = 2
          wrong_parameter      = 3
          not_supported_by_gui = 4
          OTHERS               = 5.

      IF sy-subrc <> 0.

        MESSAGE ID  sy-msgid TYPE sy-msgty NUMBER sy-msgno
                             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

      ELSE.

        IF lv_result IS INITIAL.

          MESSAGE TEXT-016 TYPE 'E'.

        ENDIF.

        lv_value = p_bck.
        CALL METHOD cl_gui_frontend_services=>directory_exist
          EXPORTING
            directory            = lv_value
          RECEIVING
            result               = lv_result
          EXCEPTIONS
            cntl_error           = 1
            error_no_gui         = 2
            wrong_parameter      = 3
            not_supported_by_gui = 4
            OTHERS               = 5.

        IF sy-subrc <> 0.

          MESSAGE ID  sy-msgid TYPE sy-msgty NUMBER sy-msgno
                               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

        ELSE.

          IF lv_result IS INITIAL.

            MESSAGE TEXT-017 TYPE 'E'.

          ENDIF.

          CALL METHOD cl_gui_frontend_services=>directory_list_files
            EXPORTING
              directory                   = p_dpath
              filter                      = '*.XML*'
              files_only                  = 'X'
            CHANGING
*             file_table                  = gt_file
              file_table                  = gt_file_info
              count                       = lv_file_count
            EXCEPTIONS
              cntl_error                  = 1
              directory_list_files_failed = 2
              wrong_parameter             = 3
              error_no_gui                = 4
              not_supported_by_gui        = 5
              OTHERS                      = 6.

          IF sy-subrc <> 0.

            MESSAGE ID  sy-msgid TYPE sy-msgty NUMBER sy-msgno
                                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

          ENDIF.

          IF gt_file_info IS INITIAL.
            MESSAGE TEXT-008 TYPE 'E'.
          ENDIF.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.                    "file_validations
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
      i_bypassing_buffer     = abap_true
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
