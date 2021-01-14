*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 24.11.2020 at 19:25:33 by user MAZZARELLI
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZEFATT_MAP_FLD_V................................*
TABLES: ZEFATT_MAP_FLD_V, *ZEFATT_MAP_FLD_V. "view work areas
CONTROLS: TCTRL_ZEFATT_MAP_FLD_V
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZEFATT_MAP_FLD_V. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZEFATT_MAP_FLD_V.
* Table for entries selected to show on screen
DATA: BEGIN OF ZEFATT_MAP_FLD_V_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZEFATT_MAP_FLD_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZEFATT_MAP_FLD_V_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZEFATT_MAP_FLD_V_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZEFATT_MAP_FLD_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZEFATT_MAP_FLD_V_TOTAL.

*.........table declarations:.................................*
TABLES: ZEFATT_MAP_FIELD               .
