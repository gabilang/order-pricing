import ballerina/io;
import ballerina/test;

@test:Config {}
function quoteFollowsMarketRules() {
    PriceQuote q = quote(120d);
    io:println(string `[${region}] taxRate=${taxRate} -> ${q.toString()}`);
    test:assertEquals(q.gross, q.net + q.tax, "gross must equal net + tax");
    if region == EU {
        test:assertEquals(q.gross, 120d, "EU list prices already include VAT");
        test:assertEquals(q.currency, "EUR");
    } else {
        test:assertEquals(q.net, 120d, "US sales tax is added on top of the list price");
        test:assertEquals(q.currency, "USD");
    }
}
