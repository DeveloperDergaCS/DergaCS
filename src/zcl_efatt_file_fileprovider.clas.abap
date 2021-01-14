class ZCL_EFATT_FILE_FILEPROVIDER definition
  public
  final
  create private

  global friends ZCL_EFATT_FILEPROVIDER_FACTORY .

*"* public components of class ZCL_EFATT_FILE_FILEPROVIDER
*"* do not include other source files here!!!
public section.

  interfaces ZIF_EFATT_FILEPROVIDER .
protected section.
*"* protected components of class ZCL_EFATT_FILE_FILEPROVIDER
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_EFATT_FILE_FILEPROVIDER
*"* do not include other source files here!!!

  types:
    efatt_ftp_line(255) TYPE c .
  types:
    efatt_ftp_line_tt TYPE STANDARD TABLE OF efatt_ftp_line .

  data M_WORK_DIR type STRING .
  data M_FTP_CONN_ID type I .
  data X_PATH type TEMFILE-DIRNAME .
  data M_WORK_DIR_BCK type STRING .
  data M_DELETE_FILE type ZEFATT_DEL_FILE .
ENDCLASS.



CLASS ZCL_EFATT_FILE_FILEPROVIDER IMPLEMENTATION.


  METHOD zif_efatt_fileprovider~close.

    DATA: lo_cx_sy_file_close TYPE REF TO cx_sy_file_close,
          physical_filename   TYPE char1024.

    CONCATENATE: x_path i_filename INTO physical_filename.

    TRY .

        CLOSE DATASET physical_filename.

      CATCH cx_sy_file_close INTO lo_cx_sy_file_close.

        return-type    = 'E'.
        return-message = lo_cx_sy_file_close->get_text( ).

    ENDTRY.

  ENDMETHOD.


  METHOD zif_efatt_fileprovider~delete_file.

    DATA: physical_filename_from  TYPE char1024,
          lo_cx_sy_file_authority TYPE REF TO cx_sy_file_authority,
          lo_cx_sy_file_open      TYPE REF TO cx_sy_file_open.

    CONCATENATE: x_path i_filename INTO physical_filename_from.

    TRY .

        DELETE DATASET physical_filename_from.

      CATCH cx_sy_file_authority  INTO lo_cx_sy_file_authority.

        return-type    = 'E'.
        return-message = lo_cx_sy_file_authority->get_text( ).

      CATCH cx_sy_file_open  INTO lo_cx_sy_file_open.

        return-type    = 'E'.
        return-message = lo_cx_sy_file_open->get_text( ).

    ENDTRY.


  ENDMETHOD.


  METHOD zif_efatt_fileprovider~get_file_listing.

    DATA: logical_filename TYPE filename-fileintern,
          file             TYPE zefatt_filedescriptor,
          iv_dir_name      TYPE zefatt_file_name_c255,
          et_dir_list      TYPE zefatt_fileinfo_t.

    FIELD-SYMBOLS:  <fs_et_dir_list> TYPE zefatt_fileinfo.

    logical_filename = m_work_dir.

    x_path = zcl_efatt_util=>file_get_name( logical_filename = logical_filename ).

    IF x_path IS INITIAL.

      return-id         = 'SG'.
      return-type       = 'E'.
      return-number     = '001'.
      return-message_v1 = logical_filename.
      return-message_v2 = sy-msgv2.
      return-message_v3 = sy-msgv3.
      return-message_v4 = sy-msgv4.

      RETURN.

    ENDIF.

    iv_dir_name = x_path.

    zcl_efatt_util=>get_files_from_file_system( EXPORTING iv_dir_name = iv_dir_name
                                                IMPORTING et_dir_list = et_dir_list
                                                          return      = return ).

    IF return-type = 'E' OR
       return-type = 'A'.

      RETURN.

    ENDIF.

    LOOP AT et_dir_list ASSIGNING <fs_et_dir_list>.

* non si tiene conto dei file che non sono XML
      FIND '.xml' IN <fs_et_dir_list>-name IGNORING CASE.

      IF sy-subrc = 0.

        file-filename = <fs_et_dir_list>-name.
        file-filedate = <fs_et_dir_list>-mod_date.

        APPEND file TO et_files.
        CLEAR file.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD zif_efatt_fileprovider~read_file.

    DATA: logical_filename             TYPE filename-fileintern,
          physical_filename            TYPE char1024,
          xml_string                   TYPE string,
          xml                          TYPE string,
          buffer                       TYPE xstring,
          lo_cx_sy_conversion_codepage TYPE REF TO cx_sy_conversion_codepage,
          lo_cx_sy_file_open_mode      TYPE REF TO cx_sy_file_open_mode,
          lo_cx_sy_pipe_reopen         TYPE REF TO cx_sy_pipe_reopen,
          lo_cx_sy_too_many_files      TYPE REF TO cx_sy_too_many_files,
          lo_cx_sy_file_access_error   TYPE REF TO cx_sy_file_access_error.

    CONCATENATE x_path i_filename INTO physical_filename.

    TRY.

* Leggo il file in formato testo
        OPEN DATASET physical_filename FOR INPUT IN TEXT MODE ENCODING DEFAULT IGNORING CONVERSION ERRORS.

        IF sy-subrc = 0.

          DO.

            READ DATASET physical_filename INTO xml_string.

            IF sy-subrc NE 0.
              EXIT.
            ENDIF.

            CONCATENATE xml xml_string INTO xml.

          ENDDO.

          CLOSE DATASET physical_filename.

* Effettuo le conversioni che mi serviranno per la normalizzazione del dato
* da XML a struttura ABAP...

*...converto prima in XSTRING
          CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
            EXPORTING
              text   = xml
            IMPORTING
              buffer = buffer
            EXCEPTIONS
              failed = 1
              OTHERS = 2.

          IF sy-subrc <> 0.
* Implement suitable error handling here
          ENDIF.

*...poi converto prima in formato BINARIO
          CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
            EXPORTING
              buffer        = buffer
            IMPORTING
              output_length = e_size
            TABLES
              binary_tab    = et_content.

        ELSE.

        ENDIF.

      CATCH cx_sy_file_access_error INTO lo_cx_sy_file_access_error.

        return-type    = 'E'.
        return-message = lo_cx_sy_file_access_error->get_text( ).

      CATCH cx_sy_conversion_codepage INTO lo_cx_sy_conversion_codepage.

        return-type    = 'E'.
        return-message = lo_cx_sy_conversion_codepage->get_text( ).

      CATCH cx_sy_pipe_reopen INTO lo_cx_sy_pipe_reopen.

        return-type    = 'E'.
        return-message = lo_cx_sy_pipe_reopen->get_text( ).

      CATCH cx_sy_too_many_files INTO lo_cx_sy_too_many_files.

        return-type    = 'E'.
        return-message = lo_cx_sy_too_many_files->get_text( ).

    ENDTRY.

ENDMETHOD.


  METHOD zif_efatt_fileprovider~set_work_directory.

    SELECT SINGLE pathintern backup delete_file FROM zefatt_conf_file INTO (m_work_dir, m_work_dir_bck, m_delete_file)
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


    DATA: logical_filename             TYPE filename-fileintern,
          physical_filename_from       TYPE char1024,
          physical_filename_to         TYPE char1024,
          xml_string                   TYPE string,
          xml                          TYPE string,
          buffer                       TYPE xstring,
          x_path_to                    TYPE temfile-dirname,
          lo_cx_sy_conversion_codepage TYPE REF TO cx_sy_conversion_codepage,
          lo_cx_sy_file_open_mode      TYPE REF TO cx_sy_file_open_mode,
          lo_cx_sy_pipe_reopen         TYPE REF TO cx_sy_pipe_reopen,
          lo_cx_sy_too_many_files      TYPE REF TO cx_sy_too_many_files,
          lo_cx_sy_file_access_error   TYPE REF TO cx_sy_file_access_error.


* Se configurata la cartella di backup trasferisco il file altrimenti l elimino
    IF m_work_dir_bck IS NOT INITIAL.

* Recupero il percorso fisico della cartella di backup
      logical_filename = m_work_dir_bck.
      x_path_to        = zcl_efatt_util=>file_get_name( logical_filename = logical_filename ).

      CONCATENATE: x_path    i_filename INTO physical_filename_from,
                   x_path_to i_filename INTO physical_filename_to.

      TRY.

* Apro il percorso sorgente per la lettura e lo leggo il file in formato testo
          OPEN DATASET physical_filename_from FOR INPUT IN TEXT MODE ENCODING DEFAULT IGNORING CONVERSION ERRORS.

          IF sy-subrc = 0.

* Apro il percorso sorgente per la scrittura in formato testo
            OPEN DATASET physical_filename_to FOR OUTPUT IN TEXT MODE ENCODING DEFAULT IGNORING CONVERSION ERRORS.

            DO.

* Leggo il contenuto
              READ DATASET physical_filename_from INTO xml_string.

              IF sy-subrc NE 0.
                EXIT.
              ENDIF.

* Trasferisco il contenuto
              TRANSFER xml_string TO physical_filename_to.

            ENDDO.

* Chiudo i percorsi dei file
            CLOSE DATASET: physical_filename_from,
                           physical_filename_to.

* Elimino il file dalla cartella sorgente se settato in customizing
            IF m_delete_file = 'X'.
              me->zif_efatt_fileprovider~delete_file( i_filename = i_filename ).
            ENDIF.

          ENDIF.

        CATCH cx_sy_file_access_error INTO lo_cx_sy_file_access_error.

          return-type    = 'E'.
          return-message = lo_cx_sy_file_access_error->get_text( ).

        CATCH cx_sy_conversion_codepage INTO lo_cx_sy_conversion_codepage.

          return-type    = 'E'.
          return-message = lo_cx_sy_conversion_codepage->get_text( ).

        CATCH cx_sy_pipe_reopen INTO lo_cx_sy_pipe_reopen.

          return-type    = 'E'.
          return-message = lo_cx_sy_pipe_reopen->get_text( ).

        CATCH cx_sy_too_many_files INTO lo_cx_sy_too_many_files.

          return-type    = 'E'.
          return-message = lo_cx_sy_too_many_files->get_text( ).

      ENDTRY.

    ELSE.


* Elimino il file dalla cartella sorgente se settato in customizing
      IF m_delete_file = 'X'.
        me->zif_efatt_fileprovider~delete_file( i_filename = i_filename ).
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD zif_efatt_fileprovider~write_file.

    DATA: physical_filename            TYPE string,
          lo_cx_sy_conversion_codepage TYPE REF TO cx_sy_conversion_codepage,
          lo_cx_sy_file_open_mode      TYPE REF TO cx_sy_file_open_mode,
          lo_cx_sy_pipe_reopen         TYPE REF TO cx_sy_pipe_reopen,
          lo_cx_sy_too_many_files      TYPE REF TO cx_sy_too_many_files,
          lo_cx_sy_file_access_error   TYPE REF TO cx_sy_file_access_error.

    FIELD-SYMBOLS: <content> TYPE sdokcntbin.

* Costruisco il path
    CONCATENATE: x_path i_filename INTO physical_filename.

    TRY.

* Apro il dataset in modalità scrittura in formato binario
        OPEN DATASET physical_filename FOR OUTPUT IN BINARY MODE.

* Trasferisco il contenuto
        LOOP AT it_content ASSIGNING <content>.
          TRANSFER <content> TO  physical_filename.
        ENDLOOP.

* Chiudo la sessione
        me->zif_efatt_fileprovider~close( EXPORTING i_filename = i_filename
                                          IMPORTING return     = return ).

      CATCH cx_sy_file_access_error INTO lo_cx_sy_file_access_error.

        return-type    = 'E'.
        return-message = lo_cx_sy_file_access_error->get_text( ).

      CATCH cx_sy_conversion_codepage INTO lo_cx_sy_conversion_codepage.

        return-type    = 'E'.
        return-message = lo_cx_sy_conversion_codepage->get_text( ).

      CATCH cx_sy_pipe_reopen INTO lo_cx_sy_pipe_reopen.

        return-type    = 'E'.
        return-message = lo_cx_sy_pipe_reopen->get_text( ).

      CATCH cx_sy_too_many_files INTO lo_cx_sy_too_many_files.

        return-type    = 'E'.
        return-message = lo_cx_sy_too_many_files->get_text( ).

    ENDTRY.


  ENDMETHOD.
ENDCLASS.
