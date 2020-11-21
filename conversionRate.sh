#!/bin/bash
# 
# Courtesy of Viet Nguyen
## AppD Events Service:    http://<events_service_endpoint>:9080
## AppD Global Acc: customer1_.......
## API Key:         .................
## For more information go to: https://docs.appdynamics.com/display/PRO45/Analytics+Events+API
# 2do: Logging for Toubleshooting the Script, Values for custom Metrics are too low i.e GPB 0.753 is 1. IDEA: Multiply with 1000 to get are more accurate calculation.



#variables for the Script
events_service_endpoint="http://<events_service_endpoint>:9080"
global_account_name=""
api_key=""
create_events_schema="/events/schema/currency_exchange_rates_base_usd"
publish_event_seg="/events/publish/currency_exchange_rates_base_usd"


### Create a schema (currency_exchange_rates_base_usd)
#curl -X POST $events_service_endpoint$create_events_schema -H"X-Events-API-AccountName:$global_account_name" -H"X-Events-API-Key:$api_key" -H"Content-type: application/vnd.appd.events+json;v=2" -d '{"schema":{"GBP":"float","HKD":"float","IDR":"float","ILS":"float","DKK":"float","INR":"float","CHF":"float","MXN":"float","CZK":"float","SGD":"float","THB":"float","HRK":"float","EUR":"float","MYR":"float","NOK":"float","CNY":"float","BGN":"float","PHP":"float","SEK":"float","PLN":"float","ZAR":"float","CAD":"float","ISK":"float","BRL":"float","RON":"float","NZD":"float","TRY":"float","JPY":"float","RUB":"float","KRW":"float","USD":"float","HUF":"float","AUD":"float"}}'



### Publish an Event (currency_exchange_rates_base_usd)
#curl -X POST $events_service_endpoint$publish_event_seg -H"X-Events-API-AccountName:$global_account_name" -H"X-Events-API-Key:$api_key" -H"Content-type: application/vnd.appd.events+json;v=2" -d '[{"GBP":0.7535446346,"HKD":7.7528449802,"IDR":14195.599763972,"ILS":3.3387844559,"DKK":6.2791030937,"INR":74.1304897581,"CHF":0.9113209138,"MXN":20.1176768103,"CZK":22.2034898424,"SGD":1.3431678328,"THB":30.2807047121,"HRK":6.3782348478,"EUR":0.8429570935,"MYR":4.0924723932,"NOK":8.9870184608,"CNY":6.5679844896,"BGN":1.6486554834,"PHP":48.2222034898,"PLN":3.7628761696,"ZAR":15.3580038776,"CAD":1.3052347636,"ISK":135.968979179,"BRL":5.3398803001,"RON":4.1081513951,"NZD":1.4402764899,"TRY":7.6262328247,"JPY":103.8354547754,"RUB":76.0871617635,"KRW":1115.4514035236,"USD":1.0,"AUD":1.3678664756,"HUF":303.0430751075,"SEK":8.6123240327}]'


start=$(date +%s)


prefix="{\"base\":\"USD\",\"rates\":"

string=$(curl -s https://api.ratesapi.io/api/latest?base=USD)

currency=${string#"$prefix"}

final_currency=$(sed 's/.\{21\}$//' <<< "$currency")

#API call to the ES of the Controller to publish an Event
curl -X POST $events_service_endpoint$publish_event_seg \
-H"X-Events-API-AccountName:$global_account_name" \
-H"X-Events-API-Key:$api_key" \
-H"Content-type: application/vnd.appd.events+json;v=2" \
-d '['${final_currency}']'

end=$(date +%s)
runtime=$(($end-$start))
echo
echo "====="
echo "The Script runs: "$runtime" second(s)." 
