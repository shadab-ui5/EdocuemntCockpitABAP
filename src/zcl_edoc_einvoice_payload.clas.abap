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

    TYPES: BEGIN OF ty_eway,
             billingdocument  TYPE vbeln,
             irn              TYPE string,
             transporterid    TYPE string,
             transdocno       TYPE string,
             transdocdate     TYPE char10,
             transdistance    TYPE string,
             vehicleno        TYPE string,
             vehicletype      TYPE string,
             transportmode    TYPE string,
             transportername  TYPE string,
             transportergstin TYPE string,
           END OF ty_eway.

    TYPES tt_eway TYPE STANDARD TABLE OF ty_eway WITH EMPTY KEY.

    CLASS-METHODS create_ewaybill
      IMPORTING it_eway           TYPE tt_eway
      RETURNING VALUE(rv_message) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS:
      gc_dist_export TYPE zi_einv_header-distributionchannel VALUE '20'.

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

    CLASS-METHODS update_eway_table
      IMPORTING
                iv_response       TYPE string
                iv_action         TYPE string
                it_cancel         TYPE tt_cancel OPTIONAL
                it_eway           TYPE tt_eway OPTIONAL
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
      IMPORTING iv_type TYPE string
      CHANGING  cv_json TYPE string .


    TYPES: tt_header  TYPE STANDARD TABLE OF zi_einv_header,
           tt_item    TYPE STANDARD TABLE OF zi_einv_item,
           tt_pricing TYPE STANDARD TABLE OF zi_einv_pricing,
           tt_partner TYPE STANDARD TABLE OF zi_einv_partner,
           tt_plant   TYPE STANDARD TABLE OF zi_einv_plant_address,
           tt_gst     TYPE STANDARD TABLE OF zi_einv_gst.

    CLASS-METHODS get_source_data
      IMPORTING it_billing TYPE tt_billing
      EXPORTING et_header  TYPE tt_header
                et_item    TYPE tt_item
                et_pricing TYPE tt_pricing
                et_partner TYPE tt_partner
                et_plant   TYPE tt_plant
                et_gst     TYPE tt_gst.

    CLASS-METHODS convert_datetime
      IMPORTING
        iv_ts   TYPE string
      EXPORTING
        ev_date TYPE datum
        ev_time TYPE uzeit.

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

             BEGIN OF expdtls,
               shipbno TYPE string,
               shipbdt TYPE string,
               port    TYPE string,
               refclm  TYPE string,
               forcur  TYPE string,
               cntcode TYPE string,
               expduty TYPE p LENGTH 16 DECIMALS 2,
             END OF expdtls,

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

    DATA: lt_invoice    TYPE tt_invoice,
          lv_loop_count TYPE i.

*-- Read all required data first
    DATA: lt_header  TYPE STANDARD TABLE OF zi_einv_header,
          lt_item    TYPE STANDARD TABLE OF zi_einv_item,
          lt_pricing TYPE STANDARD TABLE OF zi_einv_pricing,
          lt_partner TYPE STANDARD TABLE OF zi_einv_partner,
          lt_plant   TYPE STANDARD TABLE OF zi_einv_plant_address,
          lt_gst     TYPE STANDARD TABLE OF zi_einv_gst.

    get_source_data(
      EXPORTING it_billing = it_billing
      IMPORTING et_header  = lt_header
                et_item    = lt_item
                et_pricing = lt_pricing
                et_partner = lt_partner
                et_plant   = lt_plant
                et_gst     = lt_gst ).

*-- Billing Header

    LOOP AT lt_header INTO DATA(ls_head).

      DATA(ls_invoice) = VALUE ty_invoice( ).
      CLEAR: ls_invoice-valdtls, lv_loop_count.

      " Exchange rate mapping for export and domestic case
      DATA(lv_exch_rate) = COND ty_amount(
        WHEN ls_head-distributionchannel = gc_dist_export
        THEN ls_head-accountingexchangerate
        ELSE 1 ).

      IF lv_exch_rate IS INITIAL OR lv_exch_rate = 0.
        lv_exch_rate = 1.
      ENDIF.

* Header Mapping
      ls_invoice-custdocno = ls_head-documentreferenceid.

      DATA(lv_has_tax) = abap_false.

      LOOP AT lt_pricing INTO DATA(ls_tax_chk)
        WHERE billingdocument = ls_head-billingdocument
          AND ( conditiontype = 'JOIG'
             OR conditiontype = 'JOCG'
             OR conditiontype = 'JOSG'
             OR conditiontype = 'JOUG' ).

        IF ls_tax_chk-conditionamount IS NOT INITIAL
           AND ls_tax_chk-conditionamount <> 0.

          lv_has_tax = abap_true.
          EXIT.

        ENDIF.

      ENDLOOP.

      CASE ls_head-distributionchannel.

        WHEN '10' OR '30' OR '40' OR '60' OR '70' OR '80'.
          ls_invoice-trandtls-suptyp = 'B2B'.

        WHEN '50'.
          IF lv_has_tax = abap_true.
            ls_invoice-trandtls-suptyp = 'SEZWP'.
          ELSE.
            ls_invoice-trandtls-suptyp = 'SEZWOP'.
          ENDIF.

        WHEN gc_dist_export.
          IF lv_has_tax = abap_true.
            ls_invoice-trandtls-suptyp = 'EXPWP'.
          ELSE.
            ls_invoice-trandtls-suptyp = 'EXPWOP'.
          ENDIF.

        WHEN '90'.
          ls_invoice-trandtls-suptyp = 'DEXP'.

        WHEN OTHERS.
          ls_invoice-trandtls-suptyp = 'B2B'.

      ENDCASE.

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
      IF ls_head-distributionchannel = gc_dist_export.
        ls_invoice-buyerdtls-gstin = 'URP'.
        ls_invoice-buyerdtls-pos   = '96'.
        ls_invoice-buyerdtls-stcd  = '96'.
        ls_invoice-buyerdtls-pin   = '999999'.
      ELSE.
        ls_invoice-buyerdtls-gstin = ls_head-buyergstin.
        ls_invoice-buyerdtls-pos   = get_gst_state_code( ls_head-buyerregion ).
        ls_invoice-buyerdtls-stcd  = get_gst_state_code( ls_head-buyerregion ).
        ls_invoice-buyerdtls-pin   = ls_head-buyerpostalcode.
      ENDIF.

      ls_invoice-buyerdtls-lglnm =
      |{ ls_head-buyername1 } { ls_head-buyername2 }|.

      ls_invoice-buyerdtls-trdnm = ls_invoice-buyerdtls-lglnm.

      ls_invoice-buyerdtls-addr1 = ls_head-buyerstreet.
      ls_invoice-buyerdtls-loc   = ls_head-buyercity.


* Dispatch Address
      IF lv_business_place IS NOT INITIAL.

        ls_invoice-dispdtls-nm    = ls_plant_addr-dispatchname.
        ls_invoice-dispdtls-addr1 = ls_plant_addr-addr1.
        ls_invoice-dispdtls-loc   = ls_plant_addr-city.
        ls_invoice-dispdtls-pin   = ls_plant_addr-postalcode.
        ls_invoice-dispdtls-stcd  = get_gst_state_code( ls_plant_addr-statecode ).

      ENDIF.


      DATA: lv_item_oth  TYPE ty_amount,
            lv_total_oth TYPE ty_amount,
            lv_cgst_rate TYPE p LENGTH 5 DECIMALS 2,
            lv_sgst_rate TYPE p LENGTH 5 DECIMALS 2.

      CLEAR: lv_total_oth.

* Item Loop
      LOOP AT lt_item INTO DATA(ls_item)
      WHERE billingdocument = ls_head-billingdocument.

        CLEAR: lv_item_oth, lv_cgst_rate, lv_sgst_rate.

        lv_loop_count = sy-tabix.

        IF lv_loop_count = 1.

          IF ls_head-distributionchannel = gc_dist_export.
* Ship To Mapping - Export
            ls_invoice-shipdtls-gstin = 'URP'.
            ls_invoice-shipdtls-lglnm = ls_head-yy1_port_detailsname_bdh.
            ls_invoice-shipdtls-trdnm = ls_head-yy1_port_detailsname_bdh.
            ls_invoice-shipdtls-addr1 = ls_head-yy1_port_detailsadres_bdh.
            ls_invoice-shipdtls-loc   = ls_head-yy1_port_detailssname_bdh.
            ls_invoice-shipdtls-pin   = ls_head-yy1_port_detailspin_bdh.
            ls_invoice-shipdtls-stcd  = ls_head-yy1_port_detailsstate_bdh.

          ELSE.
* Ship To Mapping - Domestic
            READ TABLE lt_partner INTO DATA(ls_ship)
              WITH KEY customer = ls_item-shiptoparty
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
          ENDIF.

        ENDIF.


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
          assamt  = round_amount( CONV ty_amount( ls_item-netamount * lv_exch_rate ) ) "Net Amount
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

                ls_item_json-unitprice = round_amount( CONV ty_amount( ls_price-conditionrateamount * lv_exch_rate  ) ).
                ls_item_json-totamt    = round_amount( CONV ty_amount( ls_price-conditionamount * lv_exch_rate ) ).

              WHEN 'JOIG'.  " IGST
                ls_item_json-igstamt =
                  round_amount( CONV ty_amount( ls_price-conditionamount * lv_exch_rate ) ).

                ls_item_json-gstrt =
                  ls_price-conditionrateratio.

              WHEN 'JOCG'. "CGST
                ls_item_json-cgstamt =
                  round_amount( CONV ty_amount( ls_price-conditionamount * lv_exch_rate ) ).

                lv_cgst_rate = ls_price-conditionrateratio.

              WHEN 'JOSG' OR 'JOUG'. "SGST
                ls_item_json-sgstamt =
                  round_amount( CONV ty_amount( ls_price-conditionamount * lv_exch_rate ) ).

                lv_sgst_rate = ls_price-conditionrateratio.

              WHEN 'JTC1' OR 'JTC2'.  "Pass other changes condition type here

                lv_item_oth += round_amount(
                                 CONV ty_amount(
                                   ls_price-conditionamount * lv_exch_rate ) ).

            ENDCASE.

          ENDLOOP.

          IF lv_cgst_rate IS NOT INITIAL AND lv_sgst_rate IS NOT INITIAL.
            ls_item_json-gstrt = lv_cgst_rate + lv_sgst_rate.
          ENDIF.

          ls_item_json-othchrg = lv_item_oth.
          lv_total_oth += lv_item_oth.

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

      ENDLOOP.

      ls_invoice-valdtls-othchrg = lv_total_oth.

* TotInvVal calculation
      ls_invoice-valdtls-totinvval =
            ls_invoice-valdtls-assval
          + ls_invoice-valdtls-cgstval
          + ls_invoice-valdtls-sgstval
          + ls_invoice-valdtls-igstval
          + ls_invoice-valdtls-othchrg
          + ls_invoice-valdtls-rndoffamt
          - ls_invoice-valdtls-discount.

      "- Export Details
      IF ls_head-distributionchannel = gc_dist_export.

        ls_invoice-expdtls-shipbno = ls_head-yy1_lrgcnnumber_bdh.

        IF ls_head-yy1_date_bdh IS NOT INITIAL.
          ls_invoice-expdtls-shipbdt =
            format_date( ls_head-yy1_date_bdh ).
        ENDIF.

        ls_invoice-expdtls-port = ls_head-yy1_port_detailscode_bdh.
        ls_invoice-expdtls-refclm = 'N'.
        ls_invoice-expdtls-forcur = ls_head-transactioncurrency.
        ls_invoice-expdtls-cntcode = ls_head-country.
        ls_invoice-expdtls-expduty = 0.

      ELSE.
        CLEAR ls_invoice-expdtls.
      ENDIF.

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

    fix_json_keys( EXPORTING iv_type = 'EINV'
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

          lv_key = 'avhNgUWHGSnD3rsLWWB9WmBMCzhvMqic0w_rk77-3pYfsnIlhghodpGKFSf09z7z'.

        WHEN 'CANCEL_EINVOICE'.
          lv_url =
          'https://timetechnoplast.supertaxuat.in/api/integration/einvoices/v1.01/sales/cancel'.

          lv_key = 'avhNgUWHGSnD3rsLWWB9WmBMCzhvMqic0w_rk77-3pYfsnIlhghodpGKFSf09z7z'.

        WHEN 'GEN_EWAY'.
          lv_url =
          'https://ewayuat.supertaxgst.in/api/invoices'.

*          lv_key = 'avhNgUWHGSnD3rsLWWB9WmBMCzhvMqic0w_rk77-3pYfsnIlhghodpGKFSf09z7z'.
          lv_key = '02b2bdd3442b5324b0354ee0f409d298ba6abdcf71efb19ac78a77fa6309d4a0'.

        WHEN 'CANCEL_EWAY'.
          lv_url =
          'https://yoursubdomain.supertaxuat.in/api/integration/ewaybill/v1.01/cancel'.

          lv_key = 'avhNgUWHGSnD3rsLWWB9WmBMCzhvMqic0w_rk77-3pYfsnIlhghodpGKFSf09z7z'.

      ENDCASE.

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
             ackno        TYPE string,
             ackdate      TYPE string,
             record       TYPE string,
             success      TYPE abap_bool,
             fy           TYPE string,
             messages     TYPE string,
             status       TYPE string,
             irn          TYPE string,
             custdocno    TYPE string,
             filename     TYPE string,
             signedqrcode TYPE string,
             qrcode       TYPE string,
             ewbnum       TYPE string,
             ewbdate      TYPE string,
             validupto    TYPE string,
             docdtls      TYPE ty_doc,
             sellerdtls   TYPE ty_seller,
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
        REPLACE ALL OCCURRENCES OF ':' IN lv_t WITH ''.

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

            DATA lv_inv_x TYPE xstring.

            ls_edoc-signedqrcodestr  = ls_inv-signedqrcode.
            ls_edoc-qrcode        = ls_inv-qrcode.

            ls_edoc-edocstatus        = 'EINVOICE_GENERATED'.
*            ls_edoc-edocoverallstatus = 'COMPLETED'.

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

*          DATA: lv_eway_date  TYPE datum,
*                lv_eway_time  TYPE uzeit,
*                lv_valid_date TYPE datum,
*                lv_valid_time TYPE uzeit.
*
*          ls_edoc-errormessage = ls_inv-messages.
*
*
*          IF ls_inv-ewbdate IS NOT INITIAL.
*
*            SPLIT ls_inv-ewbdate
*              AT space
*              INTO DATA(lv_ed)
*                   DATA(lv_et).
*
*            REPLACE ALL OCCURRENCES OF '-' IN lv_ed WITH ''.
*            REPLACE ALL OCCURRENCES OF ':' IN lv_et WITH ''.
*
*            lv_eway_date = lv_ed.
*            lv_eway_time = lv_et.
*
*          ENDIF.
*
*          IF ls_inv-validupto IS NOT INITIAL.
*
*            SPLIT ls_inv-validupto
*              AT space
*              INTO DATA(lv_vd)
*                   DATA(lv_vt).
*
*            REPLACE ALL OCCURRENCES OF '-' IN lv_vd WITH ''.
*            REPLACE ALL OCCURRENCES OF ':' IN lv_vt WITH ''.
*
*            lv_valid_date = lv_vd.
*            lv_valid_time = lv_vt.
*
*          ENDIF.
*
*          IF ls_inv-success = abap_true.
*
*            lv_success += 1.
*            lv_success_docs = |{ lv_success_docs } , { ls_inv-custdocno }|.
*
*            SELECT SINGLE odndocument,
*                          billingdocument
*             FROM zedocinvoice
*             WHERE odndocument = @ls_inv-custdocno
*             INTO @DATA(ls_einvdata).
*
*            IF sy-subrc = 0.
*
** TRANSPORT
*              READ TABLE it_eway INTO DATA(ls_eway)
*                WITH KEY billingdocument = ls_einvdata-billingdocument.
*
*              IF sy-subrc = 0.
*                DATA(lv_transportmode)     = ls_eway-transportmode.
*                DATA(lv_tdistance) = CONV i( round( val = ls_eway-transdistance dec = 0 ) ).
*                DATA(lv_tcode)     = ls_eway-transporterid.
*                DATA(lv_ttin)      = substring( val = ls_eway-transportergstin len = 15 ).
*                DATA(lv_tname)     = substring( val = ls_eway-transportername len = 45 ).
*                DATA(lv_tinum)     = substring( val = ls_eway-transdocno len = 15 ).
*
*                DATA: lv_input  TYPE string,
*                      lv_date1  TYPE d,
*                      lv_output TYPE string.
*
*                lv_input = ls_eway-transdocdate.
*
*                IF lv_input IS NOT INITIAL.
*                  REPLACE ALL OCCURRENCES OF '-' IN lv_input WITH ''.
*                  lv_date1 = lv_input.
*
*                  " Convert to DDMMYYYY
*                  lv_output = |{ lv_date1+6(2) }{ lv_date1+4(2) }{ lv_date1(4) }|.
*                ENDIF.
*
*                DATA(lv_tdate)     = lv_output.
*                DATA(lv_tvnum)     = ls_eway-vehicleno(15).
*              ENDIF.
*
*              UPDATE zedocinvoice
*                 SET signedinvoice = @ls_inv-filename,
*                     ewaybillno = @ls_inv-ewbnum,
*                     ewaycreatedate = @lv_eway_date,
*                     ewaycreatetime = @lv_eway_time,
*                     ewayvalidenddate = @lv_valid_date,
*                     ewayvalidendat = @lv_valid_time,
*                     errormessage = @ls_inv-messages,
*                     edocstatus = 'EWAY_GENERATED',
*                     edocoverallstatus = 'COMPLETED',
*                     transporterid = @lv_tcode,
*                     transdocno = @lv_tinum,
*                     transdocdate = @lv_tdate,
*                     transdistance = @lv_tdistance,
*                     vehicleno = @lv_tvnum,
**                      vehicletype        : abap.char(10);
*                     transportmode = @lv_transportmode,
*                     transportername = @lv_tname,
*                     transportergstin = @lv_ttin
*                 WHERE odndocument = @ls_inv-custdocno.
*
*            ELSE.
*              SELECT SINGLE companycode,
*                            documentreferenceid,
*                            billingdocument
*                FROM i_billingdocument
*                WHERE documentreferenceid = @ls_inv-custdocno
*                INTO @DATA(ls_billing_det_eway).
*
*              IF sy-subrc = 0.
*
** TRANSPORT
*                READ TABLE it_eway INTO ls_eway
*                  WITH KEY billingdocument = ls_billing_det_eway-billingdocument.
*
*                IF sy-subrc = 0.
*                  ls_edoc-transportmode     = ls_eway-transportmode.
*                  ls_edoc-transdistance = CONV i( round( val = ls_eway-transdistance dec = 0 ) ).
*                  ls_edoc-transporterid    = ls_eway-transporterid.
*                  ls_edoc-transportergstin      = substring( val = ls_eway-transportergstin len = 15 ).
*                  ls_edoc-transportername     = substring( val = ls_eway-transportername len = 45 ).
*                  ls_edoc-transdocno     = substring( val = ls_eway-transdocno len = 15 ).
*
*                  lv_input = ls_eway-transdocdate.
*
*                  IF lv_input IS NOT INITIAL.
*                    REPLACE ALL OCCURRENCES OF '-' IN lv_input WITH ''.
*                    lv_date1 = lv_input.
*
*                    " Convert to DDMMYYYY
*                    lv_output = |{ lv_date1+6(2) }{ lv_date1+4(2) }{ lv_date1(4) }|.
*                  ENDIF.
*
*                  ls_edoc-transdocdate     = lv_output.
*                  ls_edoc-vehicleno     = ls_eway-vehicleno(15).
*                ENDIF.
*
*                ls_edoc-odndocument     = ls_inv-custdocno.
*                ls_edoc-edocsourcetype  = 'SD_INVOICE'.
*                ls_edoc-compcode        = ls_billing_det_eway-companycode.
*                ls_edoc-documentnumber  = ls_inv-custdocno.
*                ls_edoc-billingdocument = ls_billing_det_eway-billingdocument.
*
*                ls_edoc-ewaybillno       = ls_inv-ewbnum.
*                ls_edoc-ewaycreatedate   = lv_eway_date.
*                ls_edoc-ewaycreatetime   = lv_eway_time.
*                ls_edoc-ewayvalidenddate = lv_valid_date.
*                ls_edoc-ewayvalidendat   = lv_valid_time.
*                ls_edoc-edocstatus       = 'EWAY_GENERATED'.
*                ls_edoc-edocoverallstatus = 'COMPLETED'.
*
*                MODIFY zedocinvoice FROM @ls_edoc.
*              ENDIF.
*
*            ENDIF.
*
*          ELSE.
*
*            ls_edoc-edocstatus        = 'EWAY_FAILED'.
*            ls_edoc-edocoverallstatus = 'FAILED'.
*
*            lv_failed += 1.
*            lv_failure_docs = |{ lv_failure_docs } , { ls_inv-custdocno }|.
*            lv_error_msg    = |{ lv_error_msg } , { ls_inv-messages }|.
*
*            SELECT SINGLE odndocument
*             FROM zedocinvoice
*             WHERE odndocument = @ls_inv-custdocno
*             INTO @ls_einvdata.
*
*            IF sy-subrc = 0.
*              UPDATE zedocinvoice
*                SET errormessage = @ls_inv-messages,
*                    edocstatus = 'EWAY_FAILED',
*                    edocoverallstatus = 'FAILED'
*                 WHERE odndocument = @ls_inv-custdocno.
*
*            ELSE.
*              SELECT SINGLE companycode,
*                            documentreferenceid,
*                            billingdocument
*                FROM i_billingdocument
*                WHERE documentreferenceid = @ls_inv-custdocno
*                INTO @ls_billing_det_eway.
*
*              IF sy-subrc = 0.
*                ls_edoc-odndocument     = ls_inv-custdocno.
*                ls_edoc-edocsourcetype  = 'SD_INVOICE'.
*                ls_edoc-compcode        = ls_billing_det_eway-companycode.
*                ls_edoc-documentnumber  = ls_inv-custdocno.
*                ls_edoc-billingdocument = ls_billing_det_eway-billingdocument.
*
*                ls_edoc-edocstatus        = 'EWAY_FAILED'.
*                ls_edoc-edocoverallstatus = 'FAILED'.
*
*                MODIFY zedocinvoice FROM @ls_edoc.
*              ENDIF.
*
*            ENDIF.
*
*          ENDIF.


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

    fix_json_keys( EXPORTING iv_type = 'EINV'
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
    IF iv_type = 'EINV'.
      REPLACE ALL OCCURRENCES OF '"GSTIN"' IN cv_json WITH '"Gstin"'.
      REPLACE ALL OCCURRENCES OF '"QTY"'      IN cv_json WITH '"Qty"'.
      REPLACE ALL OCCURRENCES OF '"IRN"' IN cv_json WITH '"Irn"'.
    ENDIF.

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

* EXPDTLS fields
    REPLACE ALL OCCURRENCES OF '"SHIPBNO"' IN cv_json WITH '"ShipBNo"'.
    REPLACE ALL OCCURRENCES OF '"SHIPBDT"' IN cv_json WITH '"ShipBDt"'.
    REPLACE ALL OCCURRENCES OF '"PORT"'    IN cv_json WITH '"Port"'.
    REPLACE ALL OCCURRENCES OF '"REFCLM"'  IN cv_json WITH '"RefClm"'.
    REPLACE ALL OCCURRENCES OF '"FORCUR"'  IN cv_json WITH '"ForCur"'.
    REPLACE ALL OCCURRENCES OF '"CNTCODE"' IN cv_json WITH '"CntCode"'.
    REPLACE ALL OCCURRENCES OF '"EXPDUTY"' IN cv_json WITH '"ExpDuty"'.

* Convert empty string to null
    REPLACE ALL OCCURRENCES OF '"PayDtls":""'  IN cv_json WITH '"PayDtls":null'.
    REPLACE ALL OCCURRENCES OF '"PayDtls": ""' IN cv_json WITH '"PayDtls":null'.

    REPLACE ALL OCCURRENCES OF '"RefDtls":""'  IN cv_json WITH '"RefDtls":null'.
    REPLACE ALL OCCURRENCES OF '"RefDtls": ""' IN cv_json WITH '"RefDtls":null'.

    REPLACE ALL OCCURRENCES OF '"AddlDocDtls":""'  IN cv_json WITH '"AddlDocDtls":null'.
    REPLACE ALL OCCURRENCES OF '"AddlDocDtls": ""' IN cv_json WITH '"AddlDocDtls":null'.

    REPLACE ALL OCCURRENCES OF '"ExpDtls":""'  IN cv_json WITH '"ExpDtls":null'.
    REPLACE ALL OCCURRENCES OF '"ExpDtls": ""' IN cv_json WITH '"ExpDtls":null'.

    REPLACE ALL OCCURRENCES OF REGEX
      '"ExpDtls"\s*:\s*\{[^}]*"ShipBNo"\s*:\s*""[^}]*"Port"\s*:\s*""[^}]*"CntCode"\s*:\s*""[^}]*"ExpDuty"\s*:\s*0[^}]*\}\s*,'
      IN cv_json
      WITH '"ExpDtls": null,'.

    REPLACE ALL OCCURRENCES OF '"EwbDtls":""'  IN cv_json WITH '"EwbDtls":null'.
    REPLACE ALL OCCURRENCES OF '"EwbDtls": ""' IN cv_json WITH '"EwbDtls":null'.

    REPLACE ALL OCCURRENCES OF '"BchDtls":""'  IN cv_json WITH '"BchDtls":null'.
    REPLACE ALL OCCURRENCES OF '"BchDtls": ""' IN cv_json WITH '"BchDtls":null'.

    REPLACE ALL OCCURRENCES OF '"AttribDtls":""'  IN cv_json WITH '"AttribDtls":null'.
    REPLACE ALL OCCURRENCES OF '"AttribDtls": ""' IN cv_json WITH '"AttribDtls":null'.


* EMPTY STRING is converted to NULL

* Phone & Email (Seller / Buyer / Ship etc.)
    REPLACE ALL OCCURRENCES OF '"Ph":""'  IN cv_json WITH '"Ph":null'.
    REPLACE ALL OCCURRENCES OF '"Ph": ""' IN cv_json WITH '"Ph":null'.

    REPLACE ALL OCCURRENCES OF '"Em":""'  IN cv_json WITH '"Em":null'.
    REPLACE ALL OCCURRENCES OF '"Em": ""' IN cv_json WITH '"Em":null'.

* ADDRESS OPTIONAL FIELDS
    REPLACE ALL OCCURRENCES OF '"Addr2":""'  IN cv_json WITH '"Addr2":null'.
    REPLACE ALL OCCURRENCES OF '"Addr2": ""' IN cv_json WITH '"Addr2":null'.

    " Eway Bill ROOT FIX
    REPLACE ALL OCCURRENCES OF '"AG_EWAY"' IN cv_json
      WITH '"auto_generate_ewaybill_through_api"'.

    REPLACE ALL OCCURRENCES OF '"AG_PDF"' IN cv_json
      WITH '"auto_generate_ewaybill_pdf_through_api"'.

    REPLACE ALL OCCURRENCES OF '"PDF_FMT"' IN cv_json
      WITH '"pdf_format"'.

    " Eway Bill HEADER
    REPLACE ALL OCCURRENCES OF '"COMPANY_NAME"' IN cv_json WITH '"company_name"'.
    REPLACE ALL OCCURRENCES OF '"SUPPLY_TYPE"' IN cv_json WITH '"supply_type"'.
    REPLACE ALL OCCURRENCES OF '"SUPPLY_SUBTYPE"' IN cv_json WITH '"supply_subtype"'.
    REPLACE ALL OCCURRENCES OF '"DOC_TYPE"' IN cv_json WITH '"doc_type"'.
    REPLACE ALL OCCURRENCES OF '"INUM"' IN cv_json WITH '"inum"'.
    REPLACE ALL OCCURRENCES OF '"IDT"' IN cv_json WITH '"idt"'.
    REPLACE ALL OCCURRENCES OF '"VAL"' IN cv_json WITH '"val"'.
    REPLACE ALL OCCURRENCES OF '"OTHER_CHARGES"' IN cv_json WITH '"other_charges"'.
    REPLACE ALL OCCURRENCES OF '"DOC_REFERENCE_NO"' IN cv_json WITH '"doc_reference_no"'.

    " Eway Bill ITEM
    REPLACE ALL OCCURRENCES OF '"PRODUCT_CODE"' IN cv_json WITH '"product_code"'.
    REPLACE ALL OCCURRENCES OF '"PRODUCT_NAME"' IN cv_json WITH '"product_name"'.
    REPLACE ALL OCCURRENCES OF '"HSN_SAC"' IN cv_json WITH '"hsn_sac"'.
    REPLACE ALL OCCURRENCES OF '"UQC"' IN cv_json WITH '"uqc"'.
    REPLACE ALL OCCURRENCES OF '"TXVAL"' IN cv_json WITH '"txval"'.
    REPLACE ALL OCCURRENCES OF '"IAMT"' IN cv_json WITH '"iamt"'.
    REPLACE ALL OCCURRENCES OF '"CAMT"' IN cv_json WITH '"camt"'.
    REPLACE ALL OCCURRENCES OF '"SAMT"' IN cv_json WITH '"samt"'.
    REPLACE ALL OCCURRENCES OF '"CSAMT"' IN cv_json WITH '"csamt"'.
    REPLACE ALL OCCURRENCES OF '"ITEM_OTHER_CHARGES"' IN cv_json WITH '"item_other_charges"'.

    "SHIP TO
    REPLACE ALL OCCURRENCES OF '"SHIPTO_MASTER_CODE"' IN cv_json WITH '"shipTo_master_code"'.
    REPLACE ALL OCCURRENCES OF '"SHIPTO_ADDRESS_1"' IN cv_json WITH '"shipTo_address_1"'.
    REPLACE ALL OCCURRENCES OF '"SHIPTO_ADDRESS_2"' IN cv_json WITH '"shipTo_address_2"'.
    REPLACE ALL OCCURRENCES OF '"SHIPTO_PLACE"' IN cv_json WITH '"shipTo_place"'.
    REPLACE ALL OCCURRENCES OF '"SHIPTO_PINCODE"' IN cv_json WITH '"shipTo_pincode"'.

    "DISPATCH
    REPLACE ALL OCCURRENCES OF '"DISPATCHFROM_MASTER_CODE"' IN cv_json WITH '"dispatchFrom_master_code"'.
    REPLACE ALL OCCURRENCES OF '"DISPATCHFROM_ADDRESS_1"' IN cv_json WITH '"dispatchFrom_address_1"'.
    REPLACE ALL OCCURRENCES OF '"DISPATCHFROM_ADDRESS_2"' IN cv_json WITH '"dispatchFrom_address_2"'.
    REPLACE ALL OCCURRENCES OF '"DISPATCHFROM_PLACE"' IN cv_json WITH '"dispatchFrom_place"'.
    REPLACE ALL OCCURRENCES OF '"DISPATCHFROM_PINCODE"' IN cv_json WITH '"dispatchFrom_pincode"'.

    " Vendor (Bill From)
    REPLACE ALL OCCURRENCES OF '"VCODE"' IN cv_json WITH '"vcode"'.
    REPLACE ALL OCCURRENCES OF '"VNAME"' IN cv_json WITH '"vname"'.
    REPLACE ALL OCCURRENCES OF '"VTIN"' IN cv_json WITH '"vtin"'.
    REPLACE ALL OCCURRENCES OF '"V_ACT_STATE"' IN cv_json WITH '"v_act_state"'.
    REPLACE ALL OCCURRENCES OF '"V_ADDRESS_1"' IN cv_json WITH '"v_address_1"'.
    REPLACE ALL OCCURRENCES OF '"V_ADDRESS_2"' IN cv_json WITH '"v_address_2"'.
    REPLACE ALL OCCURRENCES OF '"V_PLACE"' IN cv_json WITH '"v_place"'.
    REPLACE ALL OCCURRENCES OF '"V_PIN_CODE"' IN cv_json WITH '"v_pin_code"'.
    REPLACE ALL OCCURRENCES OF '"V_STATE"' IN cv_json WITH '"v_state"'.

    " Customer (Bill To)
    REPLACE ALL OCCURRENCES OF '"CCODE"' IN cv_json WITH '"ccode"'.
    REPLACE ALL OCCURRENCES OF '"CNAME"' IN cv_json WITH '"cname"'.
    REPLACE ALL OCCURRENCES OF '"CTIN"' IN cv_json WITH '"ctin"'.
    REPLACE ALL OCCURRENCES OF '"C_ACT_STATE"' IN cv_json WITH '"c_act_state"'.
    REPLACE ALL OCCURRENCES OF '"C_ADDRESS_1"' IN cv_json WITH '"c_address_1"'.
    REPLACE ALL OCCURRENCES OF '"C_ADDRESS_2"' IN cv_json WITH '"c_address_2"'.
    REPLACE ALL OCCURRENCES OF '"C_PLACE"' IN cv_json WITH '"c_place"'.
    REPLACE ALL OCCURRENCES OF '"C_PIN_CODE"' IN cv_json WITH '"c_pin_code"'.
    REPLACE ALL OCCURRENCES OF '"C_STATE"' IN cv_json WITH '"c_state"'.

    " Ship To
    REPLACE ALL OCCURRENCES OF '"SHIPTOGSTIN"' IN cv_json WITH '"shipToGSTIN"'.
    REPLACE ALL OCCURRENCES OF '"SHIPTOTRADENAME"' IN cv_json WITH '"shipToTradeName"'.

    " Dispatch
    REPLACE ALL OCCURRENCES OF '"DISPATCHFROMGSTIN"' IN cv_json WITH '"dispatchFromGSTIN"'.
    REPLACE ALL OCCURRENCES OF '"DISPATCHFROMTRADENAME"' IN cv_json WITH '"dispatchFromTradeName"'.

    " Header
    REPLACE ALL OCCURRENCES OF '"SUB_SUPPLY_REASON"' IN cv_json WITH '"sub_supply_reason"'.

    " Items
    REPLACE ALL OCCURRENCES OF '"ITEMS"' IN cv_json WITH '"items"'.

    " Item
    REPLACE ALL OCCURRENCES OF '"DESC"' IN cv_json WITH '"desc"'.
    REPLACE ALL OCCURRENCES OF '"RT"' IN cv_json WITH '"rt"'.
    REPLACE ALL OCCURRENCES OF '"QTY"' IN cv_json WITH '"qty"'.
    REPLACE ALL OCCURRENCES OF '"TMODE"' IN cv_json WITH '"tmode"'.
    REPLACE ALL OCCURRENCES OF '"TDISTANCE"' IN cv_json WITH '"tdistance"'.
    REPLACE ALL OCCURRENCES OF '"TCODE"' IN cv_json WITH '"tcode"'.
    REPLACE ALL OCCURRENCES OF '"TTIN"' IN cv_json WITH '"ttin"'.
    REPLACE ALL OCCURRENCES OF '"TNAME"' IN cv_json WITH '"tname"'.
    REPLACE ALL OCCURRENCES OF '"TINUM"' IN cv_json WITH '"tinum"'.
    REPLACE ALL OCCURRENCES OF '"TDATE"' IN cv_json WITH '"tdate"'.
    REPLACE ALL OCCURRENCES OF '"TVNUM"' IN cv_json WITH '"tvnum"'.

    IF iv_type = 'EWAY'.
      REPLACE ALL OCCURRENCES OF '"GSTIN"' IN cv_json WITH '"gstin"'.
      REPLACE ALL OCCURRENCES OF '"IRN"' IN cv_json WITH '"irn"'.
      REPLACE ALL OCCURRENCES OF '"QTY"'      IN cv_json WITH '"qty"'.
    ENDIF.

** GENERIC
*    REPLACE ALL OCCURRENCES OF ': ""' IN cv_json WITH ': null'.
*    REPLACE ALL OCCURRENCES OF ':""' IN cv_json WITH ':null'.

  ENDMETHOD.

  METHOD create_ewaybill.

    DATA json TYPE REF TO if_xco_cp_json_data.
    DATA lv_payload TYPE string.
    DATA lv_response TYPE string.

* Input to billing table
    DATA lt_billing TYPE tt_billing.

    lt_billing = VALUE #(
      FOR ls IN it_eway
      ( vbeln = ls-billingdocument )
    ).

    DATA: lt_header  TYPE STANDARD TABLE OF zi_einv_header,
          lt_item    TYPE STANDARD TABLE OF zi_einv_item,
          lt_pricing TYPE STANDARD TABLE OF zi_einv_pricing,
          lt_partner TYPE STANDARD TABLE OF zi_einv_partner,
          lt_plant   TYPE STANDARD TABLE OF zi_einv_plant_address,
          lt_gst     TYPE STANDARD TABLE OF zi_einv_gst.

    get_source_data(
      EXPORTING it_billing = lt_billing
      IMPORTING et_header  = lt_header
                et_item    = lt_item
                et_pricing = lt_pricing
                et_partner = lt_partner
                et_plant   = lt_plant
                et_gst     = lt_gst ).


* JSON TYPES
    TYPES: BEGIN OF ty_item,
             product_code       TYPE string,
             product_name       TYPE string,
             desc               TYPE string,
             hsn_sac            TYPE string,
             uqc                TYPE string,
             qty                TYPE p LENGTH 16 DECIMALS 3,
             txval              TYPE p LENGTH 16 DECIMALS 2,
             rt                 TYPE p LENGTH 5 DECIMALS 2,
             iamt               TYPE p LENGTH 16 DECIMALS 2,
             camt               TYPE p LENGTH 16 DECIMALS 2,
             samt               TYPE p LENGTH 16 DECIMALS 2,
             csamt              TYPE p LENGTH 16 DECIMALS 2,
             item_other_charges TYPE p LENGTH 16 DECIMALS 2,
             tmode              TYPE string,
             tdistance          TYPE p LENGTH 16 DECIMALS 0,
             tcode              TYPE string,
             ttin               TYPE string,
             tname              TYPE string,
             tinum              TYPE string,
             tdate              TYPE string,
             tvnum              TYPE string,
           END OF ty_item.

    TYPES tt_item TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.

    TYPES: BEGIN OF ty_invoice,
             company_name             TYPE string,
             supply_type              TYPE string,
             supply_subtype           TYPE string,
             doc_type                 TYPE string,
             inum                     TYPE string,
             idt                      TYPE string,
             val                      TYPE p LENGTH 16 DECIMALS 2,
             other_charges            TYPE p LENGTH 16 DECIMALS 2,
             doc_reference_no         TYPE string,

             vcode                    TYPE string,
             vname                    TYPE string,
             vtin                     TYPE string,
             v_act_state              TYPE string,
             v_address_1              TYPE string,
             v_address_2              TYPE string,
             v_place                  TYPE string,
             v_pin_code               TYPE string,
             v_state                  TYPE string,

             ccode                    TYPE string,
             cname                    TYPE string,
             ctin                     TYPE string,
             c_act_state              TYPE string,
             c_address_1              TYPE string,
             c_address_2              TYPE string,
             c_place                  TYPE string,
             c_pin_code               TYPE string,
             c_state                  TYPE string,

             shiptogstin              TYPE string,
             shiptotradename          TYPE string,
             shipto_master_code       TYPE string,
             shipto_address_1         TYPE string,
             shipto_address_2         TYPE string,
             shipto_place             TYPE string,
             shipto_pincode           TYPE string,

             dispatchfromgstin        TYPE string,
             dispatchfromtradename    TYPE string,
             dispatchfrom_master_code TYPE string,
             dispatchfrom_address_1   TYPE string,
             dispatchfrom_address_2   TYPE string,
             dispatchfrom_place       TYPE string,
             dispatchfrom_pincode     TYPE string,

             sub_supply_reason        TYPE string,
             irn                      TYPE string,

             items                    TYPE tt_item,
           END OF ty_invoice.

    TYPES tt_invoice TYPE STANDARD TABLE OF ty_invoice WITH EMPTY KEY.

    DATA lt_invoice TYPE tt_invoice.

    DATA: lv_item_oth  TYPE ty_amount,
          lv_total_oth TYPE ty_amount,
          lv_cgst_rate TYPE p LENGTH 5 DECIMALS 2,
          lv_sgst_rate TYPE p LENGTH 5 DECIMALS 2.

    DATA lv_root_gstin TYPE string.

* LOOP HEADER
    LOOP AT lt_header INTO DATA(ls_head).

      DATA(ls_inv) = VALUE ty_invoice( ).

      CLEAR lv_total_oth.

      " Exchange rate mapping for export and domestic case
      DATA(lv_exch_rate) = COND ty_amount(
        WHEN ls_head-distributionchannel = gc_dist_export
        THEN ls_head-accountingexchangerate
        ELSE 1 ).

      IF lv_exch_rate IS INITIAL OR lv_exch_rate = 0.
        lv_exch_rate = 1.
      ENDIF.

* BASIC
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

          "CUSTOMER (BILL TO)
          ls_inv-company_name = 'TIME TECHNOPLAST LTD'. "ls_head-companycodename.
          lv_root_gstin = ls_gst-gstin.
          ls_inv-vcode = lv_business_place.
          ls_inv-vname = ls_gst-organizationname1.
          ls_inv-vtin  = ls_gst-gstin.
          ls_inv-v_address_1 = ls_gst-streetname.
          ls_inv-v_address_2 = ls_gst-streetname.
          ls_inv-v_place     = ls_gst-cityname.
          ls_inv-v_pin_code  = ls_gst-postalcode.
          ls_inv-v_state     = get_gst_state_code( ls_gst-region ).
          ls_inv-v_act_state = get_gst_state_code( ls_gst-region ).
        ENDIF.

        "DISPATCH
        ls_inv-dispatchfrom_master_code = lv_business_place.

        ls_inv-dispatchfromgstin     = ls_gst-gstin.
        ls_inv-dispatchfromtradename = ls_plant_addr-dispatchname.

        ls_inv-dispatchfrom_address_1 = ls_plant_addr-addr1.
        ls_inv-dispatchfrom_address_2 = ls_plant_addr-addr2.
        ls_inv-dispatchfrom_place     = ls_plant_addr-city.
        ls_inv-dispatchfrom_pincode   = ls_plant_addr-postalcode.

      ENDIF.

      ls_inv-inum         = ls_head-documentreferenceid.
      ls_inv-idt          = format_date( ls_head-billingdocumentdate ).
      ls_inv-doc_reference_no = ls_head-billingdocument.

* VALUE
      ls_inv-val = round_amount( CONV ty_amount( ( ls_head-totalnetamount + ls_head-totaltaxamount ) * lv_exch_rate ) ).

* SUPPLY TYPE
      ls_inv-supply_type = 'O'. "Outward

* SUBTYPE - sales return pending
      IF ls_head-distributionchannel = gc_dist_export.
        ls_inv-supply_subtype = '3'. "Export
      ELSE.
        ls_inv-supply_subtype = '1'. "Supply
      ENDIF.

* DOC TYPE
      ls_inv-doc_type = 'INV'.

* CUSTOMER
      ls_inv-ccode = ls_head-buyercustomer.

      ls_inv-cname =
        |{ ls_head-buyername1 } { ls_head-buyername2 }|.

      ls_inv-ctin = ls_head-buyergstin.

      ls_inv-c_address_1 = ls_head-buyerstreet.
      ls_inv-c_address_2 = ls_head-buyerstreet.
      ls_inv-c_place     = ls_head-buyercity.
      ls_inv-c_pin_code  = ls_head-buyerpostalcode.

      ls_inv-c_state     = get_gst_state_code( ls_head-buyerregion ).
      ls_inv-c_act_state = get_gst_state_code( ls_head-buyerregion ).

      ls_inv-shiptogstin     = ls_head-buyergstin.
      ls_inv-shiptotradename = ls_head-buyername1.

* ITEMS
      LOOP AT lt_item INTO DATA(ls_item)
        WHERE billingdocument = ls_head-billingdocument.

        CLEAR: lv_item_oth, lv_cgst_rate, lv_sgst_rate.

        IF sy-tabix = 1.

          IF ls_head-distributionchannel = gc_dist_export.

* EXPORT CASE
            ls_inv-shipto_master_code = ls_head-yy1_port_detailscode_bdh. "Port Code

            ls_inv-shiptogstin     = 'URP'.
            ls_inv-shiptotradename = ls_head-yy1_port_detailsname_bdh.

            ls_inv-shipto_address_1 = ls_head-yy1_port_detailsadres_bdh.
            ls_inv-shipto_address_2 = ls_head-yy1_port_detailsadres_bdh.
            ls_inv-shipto_place     = ls_head-yy1_port_detailssname_bdh.
            ls_inv-shipto_pincode   = ls_head-yy1_port_detailspin_bdh.

          ELSE.

* DOMESTIC
            READ TABLE lt_partner INTO DATA(ls_ship)
              WITH KEY customer = ls_item-shiptoparty
              BINARY SEARCH.

            IF sy-subrc = 0.

              ls_inv-shipto_master_code = ls_item-shiptoparty.

              ls_inv-shiptogstin = ls_ship-shiptogstin.

              ls_inv-shiptotradename =
                |{ ls_ship-shiptoname1 } { ls_ship-shiptoname2 }|.

              ls_inv-shipto_address_1 = ls_ship-shiptostreet.
              ls_inv-shipto_address_2 = ls_ship-shiptostreet.
              ls_inv-shipto_place     = ls_ship-shiptocity.
              ls_inv-shipto_pincode   = ls_ship-shiptopostalcode.

            ENDIF.

          ENDIF.

        ENDIF.

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
          product_code = ls_item-material
          product_name = ls_item-billingdocumentitemtext
          desc         = ls_item-billingdocumentitemtext
          hsn_sac      = ls_item-hsncode
          uqc          = lv_unit "ls_item-billingquantityunit
          qty          = CONV #( ls_item-billingquantity )
          txval        = round_amount( CONV ty_amount(
                                            ls_item-netamount * lv_exch_rate ) )
                                     ).

* TAX
        LOOP AT lt_pricing INTO DATA(ls_price)
          WHERE billingdocument = ls_item-billingdocument
            AND billingdocumentitem = ls_item-billingdocumentitem.

          CASE ls_price-conditiontype.

            WHEN 'JOIG'.
              ls_item_json-iamt = round_amount( CONV ty_amount( ls_price-conditionamount * lv_exch_rate ) ).
              ls_item_json-rt = ls_price-conditionrateratio.

            WHEN 'JOCG'.
              ls_item_json-camt = round_amount( CONV ty_amount( ls_price-conditionamount * lv_exch_rate ) ).
              lv_cgst_rate = ls_price-conditionrateratio.

            WHEN 'JOSG' OR 'JOUG'.
              ls_item_json-samt = round_amount( CONV ty_amount( ls_price-conditionamount * lv_exch_rate ) ).
              lv_sgst_rate = ls_price-conditionrateratio.

            WHEN 'JTC1' OR 'JTC2'.  "Pass other changes condition type here
              lv_item_oth += round_amount(
                               CONV ty_amount(
                                 ls_price-conditionamount * lv_exch_rate ) ).

          ENDCASE.

        ENDLOOP.

        ls_item_json-item_other_charges = lv_item_oth.

        lv_total_oth += lv_item_oth.

        IF lv_cgst_rate IS NOT INITIAL AND lv_sgst_rate IS NOT INITIAL.
          ls_item_json-rt = lv_cgst_rate + lv_sgst_rate.
        ENDIF.

* TRANSPORT (from input)
        READ TABLE it_eway INTO DATA(ls_eway)
          WITH KEY billingdocument = ls_head-billingdocument.

        IF sy-subrc = 0.
          ls_inv-irn             = ls_eway-irn.
          ls_item_json-tmode     = ls_eway-transportmode.
          ls_item_json-tdistance = CONV #( round( val = ls_eway-transdistance dec = 0 ) ).
          ls_item_json-tcode     = ls_eway-transporterid.
          ls_item_json-ttin      = ls_eway-transportergstin.
          ls_item_json-tname     = ls_eway-transportername.
          ls_item_json-tinum     = ls_eway-transdocno.

          DATA: lv_input  TYPE string,
                lv_date   TYPE d,
                lv_output TYPE string.

          lv_input = ls_eway-transdocdate.

          IF lv_input IS NOT INITIAL.
            REPLACE ALL OCCURRENCES OF '-' IN lv_input WITH ''.
            lv_date = lv_input.

            " Convert to DD/MM/YYYY
            lv_output = |{ lv_date+6(2) }/{ lv_date+4(2) }/{ lv_date(4) }|.
          ENDIF.

          ls_item_json-tdate     = lv_output.
          ls_item_json-tvnum     = ls_eway-vehicleno.
        ENDIF.

        APPEND ls_item_json TO ls_inv-items.

      ENDLOOP.

      ls_inv-other_charges = lv_total_oth.

      APPEND ls_inv TO lt_invoice.

    ENDLOOP.


* ROOT JSON
    TYPES: BEGIN OF ty_root,
             ag_eway  TYPE string,   "auto_generate_ewaybill_through_api
             ag_pdf   TYPE string,   "auto_generate_ewaybill_pdf_through_api
             pdf_fmt  TYPE string,   "pdf_format
             gstin    TYPE string,
             invoices TYPE tt_invoice,
           END OF ty_root.

    DATA(ls_root) = VALUE ty_root(
      ag_eway  = 'true'
      ag_pdf   = 'true'
      pdf_fmt  = 'small'
      gstin    = lv_root_gstin
      invoices = lt_invoice ).

* JSON
    xco_cp_json=>data->from_abap(
      EXPORTING ia_abap = ls_root
      RECEIVING ro_json_data = json ).

    json->to_string(
      RECEIVING rv_string = lv_payload ).

    fix_json_keys( EXPORTING iv_type = 'EWAY'
    CHANGING cv_json = lv_payload ).


* API
    lv_response = post_api(
                    iv_json   = lv_payload
                    iv_action = 'GEN_EWAY' ).


* UPDATE
    rv_message = update_eway_table(
                   iv_response = lv_response
                   iv_action   = 'GEN_EWAY'
                   it_eway = it_eway ).

  ENDMETHOD.

  METHOD get_source_data.

    IF it_billing IS INITIAL.
      RETURN.
    ENDIF.

    SELECT *
      FROM zi_einv_header
      FOR ALL ENTRIES IN @it_billing
      WHERE billingdocument = @it_billing-vbeln
      INTO TABLE @et_header.

    SELECT *
      FROM zi_einv_item
      FOR ALL ENTRIES IN @it_billing
      WHERE billingdocument = @it_billing-vbeln
      INTO TABLE @et_item.

    SELECT *
      FROM zi_einv_pricing
      FOR ALL ENTRIES IN @it_billing
      WHERE billingdocument = @it_billing-vbeln
      INTO TABLE @et_pricing.

    SELECT *
      FROM zi_einv_partner
      INTO TABLE @et_partner.

    SELECT *
      FROM zi_einv_plant_address
      FOR ALL ENTRIES IN @it_billing
      WHERE billingdocument = @it_billing-vbeln
      INTO TABLE @et_plant.

    SELECT *
      FROM zi_einv_gst
      INTO TABLE @et_gst.

    SORT et_header  BY billingdocument.
    SORT et_item    BY billingdocument billingdocumentitem.
    SORT et_pricing BY billingdocument billingdocumentitem conditiontype.
    SORT et_partner BY customer.
    SORT et_plant   BY billingdocument.
    SORT et_gst     BY businessplace.


  ENDMETHOD.

  METHOD update_eway_table.

    TYPES: BEGIN OF ty_eway,
             success        TYPE abap_bool,
             ewbnum         TYPE string,
             ewbdate        TYPE string,
             validupto      TYPE string,
             message        TYPE string,
             docreferenceno TYPE string,
           END OF ty_eway.

    DATA lt_eway TYPE STANDARD TABLE OF ty_eway.

    DATA ls_edoc TYPE zedocinvoice.

    TRY.
        /ui2/cl_json=>deserialize(
          EXPORTING json = iv_response
          CHANGING  data = lt_eway ).
      CATCH cx_root INTO DATA(lx).
        rv_message = lx->get_text( ).
        RETURN.
    ENDTRY.

    DATA lv_success TYPE i VALUE 0.
    DATA lv_failed  TYPE i VALUE 0.

    DATA: lv_success_docs TYPE string,
          lv_failure_docs TYPE string,
          lv_error_msg    TYPE string.

    LOOP AT lt_eway INTO DATA(ls_eway).

      DATA: lv_date       TYPE datum,
            lv_time       TYPE uzeit,
            lv_valid_date TYPE datum,
            lv_valid_time TYPE uzeit.

      convert_datetime(
        EXPORTING iv_ts = ls_eway-ewbdate
        IMPORTING ev_date = lv_date ev_time = lv_time ).

      convert_datetime(
        EXPORTING iv_ts = ls_eway-validupto
        IMPORTING ev_date = lv_valid_date ev_time = lv_valid_time ).


      IF ls_eway-success = abap_true.

        lv_success += 1.
        lv_success_docs = |{ lv_success_docs } , { ls_eway-docreferenceno }|.

        DATA: lv_tname TYPE string,
              lv_tgst  TYPE string,
              lv_tdoc  TYPE string,
              lv_tvno  TYPE string,
              lv_tmode TYPE string,
              lv_tdist TYPE i.

        SELECT SINGLE odndocument, billingdocument
          FROM zedocinvoice
          WHERE billingdocument = @ls_eway-docreferenceno
          INTO @DATA(ls_exist).

        IF sy-subrc = 0.

          READ TABLE it_eway INTO DATA(ls_tr)
            WITH KEY billingdocument = ls_exist-billingdocument.

          IF sy-subrc = 0.
            lv_tname = ls_tr-transportername.
            lv_tgst  = ls_tr-transportergstin.
            lv_tdoc  = ls_tr-transdocno.
            lv_tvno  = ls_tr-vehicleno.
            lv_tmode = ls_tr-transportmode.
            lv_tdist = CONV i( round( val = ls_tr-transdistance dec = 0 ) ).
          ENDIF.

          UPDATE zedocinvoice
            SET ewaybillno        = @ls_eway-ewbnum,
                ewaycreatedate    = @lv_date,
                ewaycreatetime    = @lv_time,
                ewayvalidenddate  = @lv_valid_date,
                ewayvalidendat    = @lv_valid_time,
                errormessage      = @ls_eway-message,
                edocstatus        = 'EWAY_GENERATED',
                edocoverallstatus = 'COMPLETED',
                transportername   = @lv_tname,
                transportergstin  = @lv_tgst,
                transdocno        = @lv_tdoc,
                vehicleno         = @lv_tvno,
                transportmode     = @lv_tmode,
                transdistance     = @lv_tdist
            WHERE billingdocument = @ls_eway-docreferenceno.

        ELSE.

          SELECT SINGLE companycode, billingdocument, documentreferenceid
            FROM i_billingdocument
            WHERE billingdocument = @ls_eway-docreferenceno
            INTO @DATA(ls_bill).

          IF sy-subrc = 0.

            READ TABLE it_eway INTO ls_tr
              WITH KEY billingdocument = ls_bill-billingdocument.
            IF sy-subrc = 0.
              lv_tname = ls_tr-transportername.
              lv_tgst  = ls_tr-transportergstin.
              lv_tdoc  = ls_tr-transdocno.
              lv_tvno  = ls_tr-vehicleno.
              lv_tmode = ls_tr-transportmode.
              lv_tdist = CONV i( round( val = ls_tr-transdistance dec = 0 ) ).
            ENDIF.

            ls_edoc-odndocument     = ls_bill-documentreferenceid.
            ls_edoc-compcode        = ls_bill-companycode.
            ls_edoc-billingdocument = ls_eway-docreferenceno.
            ls_edoc-edocsourcetype  = 'SD_INVOICE'.

            ls_edoc-ewaybillno       = ls_eway-ewbnum.
            ls_edoc-ewaycreatedate   = lv_date.
            ls_edoc-ewaycreatetime   = lv_time.
            ls_edoc-ewayvalidenddate = lv_valid_date.
            ls_edoc-ewayvalidendat   = lv_valid_time.
            ls_edoc-edocstatus       = 'EWAY_GENERATED'.
            ls_edoc-edocoverallstatus = 'COMPLETED'.

            ls_edoc-transportername  = lv_tname.
            ls_edoc-transportergstin = lv_tgst.
            ls_edoc-transdocno       = lv_tdoc.
            ls_edoc-vehicleno        = lv_tvno.
            ls_edoc-transportmode    = lv_tmode.
            ls_edoc-transdistance    = lv_tdist.

            MODIFY zedocinvoice FROM @ls_edoc.

          ENDIF.

        ENDIF.

      ELSE.

        lv_failed += 1.
        lv_failure_docs = |{ lv_failure_docs } , { ls_eway-docreferenceno }|.
        lv_error_msg    = |{ lv_error_msg } , { ls_eway-message }|.

        UPDATE zedocinvoice
          SET errormessage      = @ls_eway-message,
              edocstatus        = 'EWAY_FAILED',
              edocoverallstatus = 'FAILED'
          WHERE billingdocument = @ls_eway-docreferenceno.

      ENDIF.

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

  METHOD convert_datetime.

    CLEAR: ev_date, ev_time.

    IF iv_ts IS NOT INITIAL.

      DATA: lv_d TYPE string,
            lv_t TYPE string.

      SPLIT iv_ts AT space INTO lv_d lv_t.

      IF lv_d IS NOT INITIAL.
        REPLACE ALL OCCURRENCES OF '-' IN lv_d WITH ''.
        ev_date = lv_d.
      ENDIF.

      IF lv_t IS NOT INITIAL.
        REPLACE ALL OCCURRENCES OF ':' IN lv_t WITH ''.
        ev_time = lv_t.
      ENDIF.

    ENDIF.


  ENDMETHOD.

ENDCLASS.
