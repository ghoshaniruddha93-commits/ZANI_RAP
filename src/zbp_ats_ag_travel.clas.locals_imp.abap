CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS copytravel FOR MODIFY
       keys FOR ACTION travel~copytravel.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR travel RESULT result.
    METHODS validatecuntomer FOR VALIDATE ON SAVE
       keys FOR travel~validatecuntomer.
    METHODS determinebegindate FOR DETERMINE ON MODIFY
       keys FOR travel~determinebegindate.
    METHODS agencyidtocustomerid FOR DETERMINE ON MODIFY
       keys FOR travel~agencyidtocustomerid.
    METHODS calctotalprice FOR DETERMINE ON MODIFY
       keys FOR travel~calctotalprice.
    METHODS recalctotalprice FOR MODIFY
       keys FOR ACTION travel~recalctotalprice.

    METHODS earlynumbering_create FOR NUMBERING
       entities FOR CREATE Travel.

    METHODS earlynumbering_booking_create FOR NUMBERING
       entities FOR CREATE Travel\_Booking.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA: entity        TYPE STRUCTURE FOR CREATE zats_ag_travel,
          travel_id_max TYPE /dmo/travel_id.

    LOOP AT entities INTO entity WHERE travelid IS NOT INITIAL.
      APPEND CORRESPONDING #( entity ) TO mapped-travel.
    ENDLOOP.

    DATA(entities_wo_travelid) = entities.
    DELETE entities_wo_travelid WHERE travelid IS NOT INITIAL.

    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
*            ignore_buffer     =
            nr_range_nr       = '01'
            object            = '/DMO/TRAVL'
            quantity          = CONV #( lines( entities_wo_travelid ) )
          IMPORTING
            number            = DATA(number_range_key)
            returncode        = DATA(number_range_code)
            returned_quantity = DATA(number_range_quantity)
        ).
*        CATCH cx_nr_object_not_found.
      CATCH cx_number_ranges INTO DATA(lx_number_ranges).
        LOOP AT entities_wo_travelid INTO entity.
          APPEND VALUE #( %cid = entity-%cid %key = entity-%key %msg = lx_number_ranges )
              TO reported-travel.
          APPEND VALUE #( %cid = entity-%cid %key = entity-%key )
              TO failed-travel.
        ENDLOOP.
        EXIT.
    ENDTRY.

    CASE number_range_code.
      WHEN '1'.
        APPEND VALUE #( %cid = entity-%cid %key = entity-%key
                        %msg = NEW /dmo/cm_flight_messages(
                                  textid                = /dmo/cm_flight_messages=>number_range_depleted
                                  severity              = if_abap_behv_message=>severity-warning )
        ) TO reported-travel.

      WHEN '2' OR '3'.
        APPEND VALUE #( %cid = entity-%cid %key = entity-%key
                        %fail-cause = if_abap_behv=>cause-conflict ) TO failed-travel.

    ENDCASE.

    ASSERT number_range_quantity = lines( entities_wo_travelid ).

    travel_id_max = travel_id_max -  number_range_key.

    LOOP AT entities_wo_travelid INTO entity.
      travel_id_max = travel_id_max + 1.
      entity-TravelId = travel_id_max.
      APPEND VALUE #( %cid = entity-%cid
                      %key = entity-%key
                      %is_draft = entity-%is_draft ) TO mapped-travel.
    ENDLOOP.


  ENDMETHOD.

  METHOD earlynumbering_booking_create.
    READ ENTITIES OF zats_ag_travel IN LOCAL MODE
    ENTITY travel BY \_Booking
    FROM CORRESPONDING #( entities )
    LINK DATA(bookings).

    DATA: max_booking_id TYPE /dmo/booking_id VALUE 0.

    LOOP AT entities INTO DATA(travel_group) GROUP BY travel_group-TravelId.
      LOOP AT bookings INTO DATA(ls_booking) USING KEY entity
        WHERE source-travelid = travel_group-TravelId.
        IF max_booking_id < ls_booking-target-BookingId.
          max_booking_id = ls_booking-target-BookingId.
        ENDIF.
      ENDLOOP.

      LOOP AT entities INTO DATA(ls_travel) USING KEY entity
      WHERE travelid = travel_group-TravelId.
        LOOP AT ls_travel-%target INTO DATA(booking).
          max_booking_id += 10.
          booking-BookingId = max_booking_id.
          APPEND CORRESPONDING #( booking ) TO mapped-booking.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD CopyTravel.
    DATA: travels       TYPE TABLE FOR CREATE zats_ag_travel\\Travel,
          bookings_cba  TYPE TABLE FOR CREATE zats_ag_travel\\Travel\_Booking,
          booksuppl_cba TYPE TABLE FOR CREATE zats_ag_travel\\Booking\_BookingSupplement.

    READ TABLE keys WITH KEY %cid = '' INTO DATA(key_with_initial_cid).
    ASSERT key_with_initial_cid IS INITIAL.

    READ ENTITIES OF zats_ag_travel IN LOCAL MODE
    ENTITY travel
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(travel_read_result)
    FAILED DATA(fail).

    IF fail IS NOT INITIAL.
      LOOP AT keys INTO DATA(key).
        APPEND VALUE #( %cid = key-%cid %key = key-%key ) TO fail-travel.
      ENDLOOP.
    ENDIF.

    READ ENTITIES OF zats_ag_travel IN LOCAL MODE
    ENTITY travel BY \_Booking
    ALL FIELDS WITH CORRESPONDING #( travel_read_result )
    RESULT DATA(booking_read_result)
    FAILED fail.
    IF sy-subrc <> 0.
      LOOP AT keys INTO key.
        APPEND VALUE #( %cid = key-%cid %key = key-%key ) TO fail-travel.
      ENDLOOP.
    ENDIF.

    READ ENTITIES OF zats_ag_travel IN LOCAL MODE
    ENTITY booking BY \_BookingSupplement
    ALL FIELDS WITH CORRESPONDING #( booking_read_result )
    RESULT DATA(booksuppl_read_result)
    FAILED fail.

    IF sy-subrc <> 0.
      LOOP AT keys INTO key.
        APPEND VALUE #( %cid = key-%cid %key = key-%key ) TO fail-travel.
      ENDLOOP.
    ENDIF.

    LOOP AT travel_read_result ASSIGNING FIELD-SYMBOL(<travel>).
      APPEND VALUE #( %cid = keys[ %tky = <travel>-%tky ]-%cid
                      %data = CORRESPONDING #( <travel> EXCEPT TravelId ) )
                      TO travels ASSIGNING FIELD-SYMBOL(<new_travel>).

      <new_travel>-BeginDate = cl_abap_context_info=>get_system_date(  ).
      <new_travel>-EndDate = cl_abap_context_info=>get_system_date(  ).
      <new_travel>-OverallStatus = 'O'.

      APPEND VALUE #( %cid_ref = keys[ KEY entity %tky =  <travel>-%tky ]-%cid )
      TO bookings_cba ASSIGNING FIELD-SYMBOL(<booking_cba>).

      LOOP AT booking_read_result ASSIGNING FIELD-SYMBOL(<booking>) WHERE TravelId = <travel>-TravelId.
        APPEND VALUE #( %cid = keys[ KEY entity %tky = <travel>-%tky ]-%cid && <booking>-BookingId
                        %data = CORRESPONDING #( booking_read_result[ KEY entity %tky = <booking>-%tky ] EXCEPT travelId  ) )
                        TO <booking_cba>-%target  ASSIGNING FIELD-SYMBOL(<new_booking>).

        <new_booking>-BookingStatus = 'N'.

        APPEND VALUE #( %cid_ref = keys[ KEY entity %tky = <travel>-%tky ]-%cid && <booking>-BookingId )
                        TO booksuppl_cba ASSIGNING FIELD-SYMBOL(<booksuppl_cba>).

        LOOP AT booksuppl_read_result ASSIGNING FIELD-SYMBOL(<booksuppl>) WHERE travel_id = <travel>-TravelId AND
                                                                                booking_id = <booking>-BookingId.

          APPEND VALUE #( %cid = keys[ KEY entity %tky = <travel>-%tky ]-%cid && <booking>-BookingId && <booksuppl>-booking_supplement_id
                          %data = CORRESPONDING #( booksuppl_read_result[ KEY entity %tky = <booksuppl>-%tky ] EXCEPT travel_id booking_id )
          ) TO <booksuppl_cba>-%target.

        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF zats_ag_travel IN LOCAL MODE
    ENTITY travel
    CREATE FIELDS ( AgencyId BeginDate BookingFee CurrencyCode
                    CustomerId Description EndDate OverallStatus TotalPrice )
    WITH CORRESPONDING #( travels )
        CREATE BY \_Booking FIELDS ( BookingDate BookingStatus CarrierId ConnectionId
                                     CustomerId FlightDate FlightPrice )
          WITH bookings_cba
                ENTITY Booking
                    CREATE BY \_BookingSupplement FIELDS ( currency_code price supplement_id )
                    WITH booksuppl_cba
   MAPPED DATA(mapped_create).

    mapped-travel = mapped_create-travel.

  ENDMETHOD.

  METHOD get_instance_features.
    DATA: booking_allow LIKE LINE OF result.
    READ ENTITIES OF zats_ag_travel IN LOCAL MODE
    ENTITY travel
    FIELDS ( TravelId OverallStatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels)
    FAILED failed.

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
* OLD SYNTAX-------------->
*      IF <travel>-OverallStatus = 'X'.
*        DATA(lv_allow) = if_abap_behv=>fc-o-disabled.
*      ELSE.
*        lv_allow = if_abap_behv=>fc-o-enabled.
*      ENDIF.
*      booking_allow = VALUE #( %tky = <travel>-%tky %assoc-_Booking = lv_allow ).
*      APPEND booking_allow TO result.
* NEW SYNTAX---------------->
      APPEND VALUE #( %tky = <travel>-%tky
                      %assoc-_booking = COND #(
                             WHEN <travel>-OverallStatus = 'X'
                                  THEN if_abap_behv=>fc-o-disabled
                             ELSE if_abap_behv=>fc-o-enabled )
                     ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateCuntomer.
    READ ENTITIES OF zats_ag_travel IN LOCAL MODE
    ENTITY Travel
    FIELDS ( CustomerId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).

    DATA: lt_cust TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    lt_cust = CORRESPONDING #( lt_travel DISCARDING DUPLICATES MAPPING customer_id = CustomerId ).
    DELETE lt_cust WHERE customer_id IS INITIAL.

    IF lt_cust IS NOT INITIAL.
      SELECT
          FROM /dmo/customer
          FIELDS customer_id
          FOR ALL ENTRIES IN @lt_cust
          WHERE customer_id = @lt_cust-customer_id
          INTO TABLE @DATA(lt_cust_tmp).

      IF sy-subrc <> 0.
        LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<travel>).
          APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
          APPEND VALUE #( %tky = <travel>-%tky
                          %msg = NEW /dmo/cm_flight_messages(
                                    textid       = /dmo/cm_flight_messages=>customer_unkown
                                    customer_id  = <travel>-CustomerId
                                    severity     =  if_abap_behv_message=>severity-error )

                           %element-CustomerId = if_abap_behv=>mk-on
                         ) TO reported-travel.

        ENDLOOP.
      ENDIF.
    ELSE.
      LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<travel2>).
        APPEND VALUE #( %tky = <travel2>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel2>-%tky
                        %msg = NEW /dmo/cm_flight_messages(
                                  textid       = /dmo/cm_flight_messages=>customer_unkown
                                  customer_id  = <travel2>-CustomerId
                                  severity     =  if_abap_behv_message=>severity-error )

                         %element-CustomerId = if_abap_behv=>mk-on
                       ) TO reported-travel.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
  METHOD determineBeginDate.
    MODIFY ENTITIES OF zats_ag_travel IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS ( BeginDate )
    WITH VALUE #( FOR ls_key IN keys
                   (
                        %tky = ls_key-%tky
*                        TravelId = ls_key-TravelId
                        BeginDate = cl_abap_context_info=>get_system_date(  )
                   )
                )
    REPORTED DATA(lt_reported).

    IF lt_reported IS NOT INITIAL.
      reported = CORRESPONDING #( DEEP lt_reported ).
    ENDIF.

  ENDMETHOD.

  METHOD agencyIdtoCustomerID.
    READ ENTITIES OF zats_ag_travel IN LOCAL MODE
    ENTITY travel
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel)
    REPORTED DATA(lt_reported).

    reported = CORRESPONDING #( DEEP lt_reported ).

    IF lt_travel IS NOT INITIAL.
      MODIFY ENTITIES OF zats_ag_travel IN LOCAL MODE
      ENTITY travel
      UPDATE FIELDS ( CustomerId )
      WITH VALUE #( FOR ls_travel IN lt_travel
                    (
                      %tky = ls_travel-%tky
                      CustomerId = ls_travel-AgencyId
                  ) )
          REPORTED DATA(lt_reported_travel)
          FAILED DATA(lt_failed).
    ENDIF.
    IF lt_reported IS NOT INITIAL.
      reported = CORRESPONDING #( DEEP BASE ( reported ) lt_reported_travel ).
    ENDIF.
  ENDMETHOD.

  METHOD CalcTotalPrice.
    MODIFY ENTITIES OF zats_ag_travel IN LOCAL MODE
    ENTITY travel
    EXECUTE reCalcTotalPrice
    FROM CORRESPONDING #( keys ).

  ENDMETHOD.

  METHOD reCalcTotalPrice.
*    Define a structure where we can store all the booking fees and currency code
    TYPES : BEGIN OF ty_amount_per_currency,
              amount        TYPE /dmo/total_price,
              currency_code TYPE /dmo/currency_code,
            END OF ty_amount_per_currency.

    DATA : amounts_per_currencycode TYPE STANDARD TABLE OF ty_amount_per_currency.

*    Read all travel instances, subsequent bookings using EML
    READ ENTITIES OF zats_ag_travel IN LOCAL MODE
       ENTITY Travel
       FIELDS ( BookingFee CurrencyCode )
       WITH CORRESPONDING #( keys )
       RESULT DATA(travels).

    READ ENTITIES OF zats_ag_travel IN LOCAL MODE
       ENTITY Travel BY \_Booking
       FIELDS ( FlightPrice CurrencyCode )
       WITH CORRESPONDING #( travels )
       RESULT DATA(bookings).

    READ ENTITIES OF zats_ag_travel IN LOCAL MODE
       ENTITY booking BY \_BookingSupplement
       FIELDS ( price Currency_Code )
       WITH CORRESPONDING #( bookings )
       RESULT DATA(bookingsupplements).

*    Delete the values w/o any currency
    DELETE travels WHERE CurrencyCode IS INITIAL.
    DELETE bookings WHERE CurrencyCode IS INITIAL.
    DELETE bookingsupplements WHERE Currency_Code IS INITIAL.

*    Total all booking and supplement amounts which are in common currency
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      "Set the first value for total price by adding the booking fee from header
      amounts_per_currencycode = VALUE #( ( amount = <travel>-BookingFee
                                          currency_code = <travel>-CurrencyCode ) ).

*    Loop at all amounts and compare with target currency
      LOOP AT bookings INTO DATA(booking) WHERE TravelId = <travel>-TravelId.

        COLLECT VALUE ty_amount_per_currency( amount = booking-FlightPrice
                                              currency_code = booking-CurrencyCode
        ) INTO amounts_per_currencycode.

      ENDLOOP.

      LOOP AT bookingsupplements INTO DATA(bookingsupplement) WHERE Travel_Id = <travel>-TravelId.

        COLLECT VALUE ty_amount_per_currency( amount = bookingsupplement-Price
                                              currency_code = booking-CurrencyCode
        ) INTO amounts_per_currencycode.

      ENDLOOP.

      CLEAR <travel>-TotalPrice.
*    Perform currency conversion
      LOOP AT amounts_per_currencycode INTO DATA(amount_per_currencycode).

        IF amount_per_currencycode-currency_code = <travel>-CurrencyCode.
          <travel>-TotalPrice += amount_per_currencycode-amount.
        ELSE.

          /dmo/cl_flight_amdp=>convert_currency(
            EXPORTING
              iv_amount               = amount_per_currencycode-amount
              iv_currency_code_source = amount_per_currencycode-currency_code
              iv_currency_code_target = <travel>-CurrencyCode
              iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
            IMPORTING
              ev_amount               = DATA(total_booking_amt)
          ).

          <travel>-TotalPrice = <travel>-TotalPrice + total_booking_amt.
        ENDIF.

      ENDLOOP.
*    Put back the total amount

    ENDLOOP.
*    Return the total amount in mapped so the RAP will modify this data to DB
    MODIFY ENTITIES OF zats_ag_travel IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS ( TotalPrice )
    WITH CORRESPONDING #( travels ).


  ENDMETHOD.

ENDCLASS.
