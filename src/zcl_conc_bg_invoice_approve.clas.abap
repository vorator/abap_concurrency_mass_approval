class zcl_conc_bg_invoice_approve definition
  public
  final
  create public .

  public section.

    interfaces if_serializable_object .
    interfaces if_bgmc_operation .
    interfaces if_bgmc_op_single .

    types tt_invoice_ids type standard table of sysuuid_x16 with default key.

    methods constructor
      importing
        it_invoice_ids type tt_invoice_ids.

  protected section.
  private section.

    data mt_invoice_ids type tt_invoice_ids.

endclass.



class zcl_conc_bg_invoice_approve implementation.

  method constructor.

    mt_invoice_ids = it_invoice_ids.

  endmethod.

  method if_bgmc_op_single~execute.

    check mt_invoice_ids is not initial.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " section dedicated to:
    "   tax calculation and validations
    "   bank APIs
    "   other complex calculations
    wait up to 5 seconds.

    modify entities of ZI_conc_INVOICE
      entity Invoice
      update fields ( Status )
      with value #( for lv_id in mt_invoice_ids (
                                        InvoiceId = lv_id
                                        Status = 'A' ) )
      failed data(ls_failed)
      reported data(ls_reported).


    if ls_failed is initial.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " production environment would catch and treat errors
      return.
    endif.

  endmethod.
endclass.
