class ZCL_EFATT_FTP_FILEPROVIDER definition
  public
  final
  create private

  global friends ZCL_EFATT_FILEPROVIDER_FACTORY .

*"* public components of class ZCL_EFATT_FTP_FILEPROVIDER
*"* do not include other source files here!!!
public section.
  type-pools ABAP .

  interfaces ZIF_EFATT_FILEPROVIDER .
protected section.
*"* protected components of class ZCL_EFATT_FTP_FILEPROVIDER
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_EFATT_FTP_FILEPROVIDER
*"* do not include other source files here!!!

  types:
    efatt_ftp_line(255) TYPE c .
  types:
    efatt_ftp_line_tt TYPE STANDARD TABLE OF efatt_ftp_line .

  data M_WORK_DIR type STRING .
  data M_WORK_DIR_BCK type STRING .
  data M_FTP_CONN_ID type I .
  data M_DELETE_FILE type ZEFATT_DEL_FILE .

  methods GET_FILE_LISTING_UNIX
    importing
      !I_ONLY_FILES type ABAP_BOOL default ABAP_TRUE
    changing
      !CT_TEXTLINES type EFATT_FTP_LINE_TT
      !CT_FILES type ZEFATT_FILEDESCRIPTOR_T .
  methods GET_VALUES_FROM_LINE
    importing
      !I_LINE type EFATT_FTP_LINE
    exporting
      !E_NAME type EFATT_FTP_LINE
      !E_SIZE type EFATT_FTP_LINE
      !E_DATE type EFATT_FTP_LINE .
ENDCLASS.



CLASS ZCL_EFATT_FTP_FILEPROVIDER IMPLEMENTATION.


METHOD get_file_listing_unix .

  DATA: l_start TYPE i,
        l_end   TYPE i.
  DATA: l_textline    TYPE efatt_ftp_line.
  DATA: l_linelen     TYPE i.
  DATA: l_totalstr(5) TYPE c.
  DATA: l_onefile     TYPE zefatt_filedescriptor.
  DATA: l_filename TYPE efatt_ftp_line,
        l_filesize TYPE efatt_ftp_line,
        l_filedate TYPE efatt_ftp_line.

  l_start = 1.
  l_end = 0.
  LOOP AT ct_textlines INTO l_textline.
    IF l_start = 1.
      ADD 1 TO l_start.
      CONTINUE.                            " repeat the command
    ENDIF.
    l_linelen = strlen( l_textline ).

    IF ( l_linelen > 4 ) AND
       ( ( l_textline(4) = '200 ' ) OR
       ( l_textline(4) = '150 ' ) ).     " initial status
      ADD 1 TO l_start.
      CONTINUE.
    ENDIF.
    IF l_linelen > 5.
      l_totalstr = l_textline(5).
      TRANSLATE l_totalstr TO UPPER CASE.
      IF l_totalstr = 'TOTAL'.
        ADD 1 TO l_start.
        CONTINUE.                      " length sum line
      ENDIF.
    ENDIF.
    IF ( l_linelen > 4 ) AND
       ( l_textline(4) = '226 ' ).
      EXIT.
    ENDIF.
*   ok, listing line
    IF l_end = 0.
      l_end = l_start.
    ELSE.
      ADD 1 TO l_end.
    ENDIF.
  ENDLOOP.

  IF l_end < l_start.   " nothing
    EXIT.
  ENDIF.

* extract
  LOOP AT ct_textlines INTO l_textline FROM l_start TO l_end.
    CLEAR l_onefile.
    CASE l_textline(1).
      WHEN 'd'. " Directory
        IF NOT i_only_files = abap_true.
          l_onefile-type = 'D'.
          CALL METHOD me->get_values_from_line
            EXPORTING
              i_line = l_textline
            IMPORTING
              e_name = l_filename
              e_date = l_filedate.
          IF NOT l_filename IS INITIAL.
            l_onefile-filename = l_filename.
            l_onefile-filedate = l_filedate.
            APPEND l_onefile TO ct_files.
          ENDIF.
        ENDIF.
      WHEN 'l'. " Link - ignore it
      WHEN '-'.
        l_onefile-type = 'F'.
        CALL METHOD me->get_values_from_line
          EXPORTING
            i_line = l_textline
          IMPORTING
            e_name = l_filename
            e_size = l_filesize
            e_date = l_filedate.
        IF NOT l_filename IS INITIAL.
          l_onefile-filename = l_filename.
          l_onefile-filesize = l_filesize.
          l_onefile-filedate = l_filedate.
          APPEND l_onefile TO ct_files.
        ENDIF.
    ENDCASE.
  ENDLOOP.
ENDMETHOD.


METHOD get_values_from_line .

  DATA: l_f1    TYPE efatt_ftp_line,
        l_f2    TYPE efatt_ftp_line,
        l_f3    TYPE efatt_ftp_line,
        l_f4    TYPE efatt_ftp_line,
        l_f5    TYPE efatt_ftp_line,
        l_f6    TYPE efatt_ftp_line,
        l_f7    TYPE efatt_ftp_line,
        l_f8    TYPE efatt_ftp_line,
        l_frest TYPE efatt_ftp_line,
        giorno  TYPE char2,
        mese    TYPE char2,
        anno    TYPE char4.

* 1
  IF i_line IS INITIAL.
    EXIT.
  ENDIF.
  SPLIT i_line AT space INTO l_f1 l_frest.
  SHIFT l_frest LEFT DELETING LEADING space.
* 2
  IF l_frest IS INITIAL.
    EXIT.
  ENDIF.
  SPLIT l_frest AT space INTO l_f2 l_frest.
  SHIFT l_frest LEFT DELETING LEADING space.
* 3
  IF l_frest IS INITIAL.
    EXIT.
  ENDIF.
  SPLIT l_frest AT space INTO l_f3 l_frest.
  SHIFT l_frest LEFT DELETING LEADING space.
* 4
  IF l_frest IS INITIAL.
    EXIT.
  ENDIF.
  SPLIT l_frest AT space INTO l_f4 l_frest.
  SHIFT l_frest LEFT DELETING LEADING space.
* 5
  IF l_frest IS INITIAL.
    EXIT.
  ENDIF.
  SPLIT l_frest AT space INTO l_f5 l_frest.
  SHIFT l_frest LEFT DELETING LEADING space.
* 6
  IF l_frest IS INITIAL.
    EXIT.
  ENDIF.
  SPLIT l_frest AT space INTO l_f6 l_frest.
  SHIFT l_frest LEFT DELETING LEADING space.
* 7
  IF l_frest IS INITIAL.
    EXIT.
  ENDIF.
  SPLIT l_frest AT space INTO l_f7 l_frest.
  SHIFT l_frest LEFT DELETING LEADING space.
* 8
  IF l_frest IS INITIAL.
    EXIT.
  ENDIF.
  SPLIT l_frest AT space INTO l_f8 l_frest.
  SHIFT l_frest LEFT DELETING LEADING space.

  CLEAR: e_name, e_size, e_date.

  IF ( l_f5 = 'Jan' ) OR
     ( l_f5 = 'Feb' ) OR
     ( l_f5 = 'Mar' ) OR
     ( l_f5 = 'Apr' ) OR
     ( l_f5 = 'May' ) OR
     ( l_f5 = 'Jun' ) OR
     ( l_f5 = 'Jul' ) OR
     ( l_f5 = 'Aug' ) OR
     ( l_f5 = 'Sep' ) OR
     ( l_f5 = 'Oct' ) OR
     ( l_f5 = 'Nov' ) OR
     ( l_f5 = 'Dec' ).

    e_size = l_f4.
    e_name = l_f8.

    CASE l_f5.
      WHEN 'Jan'. mese = '01'.
      WHEN 'Feb'. mese = '02'.
      WHEN 'Mar'. mese = '03'.
      WHEN 'Apr'. mese = '04'.
      WHEN 'May'. mese = '05'.
      WHEN 'Jun'. mese = '06'.
      WHEN 'Jul'. mese = '07'.
      WHEN 'Aug'. mese = '08'.
      WHEN 'Sep'. mese = '09'.
      WHEN 'Oct'. mese = '10'.
      WHEN 'Nov'. mese = '11'.
      WHEN 'Dec'. mese = '12'.
    ENDCASE.

    UNPACK l_f6 TO giorno.

    CONCATENATE sy-datum(4) mese giorno INTO e_date.

    IF strlen( l_f7 ) = 4.

      anno = l_f7(4).

      IF anno CO '0123456789'.
        CONCATENATE anno mese giorno INTO e_date.
      ELSE.
        CONCATENATE sy-datum(4) mese giorno INTO e_date.
      ENDIF.

    ELSE.

      CONCATENATE sy-datum(4) mese giorno INTO e_date.

    ENDIF.

  ENDIF.

  IF ( l_f6 = 'Jan' ) OR
     ( l_f6 = 'Feb' ) OR
     ( l_f6 = 'Mar' ) OR
     ( l_f6 = 'Apr' ) OR
     ( l_f6 = 'May' ) OR
     ( l_f6 = 'Jun' ) OR
     ( l_f6 = 'Jul' ) OR
     ( l_f6 = 'Aug' ) OR
     ( l_f6 = 'Sep' ) OR
     ( l_f6 = 'Oct' ) OR
     ( l_f6 = 'Nov' ) OR
     ( l_f6 = 'Dec' ).

    e_size = l_f5.
    e_name = l_frest.

    CASE l_f6.
      WHEN 'Jan'. mese = '01'.
      WHEN 'Feb'. mese = '02'.
      WHEN 'Mar'. mese = '03'.
      WHEN 'Apr'. mese = '04'.
      WHEN 'May'. mese = '05'.
      WHEN 'Jun'. mese = '06'.
      WHEN 'Jul'. mese = '07'.
      WHEN 'Aug'. mese = '08'.
      WHEN 'Sep'. mese = '09'.
      WHEN 'Oct'. mese = '10'.
      WHEN 'Nov'. mese = '11'.
      WHEN 'Dec'. mese = '12'.
    ENDCASE.

    UNPACK l_f7 TO giorno.

    IF strlen( l_f8 ) = 4.

      anno = l_f8(4).

      IF anno CO '0123456789'.
        CONCATENATE anno mese giorno INTO e_date.
      ELSE.
        CONCATENATE sy-datum(4) mese giorno INTO e_date.
      ENDIF.

    ELSE.

      CONCATENATE sy-datum(4) mese giorno INTO e_date.

    ENDIF.

  ENDIF.

ENDMETHOD.


  METHOD zif_efatt_fileprovider~close.

    CALL FUNCTION 'FTP_DISCONNECT'
      EXPORTING
        handle = m_ftp_conn_id.

    IF sy-subrc <> 0.

      return-id         = sy-msgid.
      return-type       = sy-msgty.
      return-number     = sy-msgno.
      return-message_v1 = sy-msgv1.
      return-message_v2 = sy-msgv2.
      return-message_v3 = sy-msgv3.
      return-message_v4 = sy-msgv4.

      RETURN.

    ENDIF.

    CALL FUNCTION 'RFC_CONNECTION_CLOSE'
      EXPORTING
        destination = 'SAPFTPA'.

    IF sy-subrc <> 0.

      return-id         = sy-msgid.
      return-type       = sy-msgty.
      return-number     = sy-msgno.
      return-message_v1 = sy-msgv1.
      return-message_v2 = sy-msgv2.
      return-message_v3 = sy-msgv3.
      return-message_v4 = sy-msgv4.

      RETURN.

    ENDIF.

  ENDMETHOD.


  METHOD zif_efatt_fileprovider~delete_file.

    DATA: l_command(300)  TYPE c.
    DATA: lt_data         TYPE efatt_ftp_line_tt.
    DATA: l_filename(300) TYPE c.
    DATA: l_err_txt       TYPE string.
    DATA: l_sysubrc       TYPE i.

    CONCATENATE '"' i_filename '"' INTO l_filename.
    CONCATENATE 'delete' l_filename INTO l_command SEPARATED BY space.

    CALL FUNCTION 'FTP_COMMAND'
      EXPORTING
        handle        = m_ftp_conn_id
        command       = l_command
      TABLES
        data          = lt_data
      EXCEPTIONS
        tcpip_error   = 1
        command_error = 2
        data_error    = 3
        OTHERS        = 4.

    IF sy-subrc <> 0.

      return-id         = sy-msgid.
      return-type       = sy-msgty.
      return-number     = sy-msgno.
      return-message_v1 = sy-msgv1.
      return-message_v2 = sy-msgv2.
      return-message_v3 = sy-msgv3.
      return-message_v4 = sy-msgv4.

      RETURN.

    ENDIF.

  ENDMETHOD.


  METHOD zif_efatt_fileprovider~get_file_listing.

    DATA: l_command(300) TYPE c,
          lt_data        TYPE tchar255.

* Posiziomento sulla cartella di lavoro
    CONCATENATE 'cd' m_work_dir INTO l_command SEPARATED BY space.

    CALL FUNCTION 'FTP_COMMAND'
      EXPORTING
        handle        = m_ftp_conn_id
        command       = l_command
      TABLES
        data          = lt_data
      EXCEPTIONS
        tcpip_error   = 1
        command_error = 2
        data_error    = 3
        OTHERS        = 4.

    IF sy-subrc <> 0.

      return-id         = sy-msgid.
      return-type       = sy-msgty.
      return-number     = sy-msgno.
      return-message_v1 = sy-msgv1.
      return-message_v2 = sy-msgv2.
      return-message_v3 = sy-msgv3.
      return-message_v4 = sy-msgv4.

      RETURN.

    ENDIF.

    REFRESH lt_data.

* Recupero solo i file XML
    CALL FUNCTION 'FTP_COMMAND'
      EXPORTING
        handle        = m_ftp_conn_id
        command       = 'ls *.xml*'
      TABLES
        data          = lt_data
      EXCEPTIONS
        tcpip_error   = 1
        command_error = 2
        data_error    = 3
        OTHERS        = 4.

    IF sy-subrc <> 0.

      return-id         = sy-msgid.
      return-type       = sy-msgty.
      return-number     = sy-msgno.
      return-message_v1 = sy-msgv1.
      return-message_v2 = sy-msgv2.
      return-message_v3 = sy-msgv3.
      return-message_v4 = sy-msgv4.

      RETURN.

    ENDIF.

* Recupero la lista dei nomi dei file in maniera formattata
    CLEAR et_files.
    CALL METHOD me->get_file_listing_unix
      EXPORTING
        i_only_files = 'X'
      CHANGING
        ct_textlines = lt_data
        ct_files     = et_files.

  ENDMETHOD.


  METHOD zif_efatt_fileprovider~read_file.

    DATA: l_filename(1000).

    CLEAR et_content.

    CONCATENATE m_work_dir i_filename INTO l_filename.

    CALL FUNCTION 'FTP_SERVER_TO_R3'
      EXPORTING
        handle         = m_ftp_conn_id
        fname          = l_filename
        character_mode = space
      IMPORTING
        blob_length    = e_size
      TABLES
        blob           = et_content
      EXCEPTIONS
        tcpip_error    = 1
        command_error  = 2
        data_error     = 3
        OTHERS         = 4.

    IF sy-subrc <> 0.

      return-id         = sy-msgid.
      return-type       = sy-msgty.
      return-number     = sy-msgno.
      return-message_v1 = sy-msgv1.
      return-message_v2 = sy-msgv2.
      return-message_v3 = sy-msgv3.
      return-message_v4 = sy-msgv4.

      RETURN.

    ENDIF.

  ENDMETHOD.


  METHOD zif_efatt_fileprovider~set_work_directory.

    SELECT SINGLE path backup delete_file FROM zefatt_conf_ftp INTO (m_work_dir, m_work_dir_bck, m_delete_file)
           WHERE bukrs       = bukrs
           AND   interfaccia = interfaccia
           AND   active      = 'X'.

    IF sy-subrc <> 0.

      return-id         = 'ZEFATTURA'.
      return-type       = 'E'.
      return-number     = '021'.

    ENDIF.

  ENDMETHOD.


METHOD zif_efatt_fileprovider~transfer_file.

  DATA: data          TYPE TABLE OF text1000,
        path_from     TYPE  string,
        path_to       TYPE  string,
        command(1000).

* Se configurata la cartella di backup trasferisco il file altrimenti lo elimino
  IF m_work_dir_bck IS NOT INITIAL.

* Rinomina file
    CONCATENATE m_work_dir     i_filename INTO path_from.
    CONCATENATE m_work_dir_bck i_filename INTO path_to.

    CONCATENATE 'rename' path_from path_to INTO command SEPARATED BY space.

    CALL FUNCTION 'FTP_COMMAND'
      EXPORTING
        handle        = m_ftp_conn_id
        command       = command
        compress      = 'N'
      TABLES
        data          = data
      EXCEPTIONS
        tcpip_error   = 1
        command_error = 2
        data_error    = 3
        OTHERS        = 4.

    IF sy-subrc <> 0.

      return-id         = sy-msgid.
      return-type       = sy-msgty.
      return-number     = sy-msgno.
      return-message_v1 = sy-msgv1.
      return-message_v2 = sy-msgv2.
      return-message_v3 = sy-msgv3.
      return-message_v4 = sy-msgv4.

      RETURN.

    ENDIF.

  ELSE.

* Elimino il file dalla cartella sorgente se settato in customizing
    IF m_delete_file = 'X'.
      me->zif_efatt_fileprovider~delete_file( i_filename = i_filename ).
    ENDIF.

  ENDIF.

ENDMETHOD.


  METHOD zif_efatt_fileprovider~write_file.

    DATA: l_filename TYPE efatt_ftp_line.

    CONCATENATE m_work_dir i_filename INTO l_filename.

    CALL FUNCTION 'FTP_R3_TO_SERVER'
      EXPORTING
        handle         = m_ftp_conn_id
        fname          = l_filename
        blob_length    = i_filesize
        character_mode = space
      TABLES
        blob           = it_content
      EXCEPTIONS
        tcpip_error    = 1
        command_error  = 2
        data_error     = 3
        OTHERS         = 4.

    IF sy-subrc <> 0.

      return-id         = sy-msgid.
      return-type       = sy-msgty.
      return-number     = sy-msgno.
      return-message_v1 = sy-msgv1.
      return-message_v2 = sy-msgv2.
      return-message_v3 = sy-msgv3.
      return-message_v4 = sy-msgv4.

      RETURN.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
