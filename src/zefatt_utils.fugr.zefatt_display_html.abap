FUNCTION zefatt_display_html.
*"----------------------------------------------------------------------
*"*"Interfaccia locale:
*"  IMPORTING
*"     VALUE(I_TYPE) TYPE  TEXT20
*"     VALUE(I_SUBTYPE) TYPE  TEXT20
*"     VALUE(I_HTML_TABLE) TYPE  SOLI_TAB OPTIONAL
*"     VALUE(I_BYNARY_TABLE) TYPE  SWXMLCONT OPTIONAL
*"----------------------------------------------------------------------

  UNASSIGN <html_table>.

  IF i_bynary_table IS SUPPLIED.
    ASSIGN  i_bynary_table TO <html_table>.
  ELSE.
    ASSIGN  i_html_table TO <html_table>.
  ENDIF.

  CHECK <html_table> IS ASSIGNED.

  CLEAR: type,
         subtype.

  type    = i_type.
  subtype = i_subtype.

  CALL SCREEN 1.

ENDFUNCTION.
