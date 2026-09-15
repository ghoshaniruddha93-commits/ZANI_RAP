@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CHILD VIEW Booking supplement'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZATS_AG_BOOKSUPPL
  as select from /DMO/I_BookSuppl_M

  association        to parent ZATS_AG_BOOKING as _Booking        on  $projection.travel_id  = _Booking.TravelId
                                                                  and $projection.booking_id = _Booking.BookingId

  association [1..1] to ZATS_AG_TRAVEL         as _Travel         on  $projection.travel_id = _Travel.TravelId
  association [1..1] to /DMO/I_Supplement      as _Product        on  $projection.supplement_id = _Product.SupplementID
  association [1..*] to /DMO/I_SupplementText  as _SupplementText on  $projection.supplement_id = _SupplementText.SupplementID
{

  key travel_id,
  key booking_id,
  key booking_supplement_id,
      supplement_id,
      @Semantics.amount.currencyCode: 'currency_code'
      price,
      currency_code,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at,
      /* Associations */
      _Booking,
      _Product,
      _SupplementText,
      _Travel
}
