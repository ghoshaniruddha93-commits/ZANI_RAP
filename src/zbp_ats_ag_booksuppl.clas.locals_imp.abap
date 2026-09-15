CLASS lhc_booksuppl DEFINITION INHERITING FROM cl_abap_behavior_handler.
*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

  PRIVATE SECTION.

    METHODS CalcTotalPrice FOR DETERMINE ON MODIFY
       keys FOR BookSuppl~CalcTotalPrice.

ENDCLASS.

CLASS lhc_booksuppl IMPLEMENTATION.

  METHOD CalcTotalPrice.

    READ ENTITIES OF zats_ag_travel IN LOCAL MODE
    ENTITY booking BY \_BookingSupplement
    FIELDS ( travel_id  )
    WITH VALUE #( FOR key IN keys (
                  %is_draft = key-%is_draft
                  travelid = key-travel_id
                  bookingid = key-booking_id ) )
     RESULT DATA(travels).
*booking_id booking_supplement_id price currency_code
*    DATA: travel_ids TYPE TABLE OF zats_ag_travel_processor WITH UNIQUE HASHED KEY
*                                                            key COMPONENTS TravelId.
*
*    travel_ids = CORRESPONDING #( keys DISCARDING DUPLICATES MAPPING travelid = Travel_Id ).

    DATA: lt_travel_keys TYPE TABLE FOR ACTION IMPORT zats_ag_travel\\Travel~reCalcTotalPrice.

    " Explicitly map the fields to handle the travel_id vs travelid mismatch
    lt_travel_keys = VALUE #( FOR <ls_supp> IN travels
                              ( %is_draft = <ls_supp>-%is_draft
                                travelid  = <ls_supp>-travel_id ) ).

    " Clear duplicate entries so the internal action executes only once per travel
    SORT lt_travel_keys BY travelid %is_draft.
    DELETE ADJACENT DUPLICATES FROM lt_travel_keys COMPARING travelid %is_draft.

    " --- EXECUTE INTERNAL ACTION ---

    MODIFY ENTITIES OF zats_ag_travel IN LOCAL MODE
    ENTITY Travel
    EXECUTE reCalcTotalPrice
    FROM CORRESPONDING #( lt_travel_keys ).
  ENDMETHOD.

ENDCLASS.

