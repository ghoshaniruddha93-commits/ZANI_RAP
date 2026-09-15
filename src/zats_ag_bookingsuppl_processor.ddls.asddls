@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BOOKINGSUPPL PROJECTION'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZATS_AG_BOOKINGSUPPL_PROCESSOR
  as projection on ZATS_AG_BOOKSUPPL
{
  key travel_id,
  key booking_id,
  key booking_supplement_id,
      @Consumption.valueHelpDefinition: [{ entity: {
          name: '/DMO/I_Supplement',
          element: 'SupplementID'
      } }]
      supplement_id,
      @Semantics.amount.currencyCode: 'currency_code'
      price,
      currency_code,
      last_changed_at,
      /* Associations */
      _Booking : redirected to parent ZATS_AG_BOOKING_PROCESSOR,
      _Product,
      _SupplementText,
      _Travel  : redirected to ZATS_AG_TRAVEL_PROCESSOR
}
