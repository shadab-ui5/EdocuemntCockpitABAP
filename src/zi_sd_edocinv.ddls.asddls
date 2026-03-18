@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'E-Invoice Details'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_SD_EDOCINV
  as select from zedocinvoice
{
  key odndocument        as Odndocument,
      edocsourcetype     as Edocsourcetype,
      edocoverallstatus  as Edocoverallstatus,
      edocstatus         as Edocstatus,
      errormessage       as Errormessage,
      compcode           as Compcode,
      documentnumber     as Documentnumber,
      billingdocument    as Billingdocument,
      invrefnumber       as Invrefnumber,
      ackno              as Ackno,
      ackdate            as Ackdate,
      acktime            as Acktime,
      einvcancreasoncode as Einvcancreasoncode,
      einvcancelremarks  as Einvcancelremarks,
      einvcanceldate     as Einvcanceldate,
      einvcanceltime     as Einvcanceltime,
      qrcode             as Qrcode,
      signedqrcode       as Signedqrcode,
      signedinvoice      as Signedinvoice,
      ewaybillno         as Ewaybillno,
      ewaycreatedate     as Ewaycreatedate,
      ewaycreatetime     as Ewaycreatetime,
      ewayvalidenddate   as Ewayvalidenddate,
      ewayvalidendat     as Ewayvalidendat,
      ewaycancreasoncode as Ewaycancreasoncode,
      ewaycancelremarks  as Ewaycancelremarks,
      ewaycancdate       as Ewaycancdate,
      ewaycanctime       as Ewaycanctime,
      transporterid      as Transporterid,
      transdocno         as Transdocno,
      transdocdate       as Transdocdate,
      transdistance      as Transdistance,
      vehicleno          as Vehicleno,
      vehicletype        as Vehicletype,
      transportmode      as Transportmode,
      transportername    as Transportername,
      transportergstin   as Transportergstin
}
