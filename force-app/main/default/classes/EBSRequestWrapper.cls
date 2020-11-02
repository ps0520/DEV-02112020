public class EBSRequestWrapper {
    public TaxHeader TaxHeader;
    public List<TaxLines> TaxLines;
   
    public class TaxLines {
        public String LineId;
        public String Price;
        public String Quantity;
        public String Sku;
    }
    
    public class TaxHeader {
        public String CurrencyCode;
        public String OrderSource;
        public String ShipToProvince;
        public String BillToAccountReference;
        public String ShipToAccountReference;
    }
    
   
    public static void parse() {
     
      String responseBodyTest = '{"TaxHeader":{"Currency":"CAD","OrderSource":"Ecom-CA","ShipToProvince":"BC","BillToAccountReference":"0011n00002DGw0pAAD","ShipToAccountReference":"0011n00002DGw0pAAD"},"TaxLines":[{"LineId":"8020Q000001z8XmQL1","Price":"40","Quantity":"1","Sku":"MT20655"},{"LineId":"8020Q000001z8XmQL2","Price":"50.00","Quantity":"2","Sku":"MT22754"},{"LineId":"8020Q000001z8XmQL3","Price":"389.00","Quantity":"1","Sku":"STT-GF-005"},{"LineId":"8020Q000001z8XmQL4","Price":"15.00","Quantity":"1","Sku":"FREIGHT CHARGE"}]}';
	  //String requestBody = JSON.serialize(new EBSRequestWrapper(responseBodyTest));
       // string requestBody=Json.serialize(new EBSRequestWrapper(objOrder), true).replace('"CurrencyCode"','"currency"');
      //System.debug('**requestBody--'+requestBody);
		        
	}
}