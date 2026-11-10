@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Invoice projection view for UI'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_CONC_INVOICE 
  provider contract transactional_query
  as projection on ZI_CONC_INVOICE
{
  key InvoiceId,
  @Search.defaultSearchElement: true
  VendorId,
  @Search.defaultSearchElement: true
  InvoiceNo,
  AmountLC,
  CurrencyLC,
  AmountEur,
  CurrencyEur,
  InvoiceDate,
  DcIndicator,
  Status,
  Description,
  CreatedBy,
  CreatedAt,
  ModifiedBy,
  ModifiedAt,
  /* Associations */
  _Vendor : redirected to ZC_CONC_VENDOR
}
