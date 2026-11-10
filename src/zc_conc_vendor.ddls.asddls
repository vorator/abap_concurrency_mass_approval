@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vendor projection view for UI'
define root view entity ZC_CONC_VENDOR
  provider contract transactional_query
  as projection on ZI_CONC_VENDOR
{
  key VendorId,
  VendorName,
  CountryCode,
  VendorType as TypeOfVendor,
  VatNumber,
  ViesStatus,
  CreatedBy,
  CreatedAt,
  ModifiedBy,
  ModifiedAt
}
