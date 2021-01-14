*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 04.01.2021 at 18:21:47
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZEFATT_CONF_RESV................................*
TABLES: ZEFATT_CONF_RESV, *ZEFATT_CONF_RESV. "view work areas
CONTROLS: TCTRL_ZEFATT_CONF_RESV
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZEFATT_CONF_RESV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZEFATT_CONF_RESV.
* Table for entries selected to show on screen
DATA: BEGIN OF ZEFATT_CONF_RESV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZEFATT_CONF_RESV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZEFATT_CONF_RESV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZEFATT_CONF_RESV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZEFATT_CONF_RESV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZEFATT_CONF_RESV_TOTAL.

*.........table declarations:.................................*
TABLES: ZEFATT_CONF_REST               .
