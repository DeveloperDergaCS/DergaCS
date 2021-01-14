*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 26.05.2020 at 12:35:35
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZEFATT_MAP_XML_V................................*
TABLES: ZEFATT_MAP_XML_V, *ZEFATT_MAP_XML_V. "view work areas
CONTROLS: TCTRL_ZEFATT_MAP_XML_V
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZEFATT_MAP_XML_V. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZEFATT_MAP_XML_V.
* Table for entries selected to show on screen
DATA: BEGIN OF ZEFATT_MAP_XML_V_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZEFATT_MAP_XML_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZEFATT_MAP_XML_V_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZEFATT_MAP_XML_V_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZEFATT_MAP_XML_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZEFATT_MAP_XML_V_TOTAL.

*.........table declarations:.................................*
TABLES: ZEFATT_MAP_XML                 .
