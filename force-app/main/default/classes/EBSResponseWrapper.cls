/* class Created for Temp/Demo Purpose */

public class EBSResponseWrapper {
	
    public List<TaxSummary> TaxSummary;
	public List<TaxDetails> TaxDetails;
	public Object ErrorMessage;
    
    public static void parse(String responseBody) {
      // responseBody = ClsCAEBSReqTaxCalculation.makeEBSCallOut(objOrder);
      String responseBodyTest = '{"TaxSummary":[{"TaxType":"GST","TaxRate":"5","TaxAmount":"7.2"},{"TaxType":"PST","TaxRate":"7","TaxAmount":"10.8"}],"TaxDetails":[{"LineId":"8020Q000001z8XmQL1","Price":"40","Quantity":"1","Sku":"MT20655","TaxType":"GST","TaxAmount":"2"},{"LineId":"8020Q000001z8XmQL1","Price":"40","Quantity":"1","Sku":"MT20655","TaxType":"PST","TaxAmount":"2.8"},{"LineId":"8020Q000001z8XmQL2","Price":"50.00","Quantity":"2","Sku":"MT22754","TaxType":"GST","TaxAmount":"5"},{"LineId":"8020Q000001z8XmQL2","Price":"50.00","Quantity":"2","Sku":"MT22754","TaxType":"PST","TaxAmount":"7"},{"LineId":"8020Q000001z8XmQL4","Price":"10.00","Quantity":"1","Sku":"FREIGHT CHARGE","TaxType":"GST","TaxAmount":".2"},{"LineId":"8020Q000001z8XmQL4","Price":"10.00","Quantity":"1","Sku":"FREIGHT CHARGE","TaxType":"PST","TaxAmount":".28"}],"ErrorMessage":null}';
	  EBSResponseWrapper response = (EBSResponseWrapper)JSON.deserialize(responseBody, EBSResponseWrapper.class);
      System.debug('**response--'+response);
		        
	}
	public class TaxDetails {
		public String LineId;
		public String Price;
		public String Quantity;
		public String Sku;
		public String TaxType;
		public String TaxAmount;
	}

	public class TaxSummary {
		public String TaxType;
		public String TaxRate;
		public String TaxAmount;
	}
}