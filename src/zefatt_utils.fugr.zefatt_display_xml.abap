FUNCTION ZEFATT_DISPLAY_XML.
*"--------------------------------------------------------------------
*"*"Interfaccia locale:
*"  IMPORTING
*"     VALUE(IV_XML_STRING) TYPE  XSTRING
*"--------------------------------------------------------------------

  DATA:
    lv_xml            TYPE xstring,
    lv_file_name      TYPE string,
    lo_ixml           TYPE REF TO if_ixml,
    lo_stream_factory TYPE REF TO if_ixml_stream_factory,
    lo_istream        TYPE REF TO if_ixml_istream,
    lo_doc            TYPE REF TO if_ixml_document,
    lo_parser         TYPE REF TO if_ixml_parser,
    lv_rc             TYPE i.

  lv_xml = iv_xml_string.

*   Display XML in una nuova finestra
  lo_ixml = cl_ixml=>create( ).
  lo_stream_factory = lo_ixml->create_stream_factory( ).

  lo_istream = lo_stream_factory->create_istream_xstring(
                 string = lv_xml ).

  lo_doc       = lo_ixml->create_document( ).
  lo_parser    = lo_ixml->create_parser( stream_factory = lo_stream_factory
                                         istream        = lo_istream
                                         document       = lo_doc ).

  lv_rc = lo_parser->parse( ).

  IF lv_rc <> ixml_mr_parser_ok.

    MESSAGE e802(zefattura) INTO zcl_efatt=>error_txt.
    zcl_efatt=>raise_edoc_exception( ).

  ENDIF.

  cl_uxs_xml_services=>show( EXPORTING  ir_dom      = lo_doc
                             EXCEPTIONS parse_error = 1
                             OTHERS                 = 2 ).

  IF sy-subrc <> 0.

    MESSAGE e071(zefattura) INTO zcl_efatt=>error_txt.
    zcl_efatt=>raise_edoc_exception( ).

  ENDIF.

ENDFUNCTION.
