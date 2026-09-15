*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS earlynumbering_cba_Bookingsupp FOR NUMBERING
       entities FOR CREATE Booking\_Bookingsupplement.
    METHODS CalcTotalPrice FOR DETERMINE ON MODIFY
       keys FOR Booking~CalcTotalPrice.

ENDCLASS.

CLASS lhc_booking IMPLEMENTATION.

  METHOD earlynumbering_cba_Bookingsupp.
    READ ENTITIES OF zats_ag_travel IN LOCAL MODE
    ENTITY booking BY \_BookingSupplement
    FROM CORRESPONDING #( entities )
    LINK DATA(booksuppl).

    DATA: max_booksuppl_id TYPE /dmo/booking_supplement_id.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_booking>)
                               GROUP BY <ls_booking>-%tky.
      CLEAR max_booksuppl_id.
      LOOP AT booksuppl ASSIGNING FIELD-SYMBOL(<ls_booksuppl>) USING KEY entity
                        WHERE source-TravelId = <ls_booking>-TravelId
                        AND   source-BookingId = <ls_booking>-BookingId.

        IF max_booksuppl_id < <ls_booksuppl>-target-booking_supplement_id.
          max_booksuppl_id = <ls_booksuppl>-target-booking_supplement_id.
        ENDIF.
      ENDLOOP.

      LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
        LOOP AT <ls_entity>-%target INTO DATA(ls_bookingsuppl).
          max_booksuppl_id = max_booksuppl_id + 1.
          ls_bookingsuppl-booking_supplement_id = max_booksuppl_id.
          APPEND CORRESPONDING #( ls_bookingsuppl )  TO mapped-booksuppl.
        ENDLOOP.
        CLEAR max_booksuppl_id.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
  METHOD CalcTotalPrice.
    READ ENTITIES OF zats_ag_travel IN LOCAL MODE
    ENTITY travel BY \_Booking
    FIELDS ( TravelId BookingId FlightPrice CurrencyCode )
    WITH value #( for key in keys (
                  %is_draft = key-%is_draft
                  travelid = key-TravelId  ) )
    RESULT DATA(travels).
*
*    DATA: travel_ids TYPE TABLE OF zats_ag_travel_processor WITH UNIQUE HASHED KEY key COMPONENTS TravelId.
*
*    travel_ids = CORRESPONDING #( keys DISCARDING DUPLICATES MAPPING travelid = TravelId ).

    MODIFY ENTITIES OF zats_ag_travel IN LOCAL MODE
    ENTITY travel
    EXECUTE reCalcTotalPrice
    FROM CORRESPONDING #( travels ).
*    FROM CORRESPONDING #( travel_ids ).
*    REPORTED DATA(lt_reported)
*    FAILED DATA(lt_failed).
*
*    reported = CORRESPONDING #( DEEP lt_reported ).
  ENDMETHOD.

ENDCLASS.
