class ZCX_EFATTURA definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

*"* public components of class ZCX_EFATTURA
*"* do not include other source files here!!!
public section.

  interfaces IF_T100_MESSAGE .

  data MV_MSGV1 type SYMSGV read-only .
  data MV_MSGV2 type SYMSGV read-only .
  data MV_MSGV3 type SYMSGV read-only .
  data MV_MSGV4 type SYMSGV read-only .
  data MT_MESSAGE type BAPIRET2_TAB read-only .
  data MV_MESSAGE type BAPI_MSG read-only .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MV_MSGV1 type SYMSGV optional
      !MV_MSGV2 type SYMSGV optional
      !MV_MSGV3 type SYMSGV optional
      !MV_MSGV4 type SYMSGV optional
      !MT_MESSAGE type BAPIRET2_TAB optional
      !MV_MESSAGE type BAPI_MSG optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_EFATTURA IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->MV_MSGV1 = MV_MSGV1 .
me->MV_MSGV2 = MV_MSGV2 .
me->MV_MSGV3 = MV_MSGV3 .
me->MV_MSGV4 = MV_MSGV4 .
me->MT_MESSAGE = MT_MESSAGE .
me->MV_MESSAGE = MV_MESSAGE .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
