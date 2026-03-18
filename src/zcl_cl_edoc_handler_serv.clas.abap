CLASS zcl_cl_edoc_handler_serv DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .

    "Structure for one billing document
    TYPES: BEGIN OF ty_item,
             billingdocument TYPE string,
             irn             TYPE string,
             reason          TYPE string,
             remarks         TYPE string,
           END OF ty_item.

    "Table of billing documents
    TYPES: tt_item TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.

    "JSON request structure
    TYPES: BEGIN OF ty_request,
             action TYPE string,
             items  TYPE tt_item,
           END OF ty_request.

    "Data holder for parsed JSON
    DATA it_data TYPE ty_request.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_CL_EDOC_HANDLER_SERV IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    DATA: lv_body        TYPE string,
          lv_message     TYPE string,
          json           TYPE REF TO if_xco_cp_json_data,
          lv_billing_doc TYPE vbeln.

    "Read JSON request body
    lv_body = request->get_text( ).

    "Allow UI calls (CORS headers)
    response->set_header_field(
        i_name = 'Access-Control-Allow-Origin'
        i_value = '*' ).

    response->set_header_field(
        i_name = 'Access-Control-Allow-Credentials'
        i_value = 'true' ).

    "Convert JSON → ABAP structure
    json = xco_cp_json=>data->from_string( lv_body ).

    json->write_to( REF #( it_data ) ).


    CASE it_data-action.

      WHEN 'GEN_EINVOICE'.

        DATA lt_billing TYPE zcl_edoc_einvoice_payload=>tt_billing.

        LOOP AT it_data-items INTO DATA(ls_item).

          lv_billing_doc = ls_item-billingdocument.
          lv_billing_doc = |{ lv_billing_doc ALPHA = IN }|.

          APPEND lv_billing_doc TO lt_billing.

        ENDLOOP.

        IF lt_billing IS INITIAL.

          lv_message = 'No Billing Document received'.

        ELSE.

          TRY.

              lv_message =
                zcl_edoc_einvoice_payload=>create_einvoice(
                  it_billing = lt_billing ).

            CATCH cx_root INTO DATA(lx_error).

              lv_message = lx_error->get_text( ).

          ENDTRY.

        ENDIF.


      WHEN 'CANCEL_EINVOICE'. "Handle error like Eway should be cancelled first, document should be applicable for cancel

        TYPES: BEGIN OF ty_cancel,
                 billingdocument TYPE vbeln,
                 irn             TYPE string,
                 reason          TYPE string,
                 remarks         TYPE string,
               END OF ty_cancel.

        TYPES tt_cancel TYPE STANDARD TABLE OF ty_cancel WITH EMPTY KEY.

        DATA lt_cancel TYPE tt_cancel.

        LOOP AT it_data-items INTO ls_item.

          lv_billing_doc = ls_item-billingdocument.
          lv_billing_doc = |{ lv_billing_doc ALPHA = IN }|.

          DATA(ls_cancel) = VALUE ty_cancel(
              billingdocument = lv_billing_doc
              irn             = ls_item-irn
              reason          = ls_item-reason
              remarks         = ls_item-remarks ).

          APPEND ls_cancel TO lt_cancel.

        ENDLOOP.

        IF lt_cancel IS INITIAL.

          lv_message = 'No IRN received'.

        ELSE.

          TRY.

              lv_message =
                zcl_edoc_einvoice_payload=>cancel_einvoice(
                  it_cancel = lt_cancel ).

            CATCH cx_root INTO lx_error.

              lv_message = lx_error->get_text( ).

          ENDTRY.

        ENDIF.


      WHEN 'GEN_EWAY'.
*          lv_message =
*          |E-Way Bill action received for { lv_bill }|.

      WHEN 'CANCEL_EWAY'.
*          lv_message =
*          |Cancel E-Way Bill action received for { lv_bill }|.

      WHEN OTHERS.
        lv_message = 'Invalid action'.

    ENDCASE.



    "Send response back to UI
    response->set_text( lv_message ).




  ENDMETHOD.
ENDCLASS.
