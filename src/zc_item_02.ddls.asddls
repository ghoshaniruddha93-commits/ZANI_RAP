@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View for Item'
@Metadata.allowExtensions: true
define root view entity ZC_ITEM_02
  provider contract transactional_query
  as projection on ZR_ITEM_02
{
  key ItemId,
      Name,
      Description,
      Price,
      StatusCode
}
