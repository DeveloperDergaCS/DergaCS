*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 16.06.2020 at 13:16:35
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZEFATT_MAP_RULEV................................*
TABLES: ZEFATT_MAP_RULEV, *ZEFATT_MAP_RULEV. "view work areas
CONTROLS: TCTRL_ZEFATT_MAP_RULEV
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZEFATT_MAP_RULEV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZEFATT_MAP_RULEV.
* Table for entries selected to show on screen
DATA: BEGIN OF ZEFATT_MAP_RULEV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZEFATT_MAP_RULEV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZEFATT_MAP_RULEV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZEFATT_MAP_RULEV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZEFATT_MAP_RULEV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZEFATT_MAP_RULEV_TOTAL.

*.........table declarations:.................................*
TABLES: ZEFATT_MAP_RULE                .
