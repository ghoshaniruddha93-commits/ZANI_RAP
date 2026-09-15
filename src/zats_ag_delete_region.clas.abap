CLASS zats_ag_delete_region DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES IF_OO_ADT_CLASSRUN.
    CLASS-METHODS DELETE_REGION.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zats_ag_delete_region IMPLEMENTATION.
  METHOD delete_region.
    DELETE FROM ZATS_AG_REGION.

  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.
    zats_ag_delete_region=>delete_region( ).
    OUT->write( 'DELETED' ).
  ENDMETHOD.

ENDCLASS.
