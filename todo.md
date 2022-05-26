Como um cliente, eu gostaria de visualizar o custo da minha utilização da última semana, assim eu posso monitorar os meus gastos.

Acceptance Criteria:
- Dado que tenho um smart meter ID, com plano atrelado a ele e dados de uso armazenados, quando eu solicito o custo de uso, é mostrado o custo correto do uso da semana passada
- Dado que tenho um smart meter ID sem um plano atrelado a ele e tenha dados de uso, é mostrado uma mensagem de erro. 

Tarefas

- Aqui (lib/service/electricty_reading_service.rb) sabe vamos filtrar pelo periodo proposto utilizando helpers https://gist.github.com/daicorrea-tw/e33ca4ec75d80e4968e0f19f19b835ce
- PricePlanWeekController

electricity_reading_service
    week

lib/service/price_plan_service.rb
    novo metodo consultado o metodo por semana (week) da service
    sem necesidade percorrer todos planos.



Service


```json
{
    "smartMeterId": "smart-meter-3",
    "electricityReadings": [
        {
            "time": "2020-11-17T08:00+00",
            "reading": 0.0503
        },
        {
            "time": "2020-11-18T08:00+00",
            "reading": 0.0213
        }
    ]
}
```


Calculo do custo de utilização
- Unidade de leitura : kW (KilloWatt)
- Unidade de tempo : Hour (h)
- Unidade de Energia consumida : kW x Hour = kWh
- Unidade da Tarifa : $ per kWh (ex 0.2 $ per kWh)

Para calcula o custo de uso para uma duração (D) onde vamos assumir que capturamos N leituras (er1,er2,er3....erN):

Média de leitura em KW = (er1.reading + er2.reading + ..... erN.Reading)/N
Tempo de utilização em horas = Duration(D) in hours
Energia consumida em kWh = average reading x usage time
Custo = tariff unit prices x energy consumed

Nota Técnica:
Esse calculo já foi previamente realizado no serviço de comparação de planos.

Size: M. 