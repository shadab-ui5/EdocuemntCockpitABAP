@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'E-Invoice Item Data'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_EINV_ITEM
  as select from    I_BillingDocumentItem as Item

    left outer join I_ProductPlantBasic   as Product on  Product.Product = Item.Material
                                                     and Product.Plant   = Item.Plant

{
  key Item.BillingDocument,
  key Item.BillingDocumentItem,

      Item.Material,
      Item.Plant,

      @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
      Item.BillingQuantity,
      Item.BillingQuantityUnit,
      Item.BillingDocumentItemText,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      Item.NetAmount,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      Item.TaxAmount,
      Item.TaxCode,
      Item.TransactionCurrency,

      Product.ConsumptionTaxCtrlCode as HSNCode,

      Item.ShipToParty,
      Item.PayerParty,
      Item.SoldToParty,
      Item.BillToParty

}
where
  Item.BillingQuantity is not null
