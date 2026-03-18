CLASS zcl_edoc_einvoice_payload DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_vbeln,
             vbeln TYPE vbeln,
           END OF ty_vbeln.

    TYPES tt_billing TYPE STANDARD TABLE OF ty_vbeln WITH EMPTY KEY.

    CLASS-METHODS create_einvoice
      IMPORTING it_billing        TYPE tt_billing
      RETURNING VALUE(rv_message) TYPE string.

    TYPES: BEGIN OF ty_cancel,
             billingdocument TYPE vbeln,
             irn             TYPE string,
             reason          TYPE string,
             remarks         TYPE string,
           END OF ty_cancel.

    TYPES tt_cancel TYPE STANDARD TABLE OF ty_cancel WITH EMPTY KEY.

    CLASS-METHODS cancel_einvoice
      IMPORTING it_cancel         TYPE tt_cancel
      RETURNING VALUE(rv_message) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-METHODS post_api
      IMPORTING iv_json            TYPE string
                iv_action          TYPE string
      RETURNING VALUE(rv_response) TYPE string.

    CLASS-METHODS update_einvoice_table
      IMPORTING
                iv_response       TYPE string
                iv_action         TYPE string
                it_cancel         TYPE tt_cancel OPTIONAL
      RETURNING VALUE(rv_message) TYPE string.

    CLASS-METHODS format_date
      IMPORTING iv_date        TYPE d
      RETURNING VALUE(rv_date) TYPE string.

    TYPES: ty_amount TYPE p LENGTH 16 DECIMALS 2.

    CLASS-METHODS round_amount
      IMPORTING iv_value        TYPE ty_amount
      RETURNING VALUE(rv_value) TYPE ty_amount.

    CLASS-METHODS get_gst_state_code
      IMPORTING iv_region       TYPE land1
      RETURNING VALUE(rv_state) TYPE string.

    CLASS-METHODS fix_json_keys
      CHANGING cv_json TYPE string.

ENDCLASS.



CLASS zcl_edoc_einvoice_payload IMPLEMENTATION.


  METHOD create_einvoice.

    DATA json TYPE REF TO if_xco_cp_json_data.
    DATA lv_payload TYPE string.
    DATA lv_response TYPE string.

    TYPES: BEGIN OF ty_item,
             slno               TYPE string,
             isservc            TYPE string,
             prddesc            TYPE string,
             hsncd              TYPE string,
             qty                TYPE string,
             unit               TYPE string,
             unitprice          TYPE p LENGTH 16 DECIMALS 2,
             totamt             TYPE p LENGTH 16 DECIMALS 2,
             discount           TYPE p LENGTH 16 DECIMALS 2,
             assamt             TYPE p LENGTH 16 DECIMALS 2,
             gstrt              TYPE p LENGTH 5 DECIMALS 2,
             sgstamt            TYPE p LENGTH 16 DECIMALS 2,
             igstamt            TYPE p LENGTH 16 DECIMALS 2,
             cgstamt            TYPE p LENGTH 16 DECIMALS 2,
             cesrt              TYPE p LENGTH 5 DECIMALS 2,
             cesamt             TYPE p LENGTH 16 DECIMALS 2,
             cesnonadvlamt      TYPE p LENGTH 16 DECIMALS 2,
             statecesrt         TYPE p LENGTH 5 DECIMALS 2,
             statecesamt        TYPE p LENGTH 16 DECIMALS 2,
             statecesnonadvlamt TYPE p LENGTH 16 DECIMALS 2,
             othchrg            TYPE p LENGTH 16 DECIMALS 2,
             totitemval         TYPE p LENGTH 16 DECIMALS 2,
             bchdtls            TYPE string,
             attribdtls         TYPE string,
           END OF ty_item.

    TYPES tt_item TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.

    TYPES: BEGIN OF ty_invoice,

             custdocno   TYPE string,

             BEGIN OF trandtls,
               suptyp TYPE string,
             END OF trandtls,

             BEGIN OF docdtls,
               typ TYPE string,
               no  TYPE string,
               dt  TYPE string,
             END OF docdtls,

             BEGIN OF sellerdtls,
               gstin TYPE string,
               lglnm TYPE string,
               trdnm TYPE string,
               addr1 TYPE string,
               addr2 TYPE string,
               loc   TYPE string,
               pin   TYPE string,
               stcd  TYPE string,
               ph    TYPE string,
               em    TYPE string,
             END OF sellerdtls,

             BEGIN OF buyerdtls,
               gstin TYPE string,
               lglnm TYPE string,
               trdnm TYPE string,
               pos   TYPE string,
               addr1 TYPE string,
               addr2 TYPE string,
               loc   TYPE string,
               pin   TYPE string,
               stcd  TYPE string,
               ph    TYPE string,
               em    TYPE string,
             END OF buyerdtls,

             BEGIN OF dispdtls,
               nm    TYPE string,
               addr1 TYPE string,
               addr2 TYPE string,
               loc   TYPE string,
               pin   TYPE string,
               stcd  TYPE string,
             END OF dispdtls,

             BEGIN OF shipdtls,
               gstin TYPE string,
               lglnm TYPE string,
               trdnm TYPE string,
               addr1 TYPE string,
               addr2 TYPE string,
               loc   TYPE string,
               pin   TYPE string,
               stcd  TYPE string,
             END OF shipdtls,

             itemlist    TYPE tt_item,

             paydtls     TYPE string,
             refdtls     TYPE string,
             addldocdtls TYPE string,
             expdtls     TYPE string,
             ewbdtls     TYPE string,

             BEGIN OF valdtls,
               assval    TYPE p LENGTH 16 DECIMALS 2,
               cgstval   TYPE p LENGTH 16 DECIMALS 2,
               sgstval   TYPE p LENGTH 16 DECIMALS 2,
               igstval   TYPE p LENGTH 16 DECIMALS 2,
               cesval    TYPE p LENGTH 16 DECIMALS 2,
               stcesval  TYPE p LENGTH 16 DECIMALS 2,
               discount  TYPE p LENGTH 16 DECIMALS 2,
               othchrg   TYPE p LENGTH 16 DECIMALS 2,
               rndoffamt TYPE p LENGTH 16 DECIMALS 2,
               totinvval TYPE p LENGTH 16 DECIMALS 2,
             END OF valdtls,

           END OF ty_invoice.

    TYPES tt_invoice TYPE STANDARD TABLE OF ty_invoice WITH EMPTY KEY.

    DATA lt_invoice TYPE tt_invoice.

*-- Read all required data first

    IF it_billing IS INITIAL.
      RETURN.
    ENDIF.

    SELECT *
    FROM zi_einv_header
    FOR ALL ENTRIES IN @it_billing
    WHERE billingdocument = @it_billing-vbeln
    INTO TABLE @DATA(lt_header).

    SELECT *
    FROM zi_einv_item
    FOR ALL ENTRIES IN @it_billing
    WHERE billingdocument = @it_billing-vbeln
    INTO TABLE @DATA(lt_item).

    SELECT *
    FROM zi_einv_pricing
    FOR ALL ENTRIES IN @it_billing
    WHERE billingdocument = @it_billing-vbeln
    INTO TABLE @DATA(lt_pricing).

    SELECT *
    FROM zi_einv_partner
    FOR ALL ENTRIES IN @it_billing
    WHERE billingdocument = @it_billing-vbeln
    INTO TABLE @DATA(lt_partner).

    SELECT *
    FROM zi_einv_plant_address
    FOR ALL ENTRIES IN @it_billing
    WHERE billingdocument = @it_billing-vbeln
    INTO TABLE @DATA(lt_plant).

    SELECT *
    FROM zi_einv_gst
    INTO TABLE @DATA(lt_gst).

    SORT lt_header  BY billingdocument.
    SORT lt_item    BY billingdocument billingdocumentitem.
    SORT lt_pricing BY billingdocument billingdocumentitem conditiontype.
    SORT lt_partner BY billingdocument.
    SORT lt_plant   BY billingdocument.
    SORT lt_gst     BY businessplace.

*-- Billing Header

    LOOP AT lt_header INTO DATA(ls_head).

      DATA(ls_invoice) = VALUE ty_invoice( ).
      CLEAR ls_invoice-valdtls.

* Header Mapping
      ls_invoice-custdocno = ls_head-documentreferenceid.
      ls_invoice-trandtls-suptyp = 'B2B'.

* Invoice Type Logic
      CASE ls_head-sddocumentcategory.
        WHEN 'M'.
          ls_invoice-docdtls-typ = 'INV'.
        WHEN 'F2'.
          ls_invoice-docdtls-typ = 'INV'.
        WHEN 'O'.
          ls_invoice-docdtls-typ = 'CRN'.
        WHEN 'P'.
          ls_invoice-docdtls-typ = 'DBN'.
        WHEN 'U'.
          ls_invoice-docdtls-typ = 'PINV'.
      ENDCASE.

* DD/MM/YYYY
      ls_invoice-docdtls-dt =
        format_date( ls_head-billingdocumentdate ).

      ls_invoice-docdtls-no = ls_head-documentreferenceid.

      DATA lv_business_place TYPE zi_einv_plant_address-businessplace.

      READ TABLE lt_plant INTO DATA(ls_plant_addr)
        WITH KEY billingdocument = ls_head-billingdocument
        BINARY SEARCH.

      IF sy-subrc = 0.
        lv_business_place = ls_plant_addr-businessplace.
      ENDIF.

* Seller Mapping
      IF lv_business_place IS NOT INITIAL.

        READ TABLE lt_gst INTO DATA(ls_gst)
          WITH KEY businessplace = lv_business_place
          BINARY SEARCH.

        IF sy-subrc = 0.

          ls_invoice-sellerdtls-gstin = ls_gst-gstin.
          ls_invoice-sellerdtls-lglnm = ls_gst-organizationname1.
          ls_invoice-sellerdtls-trdnm = ls_gst-organizationname1.
          ls_invoice-sellerdtls-addr1 = ls_gst-streetname.
          ls_invoice-sellerdtls-loc   = ls_gst-cityname.
          ls_invoice-sellerdtls-pin   = ls_gst-postalcode.
          ls_invoice-sellerdtls-stcd  = get_gst_state_code( ls_gst-region ).

        ENDIF.

      ENDIF.

* Buyer Mapping
      ls_invoice-buyerdtls-gstin = ls_head-buyergstin.

      ls_invoice-buyerdtls-lglnm =
      |{ ls_head-buyername1 } { ls_head-buyername2 }|.

      ls_invoice-buyerdtls-trdnm = ls_invoice-buyerdtls-lglnm.

      ls_invoice-buyerdtls-addr1 = ls_head-buyerstreet.
      ls_invoice-buyerdtls-loc   = ls_head-buyercity.
      ls_invoice-buyerdtls-pin   = ls_head-buyerpostalcode.
      ls_invoice-buyerdtls-stcd  = get_gst_state_code( ls_head-buyerregion ).
      ls_invoice-buyerdtls-pos   = get_gst_state_code( ls_head-buyerregion ).


* Dispatch Address
      IF lv_business_place IS NOT INITIAL.

        ls_invoice-dispdtls-nm    = ls_plant_addr-dispatchname.
        ls_invoice-dispdtls-addr1 = ls_plant_addr-addr1.
        ls_invoice-dispdtls-loc   = ls_plant_addr-city.
        ls_invoice-dispdtls-pin   = ls_plant_addr-postalcode.
        ls_invoice-dispdtls-stcd  = get_gst_state_code( ls_plant_addr-statecode ).

      ENDIF.

* Ship To Mapping
      READ TABLE lt_partner INTO DATA(ls_ship)
        WITH KEY billingdocument = ls_head-billingdocument
        BINARY SEARCH.

      IF sy-subrc = 0.

        ls_invoice-shipdtls-gstin = ls_ship-shiptogstin.

        ls_invoice-shipdtls-lglnm =
        |{ ls_ship-shiptoname1 } { ls_ship-shiptoname2 }|.

        ls_invoice-shipdtls-trdnm = ls_invoice-shipdtls-lglnm.

        ls_invoice-shipdtls-addr1 = ls_ship-shiptostreet.
        ls_invoice-shipdtls-loc   = ls_ship-shiptocity.
        ls_invoice-shipdtls-pin   = ls_ship-shiptopostalcode.
        ls_invoice-shipdtls-stcd  = get_gst_state_code( ls_ship-shiptoregion ).

      ENDIF.

* Item Loop
      LOOP AT lt_item INTO DATA(ls_item)
      WHERE billingdocument = ls_head-billingdocument.

        DATA(lv_unit) =
          SWITCH string( ls_item-billingquantityunit
            WHEN 'ST'  THEN 'PCS'
            WHEN 'PC'  THEN 'PCS'
            WHEN 'NOS' THEN 'NOS'
            WHEN 'KG'  THEN 'KGS'
            WHEN 'KGS' THEN 'KGS'
            WHEN 'M'   THEN 'MTR'
            WHEN 'MTR' THEN 'MTR'
            WHEN 'L'   THEN 'LTR'
            WHEN 'LTR' THEN 'LTR'
            WHEN 'EA'  THEN 'UNT'
            ELSE 'OTH'
          ).

        DATA(ls_item_json) = VALUE ty_item(
          slno    = ls_item-billingdocumentitem
          isservc = SWITCH #( ls_head-division
                                   WHEN 'SR' THEN 'Y'
                                   ELSE 'N' )
          prddesc = ls_item-billingdocumentitemtext
          hsncd   = ls_item-hsncode
          qty     = ls_item-billingquantity
          unit    = lv_unit
          assamt  = round_amount( CONV ty_amount( ls_item-netamount ) ) "Net Amount
        ).

* Pricing mapping
        READ TABLE lt_pricing INTO DATA(ls_price)
         WITH KEY billingdocument     = ls_item-billingdocument
                  billingdocumentitem = ls_item-billingdocumentitem
         BINARY SEARCH.

        IF sy-subrc = 0.

          DATA(lv_index) = sy-tabix.

          LOOP AT lt_pricing INTO ls_price FROM lv_index.

            IF ls_price-billingdocument <> ls_item-billingdocument
            OR ls_price-billingdocumentitem <> ls_item-billingdocumentitem.
              EXIT.
            ENDIF.

            CASE ls_price-conditiontype.

              WHEN 'ZPR0' OR 'ZHSS' OR 'ZPB1' OR 'ZCER' OR 'ZRNT' OR 'ZPR1' OR 'ZADC'. "Pass Unit Price/Base Price Condition Type here

                ls_item_json-unitprice = round_amount( CONV ty_amount( ls_price-conditionrateamount ) ).
                ls_item_json-totamt    = round_amount( CONV ty_amount( ls_price-conditionamount ) ).

              WHEN 'JOIG'.  " IGST
                ls_item_json-igstamt =
                  round_amount( CONV ty_amount( ls_price-conditionamount ) ).

                ls_item_json-gstrt =
                  ls_price-conditionrateratio.

              WHEN 'JOCG'. "CGST
                ls_item_json-cgstamt =
                  round_amount( CONV ty_amount( ls_price-conditionamount ) ).

                ls_item_json-gstrt =
                  ls_price-conditionrateratio.

              WHEN 'JOSG' OR 'JOUG'. "SGST
                ls_item_json-sgstamt =
                  round_amount( CONV ty_amount( ls_price-conditionamount ) ).

                ls_item_json-gstrt =
                  ls_price-conditionrateratio.

              WHEN 'JTC1' OR 'JTC2'.  "Pass other changes condition type here
                ls_item_json-othchrg =
                  round_amount( CONV ty_amount( ls_price-conditionamount ) ).

            ENDCASE.

          ENDLOOP.

        ENDIF.

* TotItemVal formula from API sheet
        ls_item_json-totitemval =
              ls_item_json-assamt
            + ls_item_json-cgstamt
            + ls_item_json-sgstamt
            + ls_item_json-igstamt
            + ls_item_json-cesamt
            + ls_item_json-statecesamt
            + ls_item_json-othchrg.

        APPEND ls_item_json TO ls_invoice-itemlist.

      ENDLOOP.

* Invoice totals
      LOOP AT ls_invoice-itemlist INTO DATA(ls_it).

        ls_invoice-valdtls-assval  += ls_it-assamt.
        ls_invoice-valdtls-cgstval += ls_it-cgstamt.
        ls_invoice-valdtls-sgstval += ls_it-sgstamt.
        ls_invoice-valdtls-igstval += ls_it-igstamt.
        ls_invoice-valdtls-othchrg += ls_it-othchrg.

      ENDLOOP.

* TotInvVal calculation
      ls_invoice-valdtls-totinvval =
            ls_invoice-valdtls-assval
          + ls_invoice-valdtls-cgstval
          + ls_invoice-valdtls-sgstval
          + ls_invoice-valdtls-igstval
          + ls_invoice-valdtls-othchrg
          + ls_invoice-valdtls-rndoffamt
          - ls_invoice-valdtls-discount.

      APPEND ls_invoice TO lt_invoice.

    ENDLOOP.

    TYPES: BEGIN OF ty_root,
             invoices TYPE tt_invoice,
           END OF ty_root.

    DATA(ls_root) = VALUE ty_root(
                      invoices = lt_invoice ).

    xco_cp_json=>data->from_abap(
      EXPORTING ia_abap = ls_root
      RECEIVING ro_json_data = json ).

    json->to_string(
    RECEIVING rv_string = lv_payload ).

    fix_json_keys(
      CHANGING cv_json = lv_payload ).

* Post API
    lv_response =
      post_api(
        iv_json   = lv_payload
        iv_action = 'GEN_EINVOICE' ).

* Update Table
    rv_message = update_einvoice_table(
                   iv_response = lv_response
                   iv_action   = 'GEN_EINVOICE'
                 ).

  ENDMETHOD.


  METHOD post_api.

    DATA: client   TYPE REF TO if_web_http_client,
          dest     TYPE REF TO if_http_destination,
          response TYPE REF TO if_web_http_response,
          lv_url   TYPE string,
          lv_key   TYPE string.

    "URL and KEY based on system

    IF sy-sysid = 'F0C'. "DEV

      CASE iv_action.
        WHEN 'GEN_EINVOICE'.
          lv_url =
          'https://timetechnoplast.supertaxuat.in/api/integration/einvoices/v1.01/sales/save'.

        WHEN 'CANCEL_EINVOICE'.
          lv_url =
          'https://timetechnoplast.supertaxuat.in/api/integration/einvoices/v1.01/sales/cancel'.

        WHEN 'GEN_EWAY'.
          lv_url =
          'https://yoursubdomain.supertaxuat.in/api/integration/ewaybill/v1.01/generate'.

        WHEN 'CANCEL_EWAY'.
          lv_url =
          'https://yoursubdomain.supertaxuat.in/api/integration/ewaybill/v1.01/cancel'.

      ENDCASE.

      lv_key = 'avhNgUWHGSnD3rsLWWB9WmBMCzhvMqic0w_rk77-3pYfsnIlhghodpGKFSf09z7z'.

    ELSE. "PRD system

      lv_url = 'XXXXXXXXXXXXXXXX'.
      lv_key = 'XXXXXXXXXXXXXXXXXXXXXX'.

    ENDIF.

    "Create HTTP client

    dest = cl_http_destination_provider=>create_by_url( lv_url ).

    client = cl_web_http_client_manager=>create_by_http_destination( dest ).

    "Prepare Request

    DATA(req) = client->get_http_request( ).

    req->set_header_field(
      i_name  = 'key'
      i_value = lv_key ).

    req->set_content_type( 'application/json' ).

    req->set_text( iv_json ).

    "Execute API

    TRY.
        response = client->execute( if_web_http_client=>post ).
        rv_response = response->get_text( ).
      CATCH cx_web_http_client_error cx_web_message_error INTO DATA(lx_error).
        rv_response = lx_error->get_text( ).
    ENDTRY.

    "Close client

    TRY.
        client->close( ).
      CATCH cx_web_http_client_error.
    ENDTRY.

  ENDMETHOD.


  METHOD update_einvoice_table.

    TYPES: BEGIN OF ty_cancel,
             billingdocument TYPE vbeln,
             irn             TYPE string,
             reason          TYPE string,
             remarks         TYPE string,
           END OF ty_cancel.

    TYPES tt_cancel TYPE STANDARD TABLE OF ty_cancel WITH EMPTY KEY.


* Response structures
    TYPES: BEGIN OF ty_doc,
             no  TYPE string,
             dt  TYPE string,
             typ TYPE string,
           END OF ty_doc.

    TYPES: BEGIN OF ty_seller,
             gstin TYPE string,
           END OF ty_seller.

    TYPES: BEGIN OF ty_invoice,
             ackno         TYPE string,
             ackdate       TYPE string,
             record        TYPE string,
             success       TYPE abap_bool,
             fy            TYPE string,
             messages      TYPE string,
             status        TYPE string,
             irn           TYPE string,
             custdocno     TYPE string,
             signedinvoice TYPE string,
             signedqrcode  TYPE string,
             qrcode        TYPE string,
             ewbno         TYPE string,
             docdtls       TYPE ty_doc,
             sellerdtls    TYPE ty_seller,
           END OF ty_invoice.

    TYPES: BEGIN OF ty_root,
             invoices TYPE STANDARD TABLE OF ty_invoice WITH EMPTY KEY,
           END OF ty_root.

    DATA ls_root TYPE ty_root.

* Deserialize JSON

    TRY.

        /ui2/cl_json=>deserialize(
          EXPORTING json = iv_response
          CHANGING  data = ls_root ).

      CATCH cx_root INTO DATA(lx_json).

        rv_message = lx_json->get_text( ).
        RETURN.

    ENDTRY.

* Counters
    DATA lv_success TYPE i VALUE 0.
    DATA lv_failed  TYPE i VALUE 0.

    DATA:lv_success_docs TYPE string,
         lv_failure_docs TYPE string,
         lv_error_msg    TYPE string.


* Process response
    LOOP AT ls_root-invoices INTO DATA(ls_inv).

      DATA: lv_date TYPE datum,
            lv_time TYPE uzeit.

* Convert AckDate
* Format received: YYYY-MM-DD HH:MM:SS
      IF ls_inv-ackdate IS NOT INITIAL.

        SPLIT ls_inv-ackdate
        AT space
        INTO DATA(lv_d)
             DATA(lv_t).

        REPLACE ALL OCCURRENCES OF '-' IN lv_d WITH ''.

        lv_date = lv_d.
        lv_time = lv_t.

      ENDIF.

** Read existing record
      DATA ls_edoc TYPE zedocinvoice.

      CASE iv_action.

* GENERATE E-INVOICE
        WHEN 'GEN_EINVOICE'.

* Store error message always
          ls_edoc-errormessage = ls_inv-messages.

          IF ls_inv-success = abap_true.

            ls_edoc-invrefnumber = ls_inv-irn.
            ls_edoc-ackno        = ls_inv-ackno.
            ls_edoc-ackdate      = lv_date.
            ls_edoc-acktime      = lv_time.

            ls_edoc-signedinvoice = ls_inv-signedinvoice.
            ls_edoc-signedqrcode  = ls_inv-signedqrcode.
            ls_edoc-qrcode        = ls_inv-qrcode.

            ls_edoc-edocstatus        = 'EINVOICE_GENERATED'.
            ls_edoc-edocoverallstatus = 'COMPLETED'.

            lv_success = lv_success + 1.
            lv_success_docs = |{ lv_success_docs } , { ls_inv-custdocno }|.

          ELSE.

            ls_edoc-edocstatus        = 'EINVOICE_FAILED'.
            ls_edoc-edocoverallstatus = 'FAILED'.

            lv_failed = lv_failed + 1.
            lv_failure_docs = |{ lv_failure_docs } , { ls_inv-custdocno }|.
            lv_error_msg = |{ lv_error_msg } , { ls_inv-messages }|.

          ENDIF.

          SELECT SINGLE companycode,
                        documentreferenceid,
                        billingdocument
            FROM i_billingdocument
            WHERE documentreferenceid = @ls_inv-custdocno
            INTO @DATA(ls_billing_det).

          IF sy-subrc = 0.
            ls_edoc-client          = sy-mandt.
            ls_edoc-odndocument = ls_inv-custdocno.
            ls_edoc-edocsourcetype = 'SD_INVOICE'.
            ls_edoc-compcode = ls_billing_det-companycode.
            ls_edoc-documentnumber = ls_inv-custdocno.
            ls_edoc-billingdocument = ls_billing_det-billingdocument.

* Update record
            MODIFY zedocinvoice FROM @ls_edoc.

            IF sy-subrc <> 0.
              DATA: lv_text TYPE string.
              lv_text = lv_text && 'Update failed for - ' && ls_inv-custdocno.
            ENDIF.

          ENDIF.


* CANCEL E-INVOICE
        WHEN 'CANCEL_EINVOICE'.

          IF ls_inv-success = abap_true.

            DATA lv_reason TYPE string.
            DATA lv_remark TYPE string.

            DATA(ls_cancel) = VALUE ty_cancel( ).

            READ TABLE it_cancel INTO ls_cancel
                 WITH KEY irn = ls_inv-irn.

            IF sy-subrc = 0.
              lv_reason = ls_cancel-reason.
              lv_remark  = ls_cancel-remarks.
            ENDIF.

            DATA(lv_cancel_date) = cl_abap_context_info=>get_system_date( ).
            DATA(lv_cancel_time) = cl_abap_context_info=>get_system_time( ).

            UPDATE zedocinvoice
            SET
              errormessage      = @ls_inv-messages,
              einvcancreasoncode = @lv_reason,
              einvcancelremarks  = @lv_remark,
              einvcanceldate     = @lv_cancel_date,
              einvcanceltime     = @lv_cancel_time,
              edocstatus         = 'EINVOICE_CANCELLED',
              edocoverallstatus  = 'CANCELLED'
            WHERE invrefnumber = @ls_inv-irn.

            lv_success = lv_success + 1.

          ELSE.

            UPDATE zedocinvoice
            SET
              errormessage      = @ls_inv-messages,
              edocstatus         = 'CANCEL_EINVOICE_FAILED',
              edocoverallstatus  = 'FAILED'
            WHERE invrefnumber = @ls_inv-irn.

            lv_failed = lv_failed + 1.

          ENDIF.



* E-Way Bill
        WHEN 'GEN_EWAY'.

* CANCEL E-Way Bill
        WHEN 'CANCEL_EWAY'.

      ENDCASE.

      CLEAR ls_edoc.

    ENDLOOP.

    COMMIT WORK.

    CONDENSE: lv_success_docs,
              lv_failure_docs,
              lv_error_msg.

    SHIFT: lv_success_docs,
           lv_failure_docs,
           lv_error_msg
           LEFT DELETING LEADING space.

    SHIFT: lv_success_docs,
           lv_failure_docs,
           lv_error_msg
           LEFT DELETING LEADING ','.

    CONDENSE: lv_success_docs,
              lv_failure_docs,
              lv_error_msg.

* Return message
    rv_message =
    |Success: { lv_success } Success Docs: { lv_success_docs } Failed: { lv_failed } Failed Docs: { lv_failure_docs } Error Message: { lv_error_msg }|.

  ENDMETHOD.


  METHOD format_date.

    rv_date = |{ iv_date+6(2) }/{ iv_date+4(2) }/{ iv_date(4) }|.

  ENDMETHOD.


  METHOD round_amount.

    rv_value = round(
                 val  = iv_value
                 dec  = 2
                 mode = cl_abap_math=>round_half_up ).

  ENDMETHOD.


  METHOD get_gst_state_code.

    rv_state =
      SWITCH string( iv_region
        WHEN 'AN' THEN '35'
        WHEN 'AP' THEN '37'
        WHEN 'AR' THEN '12'
        WHEN 'AS' THEN '18'
        WHEN 'BR' THEN '10'
        WHEN 'CH' THEN '04'
        WHEN 'CT' THEN '22'
        WHEN 'DD' THEN '25'
        WHEN 'DL' THEN '07'
        WHEN 'GA' THEN '30'
        WHEN 'GJ' THEN '24'
        WHEN 'HP' THEN '02'
        WHEN 'HR' THEN '06'
        WHEN 'JH' THEN '20'
        WHEN 'JK' THEN '01'
        WHEN 'KA' THEN '29'
        WHEN 'KL' THEN '32'
        WHEN 'LA' THEN '38'
        WHEN 'LD' THEN '31'
        WHEN 'MH' THEN '27'
        WHEN 'ML' THEN '17'
        WHEN 'MN' THEN '14'
        WHEN 'MP' THEN '23'
        WHEN 'MZ' THEN '15'
        WHEN 'NL' THEN '13'
        WHEN 'OR' THEN '21'
        WHEN 'PB' THEN '03'
        WHEN 'PY' THEN '34'
        WHEN 'RJ' THEN '08'
        WHEN 'SK' THEN '11'
        WHEN 'TG' THEN '36'
        WHEN 'TN' THEN '33'
        WHEN 'TR' THEN '16'
        WHEN 'UK' THEN '05'
        WHEN 'UP' THEN '09'
        WHEN 'WB' THEN '19'
        ELSE '' ).

  ENDMETHOD.


  METHOD cancel_einvoice.

    DATA json TYPE REF TO if_xco_cp_json_data.
    DATA lv_payload TYPE string.
    DATA lv_response TYPE string.

* JSON structures

    TYPES: BEGIN OF ty_invoice,
             irn    TYPE string,
             cnlrsn TYPE string,
             cnlrem TYPE string,
           END OF ty_invoice.

    TYPES tt_invoice TYPE STANDARD TABLE OF ty_invoice WITH EMPTY KEY.

    TYPES: BEGIN OF ty_root,
             invoices TYPE tt_invoice,
           END OF ty_root.

    DATA lt_invoice TYPE tt_invoice.

* Build cancel payload

    LOOP AT it_cancel INTO DATA(ls_cancel).

      APPEND VALUE ty_invoice(
        irn    = ls_cancel-irn
        cnlrsn = ls_cancel-reason
        cnlrem = ls_cancel-remarks ) TO lt_invoice.

    ENDLOOP.

    DATA(ls_root) = VALUE ty_root(
                      invoices = lt_invoice ).

    xco_cp_json=>data->from_abap(
      EXPORTING ia_abap = ls_root
      RECEIVING ro_json_data = json ).

    json->to_string(
      RECEIVING rv_string = lv_payload ).

    fix_json_keys(
      CHANGING cv_json = lv_payload ).

* Call API
    lv_response =
      post_api(
        iv_json   = lv_payload
        iv_action = 'CANCEL_EINVOICE' ).

* Update cancel status table
    rv_message = update_einvoice_table(
                   iv_response = lv_response
                   iv_action   = 'CANCEL_EINVOICE'
                   it_cancel   = it_cancel ).

  ENDMETHOD.


  METHOD fix_json_keys.

* Root
    REPLACE ALL OCCURRENCES OF '"INVOICES"' IN cv_json WITH '"invoices"'.
    REPLACE ALL OCCURRENCES OF '"EWAYBILLS"' IN cv_json WITH '"ewaybills"'.

* E-INVOICE GENERATE
    REPLACE ALL OCCURRENCES OF '"CUSTDOCNO"' IN cv_json WITH '"CustDocNo"'.

    REPLACE ALL OCCURRENCES OF '"TRANDTLS"' IN cv_json WITH '"TranDtls"'.
    REPLACE ALL OCCURRENCES OF '"SUPTYP"'   IN cv_json WITH '"SupTyp"'.

    REPLACE ALL OCCURRENCES OF '"DOCDTLS"' IN cv_json WITH '"DocDtls"'.
    REPLACE ALL OCCURRENCES OF '"TYP"'     IN cv_json WITH '"Typ"'.
    REPLACE ALL OCCURRENCES OF '"NO"'      IN cv_json WITH '"No"'.
    REPLACE ALL OCCURRENCES OF '"DT"'      IN cv_json WITH '"Dt"'.

* SELLER
    REPLACE ALL OCCURRENCES OF '"SELLERDTLS"' IN cv_json WITH '"SellerDtls"'.
    REPLACE ALL OCCURRENCES OF '"GSTIN"' IN cv_json WITH '"Gstin"'.
    REPLACE ALL OCCURRENCES OF '"LGLNM"' IN cv_json WITH '"LglNm"'.
    REPLACE ALL OCCURRENCES OF '"TRDNM"' IN cv_json WITH '"TrdNm"'.
    REPLACE ALL OCCURRENCES OF '"ADDR1"' IN cv_json WITH '"Addr1"'.
    REPLACE ALL OCCURRENCES OF '"ADDR2"' IN cv_json WITH '"Addr2"'.
    REPLACE ALL OCCURRENCES OF '"LOC"'   IN cv_json WITH '"Loc"'.
    REPLACE ALL OCCURRENCES OF '"PIN"'   IN cv_json WITH '"Pin"'.
    REPLACE ALL OCCURRENCES OF '"STCD"'  IN cv_json WITH '"Stcd"'.
    REPLACE ALL OCCURRENCES OF '"PH"'    IN cv_json WITH '"Ph"'.
    REPLACE ALL OCCURRENCES OF '"EM"'    IN cv_json WITH '"Em"'.

* BUYER
    REPLACE ALL OCCURRENCES OF '"BUYERDTLS"' IN cv_json WITH '"BuyerDtls"'.
    REPLACE ALL OCCURRENCES OF '"POS"'       IN cv_json WITH '"Pos"'.

* DISPATCH / SHIP
    REPLACE ALL OCCURRENCES OF '"DISPDTLS"' IN cv_json WITH '"DispDtls"'.
    REPLACE ALL OCCURRENCES OF '"NM"'       IN cv_json WITH '"Nm"'.

    REPLACE ALL OCCURRENCES OF '"SHIPDTLS"' IN cv_json WITH '"ShipDtls"'.

* ITEMS
    REPLACE ALL OCCURRENCES OF '"ITEMLIST"' IN cv_json WITH '"ItemList"'.
    REPLACE ALL OCCURRENCES OF '"SLNO"'     IN cv_json WITH '"SlNo"'.
    REPLACE ALL OCCURRENCES OF '"ISSERVC"'  IN cv_json WITH '"IsServc"'.
    REPLACE ALL OCCURRENCES OF '"PRDDESC"'  IN cv_json WITH '"PrdDesc"'.
    REPLACE ALL OCCURRENCES OF '"HSNCD"'    IN cv_json WITH '"HsnCd"'.
    REPLACE ALL OCCURRENCES OF '"QTY"'      IN cv_json WITH '"Qty"'.
    REPLACE ALL OCCURRENCES OF '"UNIT"'     IN cv_json WITH '"Unit"'.

    REPLACE ALL OCCURRENCES OF '"UNITPRICE"' IN cv_json WITH '"UnitPrice"'.
    REPLACE ALL OCCURRENCES OF '"TOTAMT"'    IN cv_json WITH '"TotAmt"'.
    REPLACE ALL OCCURRENCES OF '"DISCOUNT"'  IN cv_json WITH '"Discount"'.
    REPLACE ALL OCCURRENCES OF '"ASSAMT"'    IN cv_json WITH '"AssAmt"'.

    REPLACE ALL OCCURRENCES OF '"GSTRT"'  IN cv_json WITH '"GstRt"'.
    REPLACE ALL OCCURRENCES OF '"SGSTAMT"' IN cv_json WITH '"SgstAmt"'.
    REPLACE ALL OCCURRENCES OF '"IGSTAMT"' IN cv_json WITH '"IgstAmt"'.
    REPLACE ALL OCCURRENCES OF '"CGSTAMT"' IN cv_json WITH '"CgstAmt"'.

    REPLACE ALL OCCURRENCES OF '"CESRT"' IN cv_json WITH '"CesRt"'.
    REPLACE ALL OCCURRENCES OF '"CESAMT"' IN cv_json WITH '"CesAmt"'.
    REPLACE ALL OCCURRENCES OF '"CESNONADVLAMT"' IN cv_json WITH '"CesNonAdvlAmt"'.

    REPLACE ALL OCCURRENCES OF '"STATECESRT"' IN cv_json WITH '"StateCesRt"'.
    REPLACE ALL OCCURRENCES OF '"STATECESAMT"' IN cv_json WITH '"StateCesAmt"'.
    REPLACE ALL OCCURRENCES OF '"STATECESNONADVLAMT"' IN cv_json WITH '"StateCesNonAdvlAmt"'.

    REPLACE ALL OCCURRENCES OF '"OTHCHRG"' IN cv_json WITH '"OthChrg"'.
    REPLACE ALL OCCURRENCES OF '"TOTITEMVAL"' IN cv_json WITH '"TotItemVal"'.

    REPLACE ALL OCCURRENCES OF '"BCHDTLS"' IN cv_json WITH '"BchDtls"'.
    REPLACE ALL OCCURRENCES OF '"ATTRIBDTLS"' IN cv_json WITH '"AttribDtls"'.

* VALUE TOTALS
    REPLACE ALL OCCURRENCES OF '"VALDTLS"' IN cv_json WITH '"ValDtls"'.

    REPLACE ALL OCCURRENCES OF '"ASSVAL"' IN cv_json WITH '"AssVal"'.
    REPLACE ALL OCCURRENCES OF '"CGSTVAL"' IN cv_json WITH '"CgstVal"'.
    REPLACE ALL OCCURRENCES OF '"SGSTVAL"' IN cv_json WITH '"SgstVal"'.
    REPLACE ALL OCCURRENCES OF '"IGSTVAL"' IN cv_json WITH '"IgstVal"'.

    REPLACE ALL OCCURRENCES OF '"CESVAL"' IN cv_json WITH '"CesVal"'.
    REPLACE ALL OCCURRENCES OF '"STCESVAL"' IN cv_json WITH '"StCesVal"'.

    REPLACE ALL OCCURRENCES OF '"RNDOFFAMT"' IN cv_json WITH '"RndOffAmt"'.
    REPLACE ALL OCCURRENCES OF '"TOTINVVAL"' IN cv_json WITH '"TotInvVal"'.

* CANCEL IRN
    REPLACE ALL OCCURRENCES OF '"IRN"' IN cv_json WITH '"Irn"'.
    REPLACE ALL OCCURRENCES OF '"CNLRSN"' IN cv_json WITH '"CnlRsn"'.
    REPLACE ALL OCCURRENCES OF '"CNLREM"' IN cv_json WITH '"CnlRem"'.

* EWAY BILL
    REPLACE ALL OCCURRENCES OF '"AUTO_GENERATE_EWAYBILL_THROUGH_API"' IN cv_json WITH '"auto_generate_ewaybill_through_api"'.
    REPLACE ALL OCCURRENCES OF '"AUTO_GENERATE_EWAYBILL_PDF_THROUGH_API"' IN cv_json WITH '"auto_generate_ewaybill_pdf_through_api"'.
    REPLACE ALL OCCURRENCES OF '"PDF_FORMAT"' IN cv_json WITH '"pdf_format"'.
    REPLACE ALL OCCURRENCES OF '"GSTIN"' IN cv_json WITH '"gstin"'.

* CANCEL EWAY BILL
    REPLACE ALL OCCURRENCES OF '"EWAYBILL_NO"' IN cv_json WITH '"ewaybill_no"'.
    REPLACE ALL OCCURRENCES OF '"EWAYBILL_CANCEL_REASON"' IN cv_json WITH '"ewaybill_cancel_reason"'.
    REPLACE ALL OCCURRENCES OF '"EWAYBILL_CANCEL_REMARK"' IN cv_json WITH '"ewaybill_cancel_remark"'.

* OPTIONAL STRUCTURES
    REPLACE ALL OCCURRENCES OF '"PAYDTLS"' IN cv_json WITH '"PayDtls"'.
    REPLACE ALL OCCURRENCES OF '"REFDTLS"' IN cv_json WITH '"RefDtls"'.
    REPLACE ALL OCCURRENCES OF '"ADDLDOCDTLS"' IN cv_json WITH '"AddlDocDtls"'.
    REPLACE ALL OCCURRENCES OF '"EXPDTLS"' IN cv_json WITH '"ExpDtls"'.
    REPLACE ALL OCCURRENCES OF '"EWBDTLS"' IN cv_json WITH '"EwbDtls"'.

* Convert empty string → null (API requirement)
    REPLACE ALL OCCURRENCES OF '"PayDtls":""'  IN cv_json WITH '"PayDtls":null'.
    REPLACE ALL OCCURRENCES OF '"PayDtls": ""' IN cv_json WITH '"PayDtls":null'.

    REPLACE ALL OCCURRENCES OF '"RefDtls":""'  IN cv_json WITH '"RefDtls":null'.
    REPLACE ALL OCCURRENCES OF '"RefDtls": ""' IN cv_json WITH '"RefDtls":null'.

    REPLACE ALL OCCURRENCES OF '"AddlDocDtls":""'  IN cv_json WITH '"AddlDocDtls":null'.
    REPLACE ALL OCCURRENCES OF '"AddlDocDtls": ""' IN cv_json WITH '"AddlDocDtls":null'.

    REPLACE ALL OCCURRENCES OF '"ExpDtls":""'  IN cv_json WITH '"ExpDtls":null'.
    REPLACE ALL OCCURRENCES OF '"ExpDtls": ""' IN cv_json WITH '"ExpDtls":null'.

    REPLACE ALL OCCURRENCES OF '"EwbDtls":""'  IN cv_json WITH '"EwbDtls":null'.
    REPLACE ALL OCCURRENCES OF '"EwbDtls": ""' IN cv_json WITH '"EwbDtls":null'.

    REPLACE ALL OCCURRENCES OF '"BchDtls":""'  IN cv_json WITH '"BchDtls":null'.
    REPLACE ALL OCCURRENCES OF '"BchDtls": ""' IN cv_json WITH '"BchDtls":null'.

    REPLACE ALL OCCURRENCES OF '"AttribDtls":""'  IN cv_json WITH '"AttribDtls":null'.
    REPLACE ALL OCCURRENCES OF '"AttribDtls": ""' IN cv_json WITH '"AttribDtls":null'.


  ENDMETHOD.
ENDCLASS.
