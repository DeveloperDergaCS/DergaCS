*----------------------------------------------------------------------*
***INCLUDE LZEFATT_UTILSF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  HTML_VIEWVER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM html_viewver .

  DATA: assigned_url TYPE char255.

  IF html_viewer IS BOUND.

    html_viewer->free( ).
    html_container->free( ).

    CLEAR: html_viewer,
           html_container.

  ENDIF.

* Creo il contenitore che conterrà i diversi oggetti
  CREATE OBJECT html_container
    EXPORTING
      container_name = 'HTML_CONTAINER'.

* Aggancio il visualizzatore HTML al contenitore
  CREATE OBJECT html_viewer
    EXPORTING
      parent = html_container.

* Carico i dati HTML
  html_viewer->load_data( EXPORTING type         = type
                                    subtype      = subtype
                          IMPORTING assigned_url = assigned_url
                          CHANGING  data_table   = <html_table> ).

  html_viewer->show_url( url      = assigned_url
                         in_place = 'X' ).

ENDFORM.                    " HTML_VIEWVER
