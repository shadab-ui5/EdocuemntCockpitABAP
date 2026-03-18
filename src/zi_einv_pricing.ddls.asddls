@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'E-Invoice Pricing Data'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_EINV_PRICING
  as select from I_BillingDocumentItemPrcgElmnt as Pricing
    inner join   I_BillingDocumentItem          as Item on  Pricing.BillingDocument     = Item.BillingDocument
                                                        and Pricing.BillingDocumentItem = Item.BillingDocumentItem
{
  key Pricing.BillingDocument,
  key Pricing.BillingDocumentItem,
  key Pricing.ConditionType,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      Pricing.ConditionAmount,
      Pricing.ConditionRateAmount,
      Pricing.ConditionRateRatio,
      Pricing.TransactionCurrency,

      Item.Material,
      Item.Plant,
      @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
      Item.BillingQuantity,
      Item.BillingQuantityUnit
}

//ZPR0,ZHSS,ZPB1,ZCER,ZRNT,ZPR1,ZADC   -> Add Basic Price Condition Types here
//JOIG  -> IGST
//JOCG  -> CGST
//JOSG  -> SGST
//DRD1  -> Roundoff
//ZGIV  -> Total Invoice

where
       Item.BillingQuantity  is not null
  and(
       Pricing.ConditionType = 'ZPR0'
    or Pricing.ConditionType = 'ZHSS'
    or Pricing.ConditionType = 'ZPB1'
    or Pricing.ConditionType = 'ZCER'
    or Pricing.ConditionType = 'ZRNT'
    or Pricing.ConditionType = 'ZPR1'
    or Pricing.ConditionType = 'ZADC'
    or Pricing.ConditionType = 'JOIG'
    or Pricing.ConditionType = 'JOCG'
    or Pricing.ConditionType = 'JOSG'
    or Pricing.ConditionType = 'JTC1'
    or Pricing.ConditionType = 'JTC2'
    //    or Pricing.ConditionType = 'DRD1'
    //    or Pricing.ConditionType = 'ZGIV'
  )
