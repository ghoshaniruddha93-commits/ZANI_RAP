@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BOOKING PROJECTION'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZATS_AG_BOOKING_PROCESSOR
  as projection on ZATS_AG_BOOKING
{
  key TravelId,
  key BookingId,
      BookingDate,
      @ObjectModel.text.element: [ 'CustomerName' ]
      @Consumption.valueHelpDefinition: [{ entity: {
          name: '/DMO/I_Customer',
          element: 'CustomerID'
      } }]
      CustomerId,
      @Semantics.text: true
      _Customer.LastName as CustomerName,
      @Consumption.valueHelpDefinition: [{ entity.name: '/DMO/I_Carrier',
                                           entity.element: 'AirlineID'
                                        }]
      CarrierId,
      @Consumption.valueHelpDefinition: [{ entity: {
          name: '/DMO/I_Connection',
          element: 'ConnectionID'
      },
        additionalBinding: [{ localElement: 'CarrierId',
                              element: 'AirlineID'
                           }]
      }]
      ConnectionId,
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      CurrencyCode,
      @Consumption.valueHelpDefinition: [{ entity: {
          name: '/DMO/I_Booking_Status_VH',
          element: 'BookingStatus'
      } }]
      BookingStatus,
      LastChangedAt,
      /* Associations */
      _BookingStatus,
      _BookingSupplement : redirected to composition child ZATS_AG_BOOKINGSUPPL_PROCESSOR,
      _Carrier,
      _Connection,
      _Customer,
      _Travel            : redirected to parent ZATS_AG_TRAVEL_PROCESSOR
}
