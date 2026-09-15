@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root View Entity for Item'
@Metadata.allowExtensions: true
define root view entity ZR_ITEM_02
  as select from zitem_02
{
  key item_id               as ItemId,
      name                  as Name,
      description           as Description,
      price                 as Price,
      status_code           as StatusCode,

      local_created_by      as LocalCreatedBy,
      local_created_at      as LocalCreatedAt,
      local_last_changed_by as LocalLastChangedBy,
      local_last_changed_at as LocalLastChangedAt,
      last_changed_at       as LastChangedAt
}
