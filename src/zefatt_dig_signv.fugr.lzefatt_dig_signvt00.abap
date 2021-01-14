*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 25.06.2020 at 18:03:09 by user DEVELOPER
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZEFATT_DIG_SIGNV................................*
TABLES: ZEFATT_DIG_SIGNV, *ZEFATT_DIG_SIGNV. "view work areas
CONTROLS: TCTRL_ZEFATT_DIG_SIGNV
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZEFATT_DIG_SIGNV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZEFATT_DIG_SIGNV.
* Table for entries selected to show on screen
DATA: BEGIN OF ZEFATT_DIG_SIGNV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZEFATT_DIG_SIGNV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZEFATT_DIG_SIGNV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZEFATT_DIG_SIGNV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZEFATT_DIG_SIGNV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZEFATT_DIG_SIGNV_TOTAL.

*.........table declarations:.................................*
TABLES: ZEFATT_DIG_SIGN                .
