@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ROOT VIEW TRAVEL PROJECTION'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZATS_AG_TRAVEL_PROCESSOR
  provider contract transactional_query
  as projection on ZATS_AG_TRAVEL
{
      @ObjectModel.text.element: [ 'Description' ]
  key TravelId,
      @ObjectModel.text.element: [ 'AgencyName' ]
      @Consumption.valueHelpDefinition: [{entity: {
          name: '/DMO/I_Agency',
          element: 'AgencyID'
      }  }]
      AgencyId,
      @Semantics.text: true
      _Agency.Name       as AgencyName,
      @Consumption.valueHelpDefinition: [{ entity: {
          name: '/DMO/I_Customer',
          element: 'CustomerID'
      } }]
      @ObjectModel.text.element: [ 'CustomerName' ]
      CustomerId,
      @Semantics.text: true
      _Customer.LastName as CustomerName,
      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      CurrencyCode,
      @Semantics.text: true
      Description,
      @ObjectModel.text.element: [ 'StatusText' ]
      @Consumption.valueHelpDefinition: [{ entity: {
          name: '/DMO/I_Overall_Status_VH',
          element: 'OverallStatus'
      } }]
      OverallStatus,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Semantics.text: true
      StatusText,
      Criticality,
      /* Associations */
      _Agency,
      _Booking : redirected to composition child ZATS_AG_BOOKING_PROCESSOR,
      _Currency,
      _Customer,
      _overallStatus
}
