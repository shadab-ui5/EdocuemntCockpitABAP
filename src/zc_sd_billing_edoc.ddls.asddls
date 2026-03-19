@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Billing + EDoc Data - Final View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_SD_BILLING_EDOC
  as select from ZI_SD_BILLING_EDOC
{

      @EndUserText.label: 'Billing Document'
  key BillingDocument,

      @EndUserText.label: 'Billing Type'
      BillingType,

      @EndUserText.label: 'Company Code'
      CompanyCode,

      @EndUserText.label: 'Sales Organization'
      SalesOrganization,

      @EndUserText.label: 'Distribution Channel'
      DistributionChannel,

      @EndUserText.label: 'Division'
      Division,

      @EndUserText.label: 'Customer'
      Customer,

      @EndUserText.label: 'Customer Name'
      CustomerName,

      @EndUserText.label: 'Payer Party'
      PayerParty,

      @EndUserText.label: 'Plant'
      Plant,

      @EndUserText.label: 'Created By User'
      CreatedByUser,

      @EndUserText.label: 'Creation Date'
      CreationDate,

      @EndUserText.label: 'Billing Document Date'
      BillingDocumentDate,

      @EndUserText.label: 'Total Net Amount'
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      TotalNetAmount,

      @EndUserText.label: 'Total Tax Amount'
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      TotalTaxAmount,

      @EndUserText.label: 'Transaction Currency'
      TransactionCurrency,

      @EndUserText.label: 'Region'
      Region,

      @EndUserText.label: 'Customer Purchase Order'
      PurchaseOrderByCustomer,

      @EndUserText.label: 'Assignment Reference'
      AssignmentReference,

      @EndUserText.label: 'Accounting Document'
      AccountingDocument,

      @EndUserText.label: 'Document Reference ID'
      DocumentReferenceID,

      @EndUserText.label: 'E-Doc Overall Status'
      EdocOverallStatus,

      @EndUserText.label: 'E-Doc Status'
      Edocstatus,

      @EndUserText.label: 'Error Message'
      Errormessage,

      @EndUserText.label: 'ODN Document'
      Odndocument,

      @EndUserText.label: 'EDoc Source Type'
      Edocsourcetype,

      @EndUserText.label: 'Document Number'
      Documentnumber,

      @EndUserText.label: 'Invoice Reference Number'
      Invrefnumber,

      @EndUserText.label: 'Acknowledgement Number'
      Ackno,

      @EndUserText.label: 'Acknowledgement Date'
      Ackdate,

      @EndUserText.label: 'Acknowledgement Time'
      Acktime,

      @EndUserText.label: 'E-Invoice Cancel Reason Code'
      Einvcancreasoncode,

      @EndUserText.label: 'E-Invoice Cancel Remarks'
      Einvcancelremarks,

      @EndUserText.label: 'E-Invoice Cancel Date'
      Einvcanceldate,

      @EndUserText.label: 'E-Invoice Cancel Time'
      Einvcanceltime,

      @EndUserText.label: 'QR Code'
      Qrcode,

//      @EndUserText.label: 'Signed QR Code'
//      Signedqrcode,
      
      @EndUserText.label: 'Signed QR Code'
      Signedqrcodestr as Signedqrcode,

      @EndUserText.label: 'Signed Invoice'
      Signedinvoice,

      @EndUserText.label: 'E-Way Bill Number'
      Ewaybillno,

      @EndUserText.label: 'E-Way Bill Creation Date'
      Ewaycreatedate,

      @EndUserText.label: 'E-Way Bill Creation Time'
      Ewaycreatetime,

      @EndUserText.label: 'E-Way Bill Valid End Date'
      Ewayvalidenddate,

      @EndUserText.label: 'E-Way Bill Valid End Time'
      Ewayvalidendat,

      @EndUserText.label: 'E-Way Bill Cancel Reason Code'
      Ewaycancreasoncode,

      @EndUserText.label: 'E-Way Bill Cancel Remarks'
      Ewaycancelremarks,

      @EndUserText.label: 'E-Way Bill Cancel Date'
      Ewaycancdate,

      @EndUserText.label: 'E-Way Bill Cancel Time'
      Ewaycanctime,

      @EndUserText.label: 'Transporter ID'
      Transporterid,

      @EndUserText.label: 'Transport Document Number'
      Transdocno,

      @EndUserText.label: 'Transport Document Date'
      Transdocdate,

      @EndUserText.label: 'Transport Distance'
      Transdistance,

      @EndUserText.label: 'Vehicle Number'
      Vehicleno,

      @EndUserText.label: 'Vehicle Type'
      Vehicletype,

      @EndUserText.label: 'Transport Mode'
      Transportmode,

      @EndUserText.label: 'Transporter Name'
      Transportername,

      @EndUserText.label: 'Transporter GSTIN'
      Transportergstin

}
