@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Basic View for invoice table'
@Metadata.ignorePropagatedAnnotations: false
define root view entity ZI_conc_INVOICE as select from zconc_invoice
  association [0..1] to ZI_conc_VENDOR as _Vendor
  on $projection.VendorId = _Vendor.VendorId
{
  key invoice_id  as InvoiceId,
  vendor_id       as VendorId,
  invoice_number  as InvoiceNo,
  amount_lc       as AmountLC,
  currency_lc     as CurrencyLC,
  amount_eur      as AmountEur,
  currency_eur    as CurrencyEur,
  invoice_date    as InvoiceDate,
  dc_indicator    as DcIndicator,
  status          as Status,
  description     as Description,
  @Semantics.user.createdBy: true
  created_by      as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at      as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  modified_by     as ModifiedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  modified_at     as ModifiedAt,
  _Vendor
}
