*---------------------------------------------------------------------*
*    view related FORM routines
*   generation date: 29.06.2020 at 16:55:45 by user DEVELOPER
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZEFATT_MAP_TRASV................................*
FORM GET_DATA_ZEFATT_MAP_TRASV.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZEFATT_MAP_TRASM WHERE
(VIM_WHERETAB) .
    CLEAR ZEFATT_MAP_TRASV .
ZEFATT_MAP_TRASV-MANDT =
ZEFATT_MAP_TRASM-MANDT .
ZEFATT_MAP_TRASV-INTERFACCIA =
ZEFATT_MAP_TRASM-INTERFACCIA .
ZEFATT_MAP_TRASV-TARGET_FIELD =
ZEFATT_MAP_TRASM-TARGET_FIELD .
ZEFATT_MAP_TRASV-SOURCE_FIELD =
ZEFATT_MAP_TRASM-SOURCE_FIELD .
ZEFATT_MAP_TRASV-ATTRIBUTE_TAG =
ZEFATT_MAP_TRASM-ATTRIBUTE_TAG .
<VIM_TOTAL_STRUC> = ZEFATT_MAP_TRASV.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZEFATT_MAP_TRASV .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZEFATT_MAP_TRASV.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZEFATT_MAP_TRASV-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZEFATT_MAP_TRASM WHERE
  INTERFACCIA = ZEFATT_MAP_TRASV-INTERFACCIA AND
  TARGET_FIELD = ZEFATT_MAP_TRASV-TARGET_FIELD .
    IF SY-SUBRC = 0.
    DELETE ZEFATT_MAP_TRASM .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZEFATT_MAP_TRASM WHERE
  INTERFACCIA = ZEFATT_MAP_TRASV-INTERFACCIA AND
  TARGET_FIELD = ZEFATT_MAP_TRASV-TARGET_FIELD .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZEFATT_MAP_TRASM.
    ENDIF.
ZEFATT_MAP_TRASM-MANDT =
ZEFATT_MAP_TRASV-MANDT .
ZEFATT_MAP_TRASM-INTERFACCIA =
ZEFATT_MAP_TRASV-INTERFACCIA .
ZEFATT_MAP_TRASM-TARGET_FIELD =
ZEFATT_MAP_TRASV-TARGET_FIELD .
ZEFATT_MAP_TRASM-SOURCE_FIELD =
ZEFATT_MAP_TRASV-SOURCE_FIELD .
ZEFATT_MAP_TRASM-ATTRIBUTE_TAG =
ZEFATT_MAP_TRASV-ATTRIBUTE_TAG .
    IF SY-SUBRC = 0.
    UPDATE ZEFATT_MAP_TRASM .
    ELSE.
    INSERT ZEFATT_MAP_TRASM .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZEFATT_MAP_TRASV-UPD_FLAG,
STATUS_ZEFATT_MAP_TRASV-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZEFATT_MAP_TRASV.
  SELECT SINGLE * FROM ZEFATT_MAP_TRASM WHERE
INTERFACCIA = ZEFATT_MAP_TRASV-INTERFACCIA AND
TARGET_FIELD = ZEFATT_MAP_TRASV-TARGET_FIELD .
ZEFATT_MAP_TRASV-MANDT =
ZEFATT_MAP_TRASM-MANDT .
ZEFATT_MAP_TRASV-INTERFACCIA =
ZEFATT_MAP_TRASM-INTERFACCIA .
ZEFATT_MAP_TRASV-TARGET_FIELD =
ZEFATT_MAP_TRASM-TARGET_FIELD .
ZEFATT_MAP_TRASV-SOURCE_FIELD =
ZEFATT_MAP_TRASM-SOURCE_FIELD .
ZEFATT_MAP_TRASV-ATTRIBUTE_TAG =
ZEFATT_MAP_TRASM-ATTRIBUTE_TAG .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZEFATT_MAP_TRASV USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZEFATT_MAP_TRASV-INTERFACCIA TO
ZEFATT_MAP_TRASM-INTERFACCIA .
MOVE ZEFATT_MAP_TRASV-TARGET_FIELD TO
ZEFATT_MAP_TRASM-TARGET_FIELD .
MOVE ZEFATT_MAP_TRASV-MANDT TO
ZEFATT_MAP_TRASM-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZEFATT_MAP_TRASM'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZEFATT_MAP_TRASM TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZEFATT_MAP_TRASM'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*