*---------------------------------------------------------------------*
*    view related FORM routines
*   generation date: 25.06.2020 at 18:03:09 by user DEVELOPER
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZEFATT_DIG_SIGNV................................*
FORM GET_DATA_ZEFATT_DIG_SIGNV.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZEFATT_DIG_SIGN WHERE
(VIM_WHERETAB) .
    CLEAR ZEFATT_DIG_SIGNV .
ZEFATT_DIG_SIGNV-MANDT =
ZEFATT_DIG_SIGN-MANDT .
ZEFATT_DIG_SIGNV-INTERFACCIA =
ZEFATT_DIG_SIGN-INTERFACCIA .
ZEFATT_DIG_SIGNV-REGOLA_MAP =
ZEFATT_DIG_SIGN-REGOLA_MAP .
ZEFATT_DIG_SIGNV-MAP_BEGIN =
ZEFATT_DIG_SIGN-MAP_BEGIN .
ZEFATT_DIG_SIGNV-MAP_END =
ZEFATT_DIG_SIGN-MAP_END .
<VIM_TOTAL_STRUC> = ZEFATT_DIG_SIGNV.
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
FORM DB_UPD_ZEFATT_DIG_SIGNV .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZEFATT_DIG_SIGNV.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZEFATT_DIG_SIGNV-ST_DELETE EQ GELOESCHT.
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
  SELECT SINGLE FOR UPDATE * FROM ZEFATT_DIG_SIGN WHERE
  INTERFACCIA = ZEFATT_DIG_SIGNV-INTERFACCIA AND
  REGOLA_MAP = ZEFATT_DIG_SIGNV-REGOLA_MAP AND
  MAP_BEGIN = ZEFATT_DIG_SIGNV-MAP_BEGIN .
    IF SY-SUBRC = 0.
    DELETE ZEFATT_DIG_SIGN .
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
  SELECT SINGLE FOR UPDATE * FROM ZEFATT_DIG_SIGN WHERE
  INTERFACCIA = ZEFATT_DIG_SIGNV-INTERFACCIA AND
  REGOLA_MAP = ZEFATT_DIG_SIGNV-REGOLA_MAP AND
  MAP_BEGIN = ZEFATT_DIG_SIGNV-MAP_BEGIN .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZEFATT_DIG_SIGN.
    ENDIF.
ZEFATT_DIG_SIGN-MANDT =
ZEFATT_DIG_SIGNV-MANDT .
ZEFATT_DIG_SIGN-INTERFACCIA =
ZEFATT_DIG_SIGNV-INTERFACCIA .
ZEFATT_DIG_SIGN-REGOLA_MAP =
ZEFATT_DIG_SIGNV-REGOLA_MAP .
ZEFATT_DIG_SIGN-MAP_BEGIN =
ZEFATT_DIG_SIGNV-MAP_BEGIN .
ZEFATT_DIG_SIGN-MAP_END =
ZEFATT_DIG_SIGNV-MAP_END .
    IF SY-SUBRC = 0.
    UPDATE ZEFATT_DIG_SIGN .
    ELSE.
    INSERT ZEFATT_DIG_SIGN .
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
CLEAR: STATUS_ZEFATT_DIG_SIGNV-UPD_FLAG,
STATUS_ZEFATT_DIG_SIGNV-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZEFATT_DIG_SIGNV.
  SELECT SINGLE * FROM ZEFATT_DIG_SIGN WHERE
INTERFACCIA = ZEFATT_DIG_SIGNV-INTERFACCIA AND
REGOLA_MAP = ZEFATT_DIG_SIGNV-REGOLA_MAP AND
MAP_BEGIN = ZEFATT_DIG_SIGNV-MAP_BEGIN .
ZEFATT_DIG_SIGNV-MANDT =
ZEFATT_DIG_SIGN-MANDT .
ZEFATT_DIG_SIGNV-INTERFACCIA =
ZEFATT_DIG_SIGN-INTERFACCIA .
ZEFATT_DIG_SIGNV-REGOLA_MAP =
ZEFATT_DIG_SIGN-REGOLA_MAP .
ZEFATT_DIG_SIGNV-MAP_BEGIN =
ZEFATT_DIG_SIGN-MAP_BEGIN .
ZEFATT_DIG_SIGNV-MAP_END =
ZEFATT_DIG_SIGN-MAP_END .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZEFATT_DIG_SIGNV USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZEFATT_DIG_SIGNV-INTERFACCIA TO
ZEFATT_DIG_SIGN-INTERFACCIA .
MOVE ZEFATT_DIG_SIGNV-REGOLA_MAP TO
ZEFATT_DIG_SIGN-REGOLA_MAP .
MOVE ZEFATT_DIG_SIGNV-MAP_BEGIN TO
ZEFATT_DIG_SIGN-MAP_BEGIN .
MOVE ZEFATT_DIG_SIGNV-MANDT TO
ZEFATT_DIG_SIGN-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZEFATT_DIG_SIGN'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZEFATT_DIG_SIGN TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZEFATT_DIG_SIGN'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
