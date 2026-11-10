CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.
    TYPES tt_invoice_ids TYPE STANDARD TABLE OF sysuuid_x16 WITH DEFAULT KEY.
    CLASS-DATA mt_bg_invoice_ids TYPE tt_invoice_ids.
ENDCLASS.


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Handler class
class lhc_Invoice definition inheriting from cl_abap_behavior_handler.

  private section.

    methods get_instance_features for instance features
      importing keys request requested_features for Invoice result result.

    methods get_global_authorizations for global authorization
      request requested_authorizations for Invoice result result.

    methods approveInvoice for modify
       importing keys for action Invoice~approveInvoice result result.

endclass.

class lhc_Invoice implementation.

  method get_instance_features.

    read entities of ZI_conc_INVOICE in local mode
      entity INvoice
      fields ( Status )
      with corresponding #( keys )
      result data(lt_invoices)
      failed failed.

    result = VALUE #( FOR ls_invoice IN lt_invoices (
        %tky = ls_invoice-%tky
        %action-approveInvoice = COND #(
              WHEN ls_invoice-Status = 'P'
                THEN if_abap_behv=>fc-o-enabled
                ELSE if_abap_behv=>fc-o-disabled
        )
    ) ).

  endmethod.

  method get_global_authorizations.
  endmethod.

  method approveInvoice.

    " read current data
    read entities of ZI_conc_INVOICE in local mode
      entity Invoice
      fields ( Status ) with corresponding #( keys )
      result data(lt_invoices)
      failed failed.



      DATA lt_valid_invoices TYPE lcl_buffer=>tt_invoice_ids.

      loop at lt_invoices into data(ls_invoice) where Status = 'P'.
        append ls_invoice-InvoiceId to lt_valid_invoices.
      endloop.

      check lt_valid_invoices is not initial.

      APPEND LINES OF lt_valid_invoices TO lcl_buffer=>mt_bg_invoice_ids.


      DATA(lv_count) = lines( lt_valid_invoices ).
        APPEND new_message_with_text(
                       severity = if_abap_behv_message=>severity-success
                       text     = |Batch process of { lv_count } invoices scheduled in background.|
                   ) TO reported-%other.

        result = VALUE #( FOR ls_inv IN lt_invoices (
          %tky   = ls_inv-%tky
          %param = ls_inv
        ) ).

  endmethod.

endclass.

CLASS lsc_Invoice DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_Invoice IMPLEMENTATION.

  method save_modified.

    CHECK lcl_buffer=>mt_bg_invoice_ids IS NOT INITIAL.

    try.
      " background process framework - asynchronous
      " worker instance:
      data(lo_bg_operation) = new zcl_conc_bg_invoice_approve(
          it_invoice_ids = lcl_buffer=>mt_bg_invoice_ids ).

      data(lo_bg_process) = cl_bgmc_process_factory=>get_default( )->create( ).
      lo_bg_process->set_name( 'Mass_Invoice_Approval_Job' ).
      lo_bg_process->set_operation( lo_bg_operation ).
      lo_bg_process->save_for_execution( ).
    catch cx_bgmc into data(lx_bgmc).
      APPEND new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = lx_bgmc->get_text( ) ) TO reported-%other.
    endtry.

  endmethod.

endclass.
