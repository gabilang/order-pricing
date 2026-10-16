import ballerina/http;

# The market a deployment of this integration sells in. Each market prices differently.
public enum Region {
    US,
    EU
}

# Required at run time and at test time; there is no sensible default.
configurable Region region = ?;
# US sales tax added at checkout, or EU VAT already included in list prices, as a fraction.
configurable decimal taxRate = ?;
# ERP that owns the price list.
configurable string erpBaseUrl = ?;

configurable int port = 9090;

final http:Client erp = check new (erpBaseUrl);

public type PriceQuote record {|
    decimal net;
    decimal tax;
    decimal gross;
    string currency;
|};

# Applies the deployment's market rules to an ERP list price.
public function quote(decimal listPrice) returns PriceQuote {
    if region == EU {
        decimal net = decimal:round(listPrice / (1d + taxRate), 2);
        return {net, tax: listPrice - net, gross: listPrice, currency: "EUR"};
    }
    decimal tax = decimal:round(listPrice * taxRate, 2);
    return {net: listPrice, tax, gross: listPrice + tax, currency: "USD"};
}

service /pricing on new http:Listener(port) {
    resource function get quote/[string sku]() returns PriceQuote|error {
        decimal listPrice = check erp->get(string `/prices/${sku}`);
        return quote(listPrice);
    }
}
