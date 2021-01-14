class ZCL_EFATT_UTIL definition
  public
  final
  create public .

*"* public components of class ZCL_EFATT_UTIL
*"* do not include other source files here!!!
public section.
  type-pools ABAP .
  type-pools IXML .

  class-data GCL_PROCESS_MAP type ref to ZCL_EFATT_PROCESS_MAP .

  class-methods FILE_GET_NAME
    importing
      value(LOGICAL_FILENAME) type FILENAME-FILEINTERN
    returning
      value(FILE_PATH) type TEMFILE-DIRNAME .
  class-methods GET_FILES_FROM_FILE_SYSTEM
    importing
      !IV_DIR_NAME type ZEFATT_FILE_NAME_C255
    exporting
      !ET_DIR_LIST type ZEFATT_FILEINFO_T
      !RETURN type BAPIRET2 .
  class-methods GET_LIST_FROM_XML
    importing
      !IV_XML type ZEFATT_FILE
      !IV_LIST_TAG type STRING
    exporting
      !ET_LIST_XML type ANY .
  class-methods MANAGE_FILE
    importing
      !INTERFACCIA type ZEFATT_INTERFACCIA
      !I_TYPE type ZEFATT_INTERFACE_TIPO
      !BUKRS type BUKRS
    exporting
      !FILEPROVIDER type ref to ZIF_EFATT_FILEPROVIDER
      !RETURN type BAPIRET2 .
  class-methods TRANSFOM_XML_TO_STYLESHEET
    importing
      value(TRANSFORMATION) type CXSLTDESC
      value(XML) type ZEFATT_FILE
    exporting
      value(HTML_TABLE) type SOLI_TAB .
  class-methods TRANSFOM_ATTACHEMENT_TO_BYNARY
    importing
      value(BUFFER) type XSTRING
    exporting
      value(BINARY_TAB) type SWXMLCONT .
  class-methods DISPLAY_XML
    importing
      value(IV_XML_STRING) type XSTRING .
  class-methods HANDLE_DIGITAL_SIGNATURE
    importing
      value(INTERFACCIA) type ZEFATT_INTERFACCIA
      value(REGOLA) type ZEFATT_MAP_RULE
    exporting
      value(MESSAGE) type BAPIRET2-MESSAGE
    changing
      value(XML) type XSTRING
      value(ET_XML_DATA) type ZSMUM_XMLTB_T .
  class-methods GET_VALUE_FROM_XML
    importing
      value(IV_XML) type ZEFATT_FILE
      value(IV_VALUE_NAME) type STRING
      value(IV_ATTRIBUTE_NAME) type STRING optional
    exporting
      value(MESSAGE) type BAPIRET2-MESSAGE
      value(RV_VALUE) type STRING .
  class-methods DECODE_BASE64_XSTRING
    importing
      value(IV_ENCODED_XSTRING) type XSTRING
    exporting
      value(RV_DECODED_XSTRING) type XSTRING
      value(MESSAGE) type BAPIRET2-MESSAGE .
  class-methods ADD_GOS_ATTACHMENT
    importing
      value(I_OBJECTTYPE) type SWO_OBJTYP
      value(I_OBJECTKEY) type BORIDENT-OBJKEY
      value(I_CONTENT) type XSTRING
      value(I_DESCR) type SOOD1-OBJDES
      value(I_OBJECT_TYPE) type SOODK-OBJTP
      value(I_RELTYPE) type BRELTYP-RELTYPE
      value(I_FILE_EXT) type SOOD1-FILE_EXT optional .
  class-methods START_WORKFLOW
    importing
      value(IM_OBJCATEG) type SWF_CLSTYP
      value(IM_OBJTYPE) type C
      value(IM_EVENT) type C
      value(IM_OBJKEY) type C
      value(EVENT_PARAM_T) type SRM_RECORD_EVENT_PARAM_T optional .
  class-methods DELETE_STYLE_SHEET
    changing
      !XML type XSTRING .
  class-methods ADD_GOS_XML_STYLESHEET
    importing
      !TRANSFORMATION type CXSLTDESC
      !XML type ZEFATT_FILE
      !I_OBJECTTYPE type SWO_OBJTYP
      !I_OBJECTKEY type BORIDENT-OBJKEY
      !I_CONTENT type XSTRING
      !I_DESCR type SOOD1-OBJDES
      !I_OBJECT_TYPE type SOODK-OBJTP
      !I_RELTYPE type BRELTYP-RELTYPE
      !I_FILE_EXT type SOOD1-FILE_EXT .
  class-methods CREATE_SHORTCUT
    importing
      value(RECIPIENT_USER_ID) type SYUNAME
      value(REPORT) type PROGRAMM
      value(SHORTCUT_PARAM) type ZEFATT_SHORTCUT_PAR_T optional
    exporting
      value(CONTENT) type STRING .
  class-methods SEND_MAIL
    importing
      value(OBJ_DESCR) type SO_OBJ_DES
      value(CONTENTS_TXT) type RSPC_T_TEXT
      value(CONTENTS_BIN) type RSPC_T_TEXT
      value(RECEIVERS) type SOMLRECI1_T
      value(DOC_TYPE) type SO_OBJ_TP
      value(OBJ_NAME) type SO_OBJ_NAM
      value(OBJ_DESCR_ATT) type SO_OBJ_DES .
  class-methods SEND_MAIL_WITH_SHORTCUT
    importing
      value(RECIPIENT_USER_ID) type SYUNAME
      value(REPORT) type PROGRAMM
      value(NAME) type THEAD-TDNAME
      value(OBJ_DESCR) type SO_OBJ_DES .
  class-methods P6_TO_DATE_TIME_TZ
    importing
      value(MTIME) type FILEMODSEC
    exporting
      value(MOD_DATE) type FILEMODDAT
      value(MOD_TIME) type FILEMODTIM .
  class-methods MANAGE_WS
    importing
      !INTERFACCIA type ZEFATT_INTERFACCIA
      !I_TYPE type ZEFATT_INTERFACE_TIPO
    exporting
      !RP_WSPROVIDER type ref to ZIF_FATT_API
      !RETURN type BAPIRET2 .
protected section.
*"* protected components of class ZCL_EFATT_UTIL
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_EFATT_UTIL
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_EFATT_UTIL IMPLEMENTATION.


  METHOD add_gos_attachment.

    DATA: folder_id        TYPE soodk,
          object_id        TYPE soodk,
          objhead          TYPE STANDARD TABLE OF soli,
          owner            TYPE soud-usrnam,
          object_hd_change TYPE sood1,
          obj_rolea        TYPE borident,
          obj_roleb        TYPE borident,
          binary_tab       TYPE solix_tab,
          objcont          TYPE soli_tab.

* Recupero folder id.
    owner = sy-uname.
    CALL FUNCTION 'SO_FOLDER_ROOT_ID_GET'
      EXPORTING
        owner                 = owner
        region                = 'B'
      IMPORTING
        folder_id             = folder_id
      EXCEPTIONS
        communication_failure = 1
        owner_not_exist       = 2
        system_failure        = 3
        x_error               = 4.

* Inserisco oggetto
    object_hd_change-objsns   = 'O'.
    object_hd_change-objla    = sy-langu.
    object_hd_change-objdes   = i_descr.
    object_hd_change-file_ext = i_file_ext.

* Conversione da stringa esadecimanle a binario del contenuto del file
    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer     = i_content
      TABLES
        binary_tab = binary_tab.

* Conversione da tabella binaria a tabella di testo
    CALL FUNCTION 'SO_SOLIXTAB_TO_SOLITAB'
      EXPORTING
        ip_solixtab = binary_tab
      IMPORTING
        ep_solitab  = objcont.

* Creazione oggetto
    CALL FUNCTION 'SO_OBJECT_INSERT'
      EXPORTING
        folder_id                  = folder_id
        object_type                = i_object_type
        object_hd_change           = object_hd_change
      IMPORTING
        object_id                  = object_id
      TABLES
        objcont                    = objcont
        objhead                    = objhead
      EXCEPTIONS
        active_user_not_exist      = 1
        communication_failure      = 2
        component_not_available    = 3
        dl_name_exist              = 4
        folder_not_exist           = 5
        folder_no_authorization    = 6
        object_type_not_exist      = 7
        operation_no_authorization = 8
        owner_not_exist            = 9
        parameter_error            = 10
        substitute_not_active      = 11
        substitute_not_defined     = 12
        system_failure             = 13
        x_error                    = 14.

* Creo relazione binaria con l'oggetto
    obj_rolea-objkey  = i_objectkey.
    obj_rolea-objtype = i_objecttype.

    CONCATENATE folder_id-objtp
                folder_id-objyr
                folder_id-objno
                object_id-objtp
                object_id-objyr
                object_id-objno
                INTO obj_roleb-objkey.

    obj_roleb-objtype = 'MESSAGE'.

    CALL FUNCTION 'BINARY_RELATION_CREATE'
      EXPORTING
        obj_rolea      = obj_rolea
        obj_roleb      = obj_roleb
        relationtype   = i_reltype
      EXCEPTIONS
        no_model       = 1
        internal_error = 2
        unknown        = 3.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

  ENDMETHOD.


METHOD add_gos_xml_stylesheet.

  DATA: html_table   TYPE soli_tab,
        ep_solixtab  TYPE solix_tab,
        input_length TYPE i,
        buffer       TYPE xstring.

  FIELD-SYMBOLS: <fs_solixtab> TYPE solix.

* Renderizzo XML con il foglio di stile
  zcl_efatt_util=>transfom_xml_to_stylesheet( EXPORTING transformation = transformation
                                                        xml            = xml
                                              IMPORTING html_table     = html_table ).

* Converto tabella di testo in tabella binaria
  CALL FUNCTION 'SO_SOLITAB_TO_SOLIXTAB'
    EXPORTING
      ip_solitab  = html_table
    IMPORTING
      ep_solixtab = ep_solixtab.

* Calcolo la grandezza della tabella
  LOOP AT ep_solixtab ASSIGNING <fs_solixtab>.
    input_length = input_length + XSTRLEN( <fs_solixtab>-line ).
  ENDLOOP.

* Converto tabella binaria in stringa esadecimale
  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      input_length = input_length
    IMPORTING
      buffer       = buffer
    TABLES
      binary_tab   = ep_solixtab
    EXCEPTIONS
      failed       = 1
      OTHERS       = 2.

* Creazione dell'ogetto GOS
  SET UPDATE TASK LOCAL.
  zcl_efatt_util=>add_gos_attachment( i_objecttype  = i_objecttype
                                      i_objectkey   = i_objectkey
                                      i_content     = buffer
                                      i_descr       = i_descr
                                      i_object_type = i_object_type
                                      i_reltype     = i_reltype
                                      i_file_ext    = i_file_ext ).

ENDMETHOD.


METHOD create_shortcut.

  DATA :  parameter TYPE text255.

  FIELD-SYMBOLS: <fs_shortcut_par> TYPE zefatt_shortcut_par.

* Popoloare i parametri da passare alla ShortCut
  IF NOT shortcut_param[] IS INITIAL.

    CLEAR parameter.

    LOOP AT shortcut_param ASSIGNING <fs_shortcut_par>.

      CONCATENATE parameter
                  <fs_shortcut_par>-fieldname '='
                  <fs_shortcut_par>-fieldvalue ';'
                  INTO parameter.
    ENDLOOP.

  ENDIF.

* Creazione dello shortcut per la transazione richiesta
  CALL FUNCTION 'SWN_CREATE_SHORTCUT'
    EXPORTING
      i_report                = report
      i_parameter             = parameter
      i_sysid                 = sy-sysid
      i_client                = sy-mandt
      i_user                  = recipient_user_id
      i_language              = sy-langu
      i_windowsize            = 'Maximized'
    IMPORTING
      shortcut_string         = content
    EXCEPTIONS
      inconsistent_parameters = 1
      OTHERS                  = 2.

  IF sy-subrc <> 0.

* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

  ENDIF.

ENDMETHOD.


METHOD decode_base64_xstring.

  TYPES: ty_raw(1024) TYPE x.

  DATA: lv_string    TYPE string,
        lv_length1   TYPE i,
        lv_length2   TYPE i,
        lt_binary    TYPE TABLE OF ty_raw,
        lv_error_txt TYPE string.

  CLEAR rv_decoded_xstring.

* Conversione xstring a binario
  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer        = iv_encoded_xstring
    IMPORTING
      output_length = lv_length1
    TABLES
      binary_tab    = lt_binary.

* Conversione binario a string
  CALL FUNCTION 'SCMS_BINARY_TO_STRING'
    EXPORTING
      input_length  = lv_length1
    IMPORTING
      text_buffer   = lv_string
      output_length = lv_length2
    TABLES
      binary_tab    = lt_binary
    EXCEPTIONS
      failed        = 1
      OTHERS        = 2.

  IF sy-subrc <> 0.

    MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
             INTO message.

    RETURN.

  ENDIF.

* Decodifica string
  CALL FUNCTION 'SSFC_BASE64_DECODE'
    EXPORTING
      b64data                  = lv_string
    IMPORTING
      bindata                  = rv_decoded_xstring
    EXCEPTIONS
      ssf_krn_error            = 1
      ssf_krn_noop             = 2
      ssf_krn_nomemory         = 3
      ssf_krn_opinv            = 4
      ssf_krn_input_data_error = 5
      ssf_krn_invalid_par      = 6
      ssf_krn_invalid_parlen   = 7
      OTHERS                   = 8.

  IF sy-subrc <> 0.

    MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
             INTO message.

    RETURN.

  ENDIF.

ENDMETHOD.


METHOD delete_style_sheet.

  TYPES: BEGIN OF ty_data_tab,
             line(64) TYPE x,
           END OF ty_data_tab.

  DATA: binary_tab     TYPE STANDARD TABLE OF ty_data_tab,
        text_buffer    TYPE string,
        output_length  TYPE i,
        output_length2 TYPE i,
        lines          TYPE i.

* Converto la stringa esadecimale in binario
  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer        = xml
    IMPORTING
      output_length = output_length
    TABLES
      binary_tab    = binary_tab.

* Converto il contenuto binario in stringa
  CALL FUNCTION 'SCMS_BINARY_TO_STRING'
    EXPORTING
      input_length  = output_length
    IMPORTING
      text_buffer   = text_buffer
      output_length = output_length2
    TABLES
      binary_tab    = binary_tab
    EXCEPTIONS
      failed        = 1
      OTHERS        = 2.

  IF sy-subrc <> 0.

* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


  DATA:  lv_stylesheet(200),
         lv_offset_beg      TYPE int4,
         lv_offset_end      TYPE int4.

  CLEAR: lv_stylesheet,
         lv_offset_beg,
         lv_offset_end.

  IF text_buffer CS '<?xml-stylesheet'.

    lv_offset_beg = sy-fdpos.

    IF text_buffer+lv_offset_beg CS '?>'.

      lv_offset_end = sy-fdpos + 2.
*      MOVE text_buffer+lv_offset_beg(lv_offset_end) TO lv_stylesheet.
      REPLACE FIRST OCCURRENCE OF text_buffer+lv_offset_beg(lv_offset_end) IN text_buffer WITH ''.

    ENDIF.

  ENDIF.

* Conversione da stringa a stringa esadecimale
  CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
    EXPORTING
      text   = text_buffer
    IMPORTING
      buffer = xml
    EXCEPTIONS
      failed = 1
      OTHERS = 2.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDMETHOD.


  METHOD display_xml.

    CALL FUNCTION 'ZEFATT_DISPLAY_XML' STARTING NEW TASK 'XML'
      DESTINATION 'NONE'
      EXPORTING
        iv_xml_string = iv_xml_string.

  ENDMETHOD.


  METHOD file_get_name.

    CALL FUNCTION 'FILE_GET_NAME'
      EXPORTING
        logical_filename = logical_filename
        eleminate_blanks = ' '
        including_dir    = 'X'
      IMPORTING
        file_name        = file_path
      EXCEPTIONS
        file_not_found   = 1
        OTHERS           = 2.

    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.


  ENDMETHOD.


  METHOD get_files_from_file_system.

    DATA: lv_file          TYPE zefatt_fileinfo,
          lv_file_mask     TYPE zefatt_file_name_c255,
          lv_name          TYPE char255,
          lv_error_counter TYPE i,
          ls_dir_list      LIKE LINE OF et_dir_list,
          tstmp            TYPE timestamp,
          subrc            TYPE sy-subrc,
          mtime(6)         TYPE p.

    AUTHORITY-CHECK OBJECT 'S_RZL_ADM'
                    ID 'ACTVT'
                    FIELD '03'.

    IF sy-subrc NE 0.

      return-id         = sy-msgid.
      return-type       = sy-msgty.
      return-number     = sy-msgno.
      return-message_v1 = sy-msgv1.
      return-message_v2 = sy-msgv2.
      return-message_v3 = sy-msgv3.
      return-message_v4 = sy-msgv4.

      RETURN.

    ENDIF.

*   Get directory listing
    CALL 'C_DIR_READ_FINISH'
          ID 'ERRNO'  FIELD lv_file-errno
          ID 'ERRMSG' FIELD lv_file-errmsg.

    CALL 'C_DIR_READ_START'
          ID 'DIR'    FIELD iv_dir_name
          ID 'FILE'   FIELD lv_file_mask
          ID 'ERRNO'  FIELD lv_file-errno
          ID 'ERRMSG' FIELD lv_file-errmsg.

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

    CLEAR et_dir_list.

    DO.

      CLEAR: lv_file,
             ls_dir_list.

      CALL 'C_DIR_READ_NEXT'
            ID 'TYPE'     FIELD lv_file-type
            ID 'NAME'     FIELD lv_file-name
            ID 'LEN'      FIELD lv_file-len
            ID 'OWNER'    FIELD lv_file-owner
            ID 'MTIME'    FIELD lv_file-mtime
            ID 'MODE'     FIELD lv_file-umode
            ID 'ERRNO'    FIELD lv_file-errno
            ID 'ERRMSG'   FIELD lv_file-errmsg.

      subrc = sy-subrc.

      IF lv_file-len > 2147483647.
        ls_dir_list-len  = -99.
      ELSE.
        ls_dir_list-len  = lv_file-len.
      ENDIF.

      CALL METHOD zcl_efatt_util=>p6_to_date_time_tz
        EXPORTING
          mtime    = lv_file-mtime
        IMPORTING
          mod_date = ls_dir_list-mod_date
          mod_time = ls_dir_list-mod_time.

      ls_dir_list-name     = lv_file-name.

      IF subrc = 0.

        IF lv_file-type(1) = 'f' OR
           lv_file-type(1) = 'F'.

          ls_dir_list-subrc   = 0.
          APPEND ls_dir_list TO et_dir_list.

        ENDIF.

      ELSEIF subrc = 1.

        EXIT.

      ELSE.

        IF lv_error_counter > 1000.

          CALL 'C_DIR_READ_FINISH'
                ID 'ERRNO'  FIELD lv_file-errno
                ID 'ERRMSG' FIELD lv_file-errmsg.

          RETURN.

        ENDIF.

        ADD 1 TO lv_error_counter.
        ls_dir_list-subrc  = 18.

        APPEND ls_dir_list TO et_dir_list.

      ENDIF.

    ENDDO.

    CALL 'C_DIR_READ_FINISH'
          ID 'ERRNO'  FIELD lv_file-errno
          ID 'ERRMSG' FIELD lv_file-errmsg.


    SORT et_dir_list BY name ASCENDING.

  ENDMETHOD.


  METHOD get_list_from_xml.                                 "New with 2765690

    DATA lt_xml_data TYPE TABLE OF smum_xmltb.
    DATA ls_xml_data TYPE smum_xmltb.
    DATA lv_index_tag TYPE sy-tabix.
    DATA lv_index_data TYPE sy-tabix.
    DATA lv_tag_name TYPE string.
    DATA lv_tag_flag TYPE c.
    DATA lt_xml_tag TYPE TABLE OF string.
    DATA lt_return TYPE TABLE OF bapiret2.

    FIELD-SYMBOLS <lt_list_xml> LIKE lt_xml_data.
    ASSIGN et_list_xml TO <lt_list_xml>.

*   Extract xml value into internal table
    CALL FUNCTION 'SMUM_XML_PARSE'
      EXPORTING
        xml_input = iv_xml
      TABLES
        xml_table = lt_xml_data
        return    = lt_return.

    IF lines( lt_xml_data ) < 2.
      MESSAGE e802(zefattura) INTO zcl_efatt=>error_txt.
      zcl_efatt=>raise_edoc_exception( ).
    ENDIF.

*   Prepare search tag path split path into tag table
    SPLIT iv_list_tag AT '/' INTO TABLE lt_xml_tag.

    lv_index_tag = 1.
    READ TABLE lt_xml_tag INDEX lv_index_tag INTO lv_tag_name.
    IF sy-subrc <> 0.
      MESSAGE e079(zefattura)
        WITH 'ZCL_EFATT' 'GET_LIST_FROM_XML' 'IV_LIST_TAG'
        INTO zcl_efatt=>error_txt.
      zcl_efatt=>raise_edoc_exception( ).
    ENDIF.

    TRANSLATE lv_tag_name TO UPPER CASE.
    IF lv_tag_name <> 'XML'.
      INSERT 'XML' INTO lt_xml_tag INDEX 1.
    ENDIF.


*   Extract required part of the table
    CLEAR et_list_xml.
    lv_index_tag = 2.
    lv_tag_flag = 'N'.
    lv_index_data = 0.


    DO.
      lv_index_data = lv_index_data + 1.
      IF lv_index_data > lines( lt_xml_data ).
        EXIT.
      ENDIF.

      READ TABLE lt_xml_data INDEX lv_index_data INTO ls_xml_data.
      IF sy-subrc <> 0.
        MESSAGE e802(zefattura) INTO zcl_efatt=>error_txt.
        zcl_efatt=>raise_edoc_exception( ).
      ENDIF.

      TRANSLATE ls_xml_data-cname TO UPPER CASE.
      TRANSLATE lv_tag_name TO UPPER CASE.

*     If any node in the given path is reached,
*     then read the line of xml table(if deepest node in the given path is reached),
*     or search next node in the given path
      IF ls_xml_data-cname = lv_tag_name
        AND ls_xml_data-hier = lv_index_tag.

        IF lv_index_tag = lines( lt_xml_tag ).
*         Deepest node is reached, set flag to true, start reading values from xml table.
          lv_tag_flag = 'Y'.
          APPEND ls_xml_data TO <lt_list_xml>.

        ELSEIF lv_index_tag < lines( lt_xml_tag ).
*         Deepest node is not yet reached, go deeper in the given path
          lv_index_tag = lv_index_tag + 1.
          READ TABLE lt_xml_tag INDEX lv_index_tag INTO lv_tag_name.
          IF sy-subrc <> 0.
            MESSAGE e802(zefattura) INTO zcl_efatt=>error_txt.
            zcl_efatt=>raise_edoc_exception( ).
          ENDIF.
          TRANSLATE lv_tag_name TO UPPER CASE.

        ENDIF.

*     If deepest node in the given path is reached, also take the values of subtags
      ELSEIF ls_xml_data-cname <> lv_tag_name
        AND ls_xml_data-hier > lv_index_tag
        AND lv_index_tag = lines( lt_xml_tag )
        AND lv_tag_flag = 'Y'.

        APPEND ls_xml_data TO <lt_list_xml>.

*     Deepest node is reached, other same level tags should not be read.
      ELSEIF ls_xml_data-cname <> lv_tag_name
        AND ls_xml_data-hier = lv_index_tag.

        lv_tag_flag = 'N'.

*     If current node cannot be reached inside this level of data, go back to upper level of data and continue
      ELSEIF ls_xml_data-cname <> lv_tag_name
        AND ls_xml_data-hier < lv_index_tag
        AND lv_index_tag > 2.

        lv_index_tag = lv_index_tag - 1.
        READ TABLE lt_xml_tag INDEX lv_index_tag INTO lv_tag_name.
        IF sy-subrc <> 0.
          MESSAGE e802(zefattura) INTO zcl_efatt=>error_txt.
          zcl_efatt=>raise_edoc_exception( ).
        ENDIF.
        TRANSLATE lv_tag_name TO UPPER CASE.
        IF ls_xml_data-cname = lv_tag_name.
          lv_index_data = lv_index_data - 1.
        ENDIF.

      ENDIF.

    ENDDO.


  ENDMETHOD.


METHOD get_value_from_xml.

  DATA: lo_xml       TYPE REF TO cl_xml_document,
        lo_error     TYPE REF TO if_ixml_parse_error,
        lo_node      TYPE REF TO if_ixml_node,
        lv_error_txt TYPE string,
        lv_xml_error TYPE string.

  CLEAR rv_value.

  CREATE OBJECT lo_xml.

  IF lo_xml IS BOUND.

    lo_xml->parse_xstring( EXPORTING stream = iv_xml ).
    lo_error = lo_xml->get_last_parse_error( ).

    IF lo_error IS BOUND.
      lv_xml_error = lo_error->get_reason( ).
    ENDIF.

    IF lv_xml_error IS INITIAL.

      lo_xml->find_node( EXPORTING name = iv_value_name
                         RECEIVING node = lo_node ).

      IF lo_node IS BOUND.

        IF iv_attribute_name IS INITIAL.
          rv_value = lo_node->get_value( ).
        ELSE.
          rv_value = lo_xml->get_node_attribute( node = lo_node
                                                 name = iv_attribute_name ).
        ENDIF.

      ELSE.

        MESSAGE e803(zefattura) WITH iv_value_name INTO message.

      ENDIF.

    ELSE.

      MESSAGE e802(zefattura) INTO message.

    ENDIF.

  ELSE.

    MESSAGE e802(zefattura) INTO message.


  ENDIF.

ENDMETHOD.                    "get_value_from_xml


METHOD handle_digital_signature.

  TYPES: BEGIN OF ty_data_tab,
           line(64) TYPE x,
         END OF ty_data_tab.

  DATA: lt_dig_sign    TYPE STANDARD TABLE OF zefatt_dig_sign,
        lt_return      TYPE STANDARD TABLE OF bapiret2,
        binary_tab     TYPE STANDARD TABLE OF ty_data_tab,
        text_buffer    TYPE string,
        text_string    TYPE string,
        output_length  TYPE i,
        output_length2 TYPE i,
        lines          TYPE i.

  FIELD-SYMBOLS: <fs_dig_sign>  TYPE zefatt_dig_sign,
                 <fs_return>    TYPE bapiret2.

  REFRESH et_xml_data.

* Recupero per la regola di mapping quali sono i possibili
* tag di inizio e fine dell'xml al fi fuori dei quali devo
* eliminare la firma digitale
  SELECT * FROM zefatt_dig_sign INTO TABLE lt_dig_sign
         WHERE interfaccia  = regola-interfaccia
         AND   regola_map   = regola-regola_map.

  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

* Converto la stringa esadecimale in binario
  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer        = xml
    IMPORTING
      output_length = output_length
    TABLES
      binary_tab    = binary_tab.

* Converto il contenuto binario in stringa
  CALL FUNCTION 'SCMS_BINARY_TO_STRING'
    EXPORTING
      input_length  = output_length
    IMPORTING
      text_buffer   = text_buffer
      output_length = output_length2
    TABLES
      binary_tab    = binary_tab
    EXCEPTIONS
      failed        = 1
      OTHERS        = 2.

  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


  LOOP AT lt_dig_sign ASSIGNING <fs_dig_sign>.

    CLEAR text_string.
    text_string = text_buffer.

    IF text_string CS <fs_dig_sign>-map_begin.

      REPLACE ALL OCCURRENCES OF text_string(sy-fdpos) IN text_string WITH ''.

      IF text_buffer CS <fs_dig_sign>-map_end.

        output_length = sy-fdpos + STRLEN( <fs_dig_sign>-map_end ).

        REPLACE ALL OCCURRENCES OF text_string+output_length IN text_string WITH ''.

      ENDIF.

    ENDIF.

* Conversione da stringa a stringa esadecimale
    CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
      EXPORTING
        text   = text_string
      IMPORTING
        buffer = xml
      EXCEPTIONS
        failed = 1
        OTHERS = 2.

    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    REFRESH: et_xml_data,
             lt_return.

* Estrazione XML in tabella interna
    CALL FUNCTION 'SMUM_XML_PARSE'
      EXPORTING
        xml_input = xml
      TABLES
        xml_table = et_xml_data
        return    = lt_return.

    DESCRIBE TABLE et_xml_data LINES lines.

    IF lines > 2.
      EXIT.
    ENDIF.

  ENDLOOP.

  DESCRIBE TABLE et_xml_data LINES lines.

  IF lines < 2.

    DESCRIBE TABLE lt_return LINES lines.
    READ TABLE lt_return ASSIGNING <fs_return> INDEX lines.
    message = <fs_return>-message.

  ENDIF.

ENDMETHOD.


  METHOD manage_file.

* Instazio l'oggeto che costituisce il mio provider di file ( FTP server, Application Server)
    zcl_efatt_fileprovider_factory=>get_fileprovider( EXPORTING bukrs           = bukrs
                                                                interfaccia     = interfaccia
                                                                i_type          = i_type
                                                      IMPORTING rp_fileprovider = fileprovider
                                                                return          = return ).

  ENDMETHOD.


  METHOD manage_ws.

    zcl_fatt_wsprovider_factory=>get_wsprovider( EXPORTING interfaccia   = interfaccia
                                                           i_type        = i_type
                                                 IMPORTING rp_wsprovider = rp_wsprovider
                                                           return        = return ).

  ENDMETHOD.


METHOD p6_to_date_time_tz.


  DATA: opcode     TYPE x,
        timestamp  TYPE i,
        date       TYPE d,
        time       TYPE t,
        tz         TYPE sy-zonlo,
        abaptstamp TYPE timestamp,
        timestring(10),
        abapstamp(14),
        unique,
        not_found.

  timestamp = mtime.

  IF sy-zonlo = space.

    CALL FUNCTION 'TZON_GET_OS_TIMEZONE'
      IMPORTING
        ef_timezone   = tz
        ef_not_unique = unique
        ef_not_found  = not_found.

    IF unique = 'X' OR
       not_found = 'X'.
      .
      tz = sy-tzone.

      CONCATENATE 'UTC+' tz INTO tz.

    ENDIF.

  ELSE.

    tz = sy-zonlo.

  ENDIF.

  opcode = 3.
  CALL 'RstrDateConv'
    ID 'OPCODE' FIELD opcode
    ID 'TIMESTAMP' FIELD timestamp
    ID 'ABAPSTAMP' FIELD abapstamp.

  abaptstamp = abapstamp.

  CONVERT TIME STAMP abaptstamp TIME ZONE tz INTO DATE mod_date TIME mod_time.

ENDMETHOD.


METHOD send_mail.

  DATA: document_data   TYPE sodocchgi1,
        packing_list    TYPE STANDARD TABLE OF sopcklsti1,
        ls_packing_list TYPE sopcklsti1,
        tab_lines       TYPE sy-tabix.

* Oggetto della mail
  document_data-obj_descr = obj_descr.

* Corpo della mail
  DESCRIBE TABLE contents_txt LINES tab_lines.

  ls_packing_list-head_start = 1.
  ls_packing_list-head_num = 0.
  ls_packing_list-body_start = 1.
  ls_packing_list-body_num = tab_lines.
  ls_packing_list-doc_type = 'RAW'.

  APPEND ls_packing_list TO packing_list.
  CLEAR ls_packing_list.

* Allegato della mail
  CLEAR tab_lines.
  DESCRIBE TABLE contents_bin LINES tab_lines.

  ls_packing_list-transf_bin = 'X'.
  ls_packing_list-head_start = 1.
  ls_packing_list-head_num   = 1.
  ls_packing_list-body_start = 1.
  ls_packing_list-body_num   = tab_lines.
  ls_packing_list-doc_type   = doc_type.
  ls_packing_list-obj_name   = obj_name.
  ls_packing_list-obj_descr  = obj_descr.
  ls_packing_list-doc_size   = tab_lines * 255.

  APPEND ls_packing_list TO packing_list.
  CLEAR ls_packing_list.

  CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
    EXPORTING
      document_data              = document_data
      put_in_outbox              = 'X'
      commit_work                = 'X'
    TABLES
      packing_list               = packing_list
      contents_bin               = contents_bin
      contents_txt               = contents_txt
      receivers                  = receivers
    EXCEPTIONS
      too_many_receivers         = 1
      document_not_sent          = 2
      document_type_not_exist    = 3
      operation_no_authorization = 4
      parameter_error            = 5
      x_error                    = 6
      enqueue_error              = 7
      OTHERS                     = 8.

  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDMETHOD.


METHOD send_mail_with_shortcut.

  DATA: content         TYPE string,
        obj_name        TYPE so_obj_nam,
        obj_descr_att   TYPE so_obj_des,
        obj_descr_mail  TYPE so_obj_des,
        receivers       TYPE somlreci1_t,
        ls_receivers    TYPE somlreci1,
        contents_txt    TYPE rspc_t_text,
        contents_bin    TYPE rspc_t_text,
        ls_contents_bin TYPE solisti1,
        lt_lines        TYPE STANDARD TABLE OF tline,
        header          TYPE thead,
        main_text       TYPE bcsy_text,
        stream_lines    TYPE string_table,
        persnumber      TYPE usr21-persnumber,
        addrnumber      TYPE usr21-addrnumber.

* Creazione ShortCut
  zcl_efatt_util=>create_shortcut( EXPORTING recipient_user_id = recipient_user_id
                                             report            = report
                                   IMPORTING content           = content ).

* Mi richiamo il testo standard per il corpo della mail
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = 'ST'
      language                = 'I'
      name                    = name
      object                  = 'TEXT'
    IMPORTING
      header                  = header
    TABLES
      lines                   = lt_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.

* Converto in testo di tipo stream adatto per il corpo della mail
  CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
    EXPORTING
      language     = sy-langu
      lf           = space
    IMPORTING
      stream_lines = stream_lines
    TABLES
      itf_text     = lt_lines
      text_stream  = contents_txt.

  CONCATENATE text-002 ' '
              sy-datum+6(2) '.' sy-datum+4(2) '.' sy-datum(4) ' '
              sy-uzeit(2) ':' sy-uzeit+2(2) ':' sy-uzeit+4(2) INTO obj_descr_mail.

  obj_descr_att = obj_descr.
  obj_name      = 'EFATTSHORTCUT'.

* Allegato shotcut
  CONCATENATE content ls_contents_bin-line INTO ls_contents_bin-line.
  APPEND ls_contents_bin TO contents_bin.

* Destinatari Mail
  SELECT SINGLE persnumber addrnumber FROM usr21 INTO (persnumber, addrnumber)
         WHERE bname = recipient_user_id.

  SELECT SINGLE smtp_addr FROM adr6 INTO ls_receivers-receiver
         WHERE addrnumber = addrnumber
         AND   persnumber = persnumber.

  ls_receivers-rec_type = 'U'.
  APPEND ls_receivers TO receivers.

* Invio Mail
  zcl_efatt_util=>send_mail( obj_descr     = obj_descr_mail
                             contents_txt  = contents_txt
                             contents_bin  = contents_bin
                             receivers     = receivers
                             doc_type      = 'EXT'
                             obj_name      = obj_name
                             obj_descr_att = obj_descr_att ).

ENDMETHOD.


METHOD start_workflow.

  DATA: event_container	TYPE REF TO	if_swf_ifs_parameter_container.

  FIELD-SYMBOLS: <fs_event_parameter> TYPE srm_record_event_param.

* Instanziare un contenitore di evento vuoto
  CALL METHOD cl_swf_evt_event=>get_event_container
    EXPORTING
      im_objcateg  = im_objcateg
      im_objtype   = im_objtype
      im_event     = im_event
    RECEIVING
      re_reference = event_container.

* Settare i parametri dell'evento
  TRY.

      LOOP AT event_param_t ASSIGNING <fs_event_parameter>.

        CALL METHOD event_container->set
          EXPORTING
            name  = <fs_event_parameter>-name
            value = <fs_event_parameter>-value.

      ENDLOOP.

    CATCH cx_swf_cnt_cont_access_denied .
    CATCH cx_swf_cnt_elem_access_denied .
    CATCH cx_swf_cnt_elem_not_found .
    CATCH cx_swf_cnt_elem_type_conflict .
    CATCH cx_swf_cnt_unit_type_conflict .
    CATCH cx_swf_cnt_elem_def_invalid .
    CATCH cx_swf_cnt_container .

  ENDTRY.

* Raise dell'evento in cui passiamo anche il contenitore istanziato
  TRY.
      CALL METHOD cl_swf_evt_event=>raise
        EXPORTING
          im_objcateg        = im_objcateg
          im_objtype         = im_objtype
          im_event           = im_event
          im_objkey          = im_objkey
          im_event_container = event_container.

    CATCH cx_swf_evt_invalid_objtype .
    CATCH cx_swf_evt_invalid_event .

  ENDTRY.

  COMMIT WORK AND WAIT.

ENDMETHOD.


  METHOD transfom_attachement_to_bynary.

    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer     = buffer
      TABLES
        binary_tab = binary_tab.

  ENDMETHOD.


  METHOD transfom_xml_to_stylesheet.

    DATA: lv_xml_out        TYPE string,
          string_components TYPE STANDARD TABLE OF swastrtab,
          ls_html           TYPE soli.

    FIELD-SYMBOLS: <fs_components> TYPE swastrtab.

    TRY.
        CALL TRANSFORMATION (transformation)
          SOURCE XML xml
          RESULT XML lv_xml_out.

      CATCH cx_transformation_error.
        RETURN.
    ENDTRY.

    CALL FUNCTION 'SWA_STRING_SPLIT'
      EXPORTING
        input_string                 = lv_xml_out
        max_component_length         = 255
      TABLES
        string_components            = string_components
      EXCEPTIONS
        max_component_length_invalid = 1
        OTHERS                       = 2.

    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    LOOP AT string_components ASSIGNING <fs_components>.

      ls_html-line = <fs_components>-str.

      APPEND ls_html TO html_table.
      CLEAR: ls_html.

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
