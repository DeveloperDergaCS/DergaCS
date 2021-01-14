*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 29.06.2020 at 16:55:45 by user DEVELOPER
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZEFATT_MAP_TRASV................................*
TABLES: ZEFATT_MAP_TRASV, *ZEFATT_MAP_TRASV. "view work areas
CONTROLS: TCTRL_ZEFATT_MAP_TRASV
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZEFATT_MAP_TRASV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZEFATT_MAP_TRASV.
* Table for entries selected to show on screen
DATA: BEGIN OF ZEFATT_MAP_TRASV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZEFATT_MAP_TRASV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZEFATT_MAP_TRASV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZEFATT_MAP_TRASV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZEFATT_MAP_TRASV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZEFATT_MAP_TRASV_TOTAL.

*.........table declarations:.................................*
TABLES: ZEFATT_MAP_TRASM               .
