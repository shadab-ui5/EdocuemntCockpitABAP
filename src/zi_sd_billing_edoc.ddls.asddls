@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Billing + EDoc Data'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZI_SD_BILLING_EDOC
  as select from    ZI_SD_BillingDocument as Billing

    left outer join ZI_SD_EDOCINV         as Edoc on Billing.BillingDocument = Edoc.Billingdocument

{

  key Billing.BillingDocument,

      Billing.BillingType,
      Billing.CompanyCode,
      Billing.SalesOrganization,
      Billing.DistributionChannel,
      Billing.Division,
      Billing.Customer,
      Billing.CustomerName,
      Billing.PayerParty,
      Billing.Plant,

      Billing.CreatedByUser,
      Billing.CreationDate,
      Billing.BillingDocumentDate,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      Billing.TotalNetAmount,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      Billing.TotalTaxAmount,
      Billing.TransactionCurrency,

      Billing.Region,
      Billing.PurchaseOrderByCustomer,
      Billing.AssignmentReference,
      Billing.AccountingDocument,
      Billing.DocumentReferenceID,


      Edoc.Odndocument,
      Edoc.Edocsourcetype,
      Edoc.Documentnumber,
      coalesce( Edoc.Edocstatus, 'PENDING' ) as Edocstatus,
      Edoc.Invrefnumber,
      Edoc.Ackno,
      Edoc.Ackdate,
      Edoc.Acktime,
      Edoc.Einvcancreasoncode,
      Edoc.Einvcancelremarks,
      Edoc.Einvcanceldate,
      Edoc.Einvcanceltime,
      Edoc.Qrcode,
      Edoc.Signedqrcode,
      Edoc.Signedqrcodestr,
      Edoc.Signedinvoice,
      Edoc.Ewaybillno,
      Edoc.Ewaycreatedate,
      Edoc.Ewaycreatetime,
      Edoc.Ewayvalidenddate,
      Edoc.Ewayvalidendat,
      Edoc.Ewaycancreasoncode,
      Edoc.Ewaycancelremarks,
      Edoc.Ewaycancdate,
      Edoc.Ewaycanctime,



      Billing.Transporterid,
      Billing.Transdocno,
      Billing.Transdocdate,
      Billing.Transdistance,
      Billing.Vehicleno,
      Billing.Vehicletype,
      Billing.Transportmode,
      Billing.Transportername,
      Billing.Transportergstin,

      Edoc.Errormessage,

      case

          when Edoc.Billingdocument is null
          then 'PENDING'

      //      Only E-Way Bill required
          when ( Billing.BillingType = 'JSN'
              or Billing.BillingType = 'JDC'
              or Billing.BillingType = 'F5'
              or Billing.BillingType = 'F8' )
              and Edoc.Edocstatus = 'EWAY_GENERATED'
          then 'COMPLETED'

      //      Only E-Invoice required
          when ( Billing.BillingType = 'L2'
              or Billing.BillingType = 'G2'
              or Billing.BillingType = 'F2' )
              and Billing.Division = 'SR'
              and Edoc.Edocstatus = 'EINVOICE_GENERATED'
          then 'COMPLETED'

      //      Both E-Invoice and E-Way Bill required
          when ( Billing.BillingType = 'CBRE'
              or Billing.BillingType = 'JSTO'
              or ( Billing.BillingType = 'F2' and Billing.Division <> 'SR' ) )
              and Edoc.Edocstatus = 'EINVOICE_EWAY_GENERATED'
          then 'COMPLETED'

          else Edoc.Edocoverallstatus

      end                                    as EdocOverallStatus

}
