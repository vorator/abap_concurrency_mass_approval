@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Basic View for vendor master table'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_conc_VENDOR as select from zconc_vendor
{
  key vendor_id as VendorId,
  vendor_name   as VendorName,
  country_code  as CountryCode,
  vendor_type   as VendorType,
  vat_number    as VatNumber,
  vies_status   as ViesStatus,
  @Semantics.user.createdBy: true
  created_by    as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at    as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  modified_by   as ModifiedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  modified_at   as ModifiedAt
}
